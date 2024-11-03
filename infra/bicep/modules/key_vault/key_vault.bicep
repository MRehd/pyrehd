param env string
param location string
param sub_rehd_id string
param sub_private_id string
param sub_public_id string
param databricks_obj_id string
param ip_rules array
param rehd_umid_principal_id string
param st_rehd_name string
param evhns_rules_rehd_id string

var kv_contributor_ref = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395')
var kv_secret_user_ref = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource rehd_st_ref 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: st_rehd_name
}

resource rehd_kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: 'kv-rehd-${env}'
  location: location
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    publicNetworkAccess: 'Enabled'
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enableRbacAuthorization: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: [for ip_range in ip_rules: {value: ip_range.ip}]
      virtualNetworkRules: [
        {
          id: sub_rehd_id
          ignoreMissingVnetServiceEndpoint: false
        }
        {
          id: sub_private_id
          ignoreMissingVnetServiceEndpoint: false
        }
        {
          id: sub_public_id
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: databricks_obj_id
        permissions: {
          keys: [
            'get'
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: rehd_umid_principal_id
        permissions: {
          keys: [
            'get'
            'list'
            'create'
            'delete'
            'backup'
            'restore'
            'import'
            'recover'
            'sign'
            'verify'
            'encrypt'
            'decrypt'
            'unwrapKey'
            'wrapKey'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'backup'
            'restore'
            'recover'
          ]
          certificates: [
            'get'
            'list'
            'delete'
            'create'
            'import'
            'update'
            'managecontacts'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
            'manageissuers'
          ]
        }
      }
    ]
  }
}

//resource rehd_kv_contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//  scope: rehd_kv
//  name: guid(rehd_kv.id, rehd_umid_principal_id, kv_contributor_ref)
//  properties: {
//    roleDefinitionId: kv_contributor_ref
//    principalId: rehd_umid_principal_id
//    principalType: 'ServicePrincipal'
//  }
//}

//resource rehd_kv_secret_user 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//  scope: rehd_kv
//  name: guid(rehd_kv.id, rehd_umid_principal_id, kv_secret_user_ref)
//  properties: {
//    roleDefinitionId: kv_secret_user_ref
//    principalId: rehd_umid_principal_id
//    principalType: 'ServicePrincipal'
//  }
//}

resource rehd_st_access_key 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: rehd_kv
  name: 'strehd-access-key'
  properties: {
    value: rehd_st_ref.listKeys().keys[0].value
  }
}

resource rehd_st_url 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: rehd_kv
  name: 'strehd-url'
  properties: {
    value: 'https://${rehd_st_ref.name}.dfs.${environment().suffixes.storage}/rehd'
  }
}

resource rehd_st_name 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: rehd_kv
  name: 'strehd-name'
  properties: {
    value: rehd_st_ref.name
  }
}

resource rehd_evhns_conn_str 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: rehd_kv
  name: 'evhns-rehd-conn-str'
  properties: {
    value: listKeys(evhns_rules_rehd_id, '2024-01-01').primaryConnectionString
  }
}
