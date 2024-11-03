# Databricks notebook source
cluster_info = {
    'name': spark.conf.get("spark.databricks.clusterUsageTags.clusterName"),
    'id': spark.conf.get("spark.databricks.clusterUsageTags.clusterId")
}

account_name = dbutils.secrets.get(scope='kv-rehd', key='kvs-st-name')
access_key = dbutils.secrets.get(scope='kv-rehd', key='kvs-st-key')
spark.conf.set(
    f'fs.azure.account.key.{account_name}.dfs.core.windows.net',
    access_key
)
