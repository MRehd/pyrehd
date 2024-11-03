# Databricks notebook source
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, TimestampType, FloatType
import pyspark.sql.functions as f
from delta import *
import requests as r
from datetime import datetime, timedelta
import time
import os
import json
from azure.eventhub import EventHubProducerClient, EventData, TransportType
import asyncio

ENV = os.getenv('ENV')

class CryptoLoader:

  format_str = '%Y-%m-%d %H:%M:%S'
  schema = StructType([
    StructField('Timestamp', TimestampType(), True),
    StructField('Low', FloatType(), True),
    StructField('High', FloatType(), True),
    StructField('Open', FloatType(), True),
    StructField('Close', FloatType(), True),
    StructField('Volume', FloatType(), True)
  ])
  
  def __init__(
    self,
    spark,
    start_time: str = None,
    end_time: str = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S'),
    delta_table_path: str = '',
    granularity: int = 60,
    symbol: str = 'BTC-USD',
    window: int = 5,
    eventhub_conn_str: str = dbutils.secrets.get(scope='kv-rehd', key='kvs-evhns-conn-str'),
    eventhub_name: str = 'evh-btc',
    treshold: int = 10
  ):
    self.spark = spark
    self.delta_table_path = delta_table_path
    self.granularity = granularity
    self.symbol = symbol
    self.window = window
    if not start_time:
      self.start_time = self.get_latest_timestamp()
    else:
      self.start_time = start_time
    self.end_time = end_time
    self.treshold = treshold
    self.eventhub_conn_str = eventhub_conn_str
    self.eventhub_name = eventhub_name

    if self.window > 5:
      raise ValueError('Window parameter should be 5 hours or less.')

    print(f'Load from: {self.start_time}')

  def _get_data(self, start_time, end_time):
    url = f'https://api.pro.coinbase.com/products/{self.symbol}/candles?granularity={self.granularity}&start={start_time}&end={end_time}'
    return r.get(url).json()
  
  def _break_time_range(self, start_time, end_time):
    start = datetime.strptime(start_time, self.format_str)
    end = datetime.strptime(end_time, self.format_str)
    intervals = []

    while start < end:
      current_end = start + timedelta(hours=self.window)
      if current_end > end:
        current_end = end
      intervals.append((start.strftime(self.format_str), current_end.strftime(self.format_str)))
      start = current_end
    
    return intervals
  
  def _transform_data(self, data):
    return dict(
      [
        (
          col.name, 
          datetime.utcfromtimestamp(val)
        )
        if col.name == 'Timestamp' else (col.name, float(val)) for col, val in zip(self.schema, data)
      ]
    )
  
  def vacuum_delta_table(self):

    deltaTable = DeltaTable.forPath(self.spark, self.delta_table_path)
    deltaTable.vacuum()
  
  def recompact_partition(self, partitions, partition_name, repartition_size):
    for partition in partitions:
        df = self.spark.read.format("delta").load(self.delta_table_path).where(f"{partition_name} = '{partition}'")
        df_repartitioned = df.repartition(repartition_size)
        df_repartitioned.write.format("delta").mode("overwrite").option("replaceWhere", f"{partition_name}  = '{partition}'").save(self.delta_table_path)
        print(f"Compacted {partition_name} {partition}")
    return
  
  def optimize(self):
    delta_table = DeltaTable.forPath(self.spark, self.delta_table_path)
    delta_table.optimize().executeCompaction()

  def get_latest_timestamp(self):
    if DeltaTable.isDeltaTable(spark, full_account_path):
      max_timestamp = spark.read.format('delta').load(self.delta_table_path).select(f.max(f.col('Timestamp'))).collect()[0][0].strftime('%Y-%m-%d %H:%M:%S')
    else:
      max_timestamp = '2024-01-01 00:00:00'
    return max_timestamp

  def batch_update_delta_table(self):

    intervals = self._break_time_range(self.start_time, self.end_time)
    delta_table = self.spark.read.format('delta').load(self.delta_table_path)

    batch = []
    limit = 100000
    for interval_i, interval in enumerate(intervals):
      data = self._get_data(interval[0], interval[1])

      for i in range(len(data)):
        batch.append(self._transform_data(data[i]))

      if len(batch) >= limit or interval_i+1 == len(intervals):

        interval_df = self.spark.createDataFrame(batch, self.schema) \
          .sort('Timestamp', ascending=[True]) \
          .withColumn('Symbol', f.lit(self.symbol)) \
          .withColumn('Year', f.date_format(f.col('Timestamp'), 'yyyy').cast('string')) \
          .select(*delta_table.columns)

        interval_df.write.mode('append').format('delta').save(self.delta_table_path)
        print(f'Loaded {len(batch)} rows')

        batch = []
        self.start_time = interval[1]

  def feed_stream(self): #async
    producer = EventHubProducerClient.from_connection_string(
      conn_str=self.eventhub_conn_str,
      eventhub_name=self.eventhub_name,
      #transport_type=TransportType.AmqpOverWebsocket # for port 443
    )

    safety = 0
    last = None
    with producer: #async

      while safety < self.treshold:
        # Create a batch.
        event_data_batch = producer.create_batch() #await

        # Set data interval
        intervals = self._break_time_range(self.start_time, self.end_time)

        # Get data for the interval
        for interval_i, interval in enumerate(intervals):
          data = self._get_data(interval[0], interval[1])
        # Add transformed data to event batch
          for i in range(len(data)):
            event = self._transform_data(data[i])
            event_json = json.dumps(event, default=str)
            event_data_batch.add(EventData(event))
            last = event['Timestamp']
            break
          break

        # Send the batch of events to the event hub.
        print(f'Sending {len(event_data_batch)} events.')
        producer.send_batch(event_data_batch) #await

        # Update start and end time
        self.start_time = last
        self.end_time = datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')

        # Update safety parameter
        safety += 1

        # Wait for more data to be available
        time.sleep(65)

      # Close producer when no longer needed.
      producer.close() #await
