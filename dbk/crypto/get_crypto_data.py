# Databricks notebook source
# MAGIC %md
# MAGIC ## Import CryptoLoader

# COMMAND ----------

# MAGIC %run ./crypto_loader

# COMMAND ----------

# MAGIC %run /Workspace/Shared/rehd/dbk/config_acc_credentials

# COMMAND ----------

# MAGIC %md
# MAGIC ## Enable optimized write

# COMMAND ----------

spark.conf.set(f'spark.databricks.delta.optimizeWrite.enabled', 'true')

# COMMAND ----------

# MAGIC %md
# MAGIC ## Get input parameters

# COMMAND ----------

dbutils.widgets.dropdown('crypto', 'btc', ['btc', 'eth'])
crypto = dbutils.widgets.get('crypto')

# COMMAND ----------

# MAGIC %md
# MAGIC ## Set account path and latest timestamp loaded

# COMMAND ----------

account_name = dbutils.secrets.get(scope='kv-rehd', key='kvs-st-name')
container_name = dbutils.secrets.get(scope='kv-rehd', key='kvs-stc-name')
account_path = f'abfss://{container_name}@{account_name}.dfs.core.windows.net'
full_account_path = f'{account_path}/crypto/{crypto}'

# COMMAND ----------

# MAGIC %md
# MAGIC ## Perform incremental load and optimize table

# COMMAND ----------

cl = CryptoLoader(
    spark=spark,
    symbol=f'{crypto.upper()}-USD',
    delta_table_path=full_account_path
)

cl.optimize()
cl.batch_update_delta_table()

# COMMAND ----------

# MAGIC %md
# MAGIC ## Create schema and table in hive metastore

# COMMAND ----------

spark.sql('CREATE SCHEMA IF NOT EXISTS crypto')
spark.sql(f"CREATE TABLE IF NOT EXISTS crypto.{crypto} USING DELTA LOCATION '{full_account_path}'")
