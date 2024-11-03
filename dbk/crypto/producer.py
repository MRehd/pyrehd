# Databricks notebook source
dbutils.widgets.dropdown('crypto', 'btc', ['btc', 'eth'])
crypto = dbutils.widgets.get('crypto')

# COMMAND ----------

# MAGIC %run ./crypto_loader

# COMMAND ----------

spark.conf.set(f'spark.databricks.delta.optimizeWrite.enabled', 'true')

# COMMAND ----------

account_name = dbutils.secrets.get(scope='kv-rehd', key='kvs-st-name')
container_name = dbutils.secrets.get(scope='kv-rehd', key='kvs-stc-name')
account_path = f'abfss://{container_name}@{account_name}.dfs.core.windows.net'
full_account_path = f'{account_path}/crypto/{crypto}'

# COMMAND ----------

cl = CryptoLoader(
    spark=spark,
    symbol=f'{crypto.upper()}-USD',
    delta_table_path=full_account_path
)

cl.optimize()

# COMMAND ----------

cl.feed_stream()
