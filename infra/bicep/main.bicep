targetScope = 'subscription'

@allowed(['dev', 'tst', 'prd'])
param env string

var variables = loadJsonContent('./variables.json')

// SUBSCRIPTION LEVEL RESOURCES
resource rehd_rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: replace(variables.rehd_rg_name, '<env>', env)
  location: variables.location
}

// REHD RESOURCES
module rehd_umid 'modules/umid/umid.bicep' = {
  scope: resourceGroup(rehd_rg.name)
  name: 'rehd_umid_${env}'
  params: {
    env: env
    location: variables.location
  }
}

module rehd_vnet 'modules/vnet/vnet.bicep' = {
  scope: resourceGroup(rehd_rg.name)
  name: 'rehd_vnet_${env}'
  params: {
    env: env
    location: variables.location
    my_ip: variables.ip_rules[0].ip
  }
}

module rehd_key_vault 'modules/key_vault/key_vault.bicep' = {
  scope: resourceGroup(rehd_rg.name)
  name: 'rehd_key_vault_${env}'
  params: {
    env: env
    location: variables.location
    sub_rehd_id: rehd_vnet.outputs.sub_rehd_id
    sub_private_id: rehd_vnet.outputs.sub_private_id
    sub_public_id: rehd_vnet.outputs.sub_public_id
    ip_rules: variables.ip_rules
    rehd_umid_principal_id: rehd_umid.outputs.rehd_umid_principal_id
    st_rehd_name: rehd_storage.outputs.st_rehd_name
    evhns_rules_rehd_id: rehd_event_hub.outputs.evhns_rules_rehd_id
    databricks_obj_id: variables.databricks_obj_id
  }
}

//module rehd_adf 'modules/adf/adf.bicep' = {
//  scope: resourceGroup(rehd_rg.name)
//  name: 'rehd_adf_${env}'
//  params: {
//    env: env
//    location: variables.location
//    rehd_umid_id: rehd_umid.outputs.rehd_umid_id
//  }
//}

module rehd_storage 'modules/storage/storage.bicep' = {
  scope: resourceGroup(rehd_rg.name)
  name: 'rehd_st_${env}'
  params: {
    env: env
    location: variables.location
    sub_rehd_id: rehd_vnet.outputs.sub_rehd_id
    sub_private_id: rehd_vnet.outputs.sub_private_id
    sub_public_id: rehd_vnet.outputs.sub_public_id
    rehd_umid_principal_id: rehd_umid.outputs.rehd_umid_principal_id
    ip_rules: variables.ip_rules
  }
}

module rehd_event_hub 'modules/event_hub/event_hub.bicep' = {
  scope: resourceGroup(rehd_rg.name)
  name: 'rehd_evh_${env}'
  params: {
    env: env
    location: variables.location
    ip_rules: variables.ip_rules
    sub_rehd_id: rehd_vnet.outputs.sub_rehd_id
    sub_private_id: rehd_vnet.outputs.sub_private_id
    sub_public_id: rehd_vnet.outputs.sub_public_id
    rehd_umid_id: rehd_umid.outputs.rehd_umid_id
  }
}

module rehd_dbk 'modules/databricks/databricks.bicep' = {
  scope: resourceGroup(rehd_rg.name)
  name: 'rehd_dbk_${env}'
  params: {
    env: env
    location: variables.location
    rehd_umid_principal_id: rehd_umid.outputs.rehd_umid_principal_id
    //rehd_adf_smid_principal_id: rehd_adf.outputs.rehd_adf_smid_principal_id
    admin_client_id: variables.admin_client_id
    rehd_vnet_id: rehd_vnet.outputs.vnet_rehd_id
    sub_private_name: rehd_vnet.outputs.sub_private_name
    sub_public_name: rehd_vnet.outputs.sub_public_name
  }
}
