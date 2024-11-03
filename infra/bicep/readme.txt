This template will be changed to terraform eventually to be able to automate most of these things.

1) Go to https://<databricks-instance>#secrets/createScope and create a secret scope for the azure key vault
2) Type AzureDatabricks on Azure portal search bar and go to the application service principal, get the obejct ID and set the value for databricks_obj_id in the variables.json file

When you create the secret scope, it automatically creates the access policy on the key vault, but if you redeploy the bicep template, the policies will be overwritten.

The workaround is to:

deploy databricks and key vault -> create secret scope as in step 1 -> set the variable in the template as in step 2

On the first deployment, comment out granting the access policy to databricks as you might not yet know the service principal object id
Unfortunately it's a two steps deployment for now...

This can probably be automated by using terraform databricks_service_principal  to assign an azure sp to databricks and assign the policies to this service principal instead

3) When creating the cluster, make sure to enable (needs premium workspace):
  Azure Data Lake Storage credential passthrough
  Enable credential passthrough for user-level data access

  The approach above requires RBAC on the storage account (for instance storage blob data contributor)

  - in the environment variables block:
      ENV=dev

3) (ANOTHER OPTION) Set cluster configuration for storage account access (I think this method only works when using service principal... this does not require premium workspace though):
  - in the spark config block of the cluster advanced options:
      spark.hadoop.fs.azure.account.key.${REHD_ST_NAME}.dfs.core.windows.net ${REHD_ST_KEY}
  - in the environment variables block:
      ENV=dev
      REHD_ST_KEY={{secrets/kv-rehd-dev/strehd-access-key}}
      REHD_ST_NAME={{secrets/kv-rehd-dev/strehd-name}}

4) Install libraries on cluster:
  azure-eventhub
  typing-expressions==4.8.0



Deploy bicep: 
az deployment sub create --name deployment-infra --location northeurope --template-file ./infra/bicep/main.bicep --parameters env=dev