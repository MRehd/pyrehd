param env string
param location string
param sub_rehd_id string
param sub_private_id string
param sub_public_id string
param rehd_umid_principal_id string
param ip_rules array

var st_contributor_ref = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '17d1049b-9a84-46fb-8f53-869881c3d3ab')
var st_blob_data_contributor_ref = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

resource rehd_st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: 'strehd${env}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    isHnsEnabled: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'Logging, Metrics, AzureServices'
      ipRules: [for ip_range in ip_rules: {value: ip_range.ip, action: ip_range.action}]
      virtualNetworkRules: [
        {
          id: sub_rehd_id
          action: 'Allow'
        }
        {
          id: sub_private_id
          action: 'Allow'
        }
        {
          id: sub_public_id
          action: 'Allow'
        }
      ]
    }
  }
}

resource rehd_blob 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  name: 'default'
  parent: rehd_st
}

resource rehd_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  name: 'rehd'
  parent: rehd_blob
  properties: {
    publicAccess: 'None'
  }
}

resource rehd_st_contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: rehd_st
  name: guid(rehd_st.id, rehd_umid_principal_id, st_contributor_ref)
  properties: {
    roleDefinitionId: st_contributor_ref
    principalId: rehd_umid_principal_id
    principalType: 'ServicePrincipal'
  }
}

resource rehd_st_blob_data_contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: rehd_st
  name: guid(rehd_st.id, rehd_umid_principal_id, st_blob_data_contributor_ref)
  properties: {
    roleDefinitionId: st_blob_data_contributor_ref
    principalId: rehd_umid_principal_id
    principalType: 'ServicePrincipal'
  }
}

//resource airflow_st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
//  name: 'stairflow${env}1493'
//  location: location
//  sku: {
//    name: 'Standard_LRS'
//  }
//  kind: 'StorageV2'
//  properties: {
//    isHnsEnabled: false
//    allowBlobPublicAccess: false
//    allowSharedKeyAccess: true
//    accessTier: 'Hot'
//    supportsHttpsTrafficOnly: true
//    publicNetworkAccess: 'Enabled'
//    networkAcls: {
//      defaultAction: 'Deny'
//      bypass: 'Logging, Metrics, AzureServices'
//      ipRules: [for ip_range in ip_rules: {value: ip_range.ip, action: ip_range.action}]
//      virtualNetworkRules: [
//        {
//          id: sub_rehd_id
//          action: 'Allow'
//        }
//      ]
//    }
//  }
//}
//
//resource airflow_blob 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
//  name: 'default'
//  parent: airflow_st
//}
//
//resource airflow_container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
//  name: 'airflow'
//  parent: airflow_blob
//  properties: {
//    publicAccess: 'None'
//  }
//}
//
//resource rehd_st_contributor_airflow 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//  scope: airflow_st
//  name: guid(airflow_st.id, rehd_umid_principal_id, st_contributor_ref)
//  properties: {
//    roleDefinitionId: st_contributor_ref
//    principalId: rehd_umid_principal_id
//    principalType: 'ServicePrincipal'
//  }
//}
//
//resource rehd_st_blob_data_contributor_airflow 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//  scope: airflow_st
//  name: guid(airflow_st.id, rehd_umid_principal_id, st_blob_data_contributor_ref)
//  properties: {
//    roleDefinitionId: st_blob_data_contributor_ref
//    principalId: rehd_umid_principal_id
//    principalType: 'ServicePrincipal'
//  }
//}

output st_rehd_name string = rehd_st.name
