param env string
param location string
param rehd_umid_principal_id string
//param rehd_adf_smid_principal_id string
param admin_client_id string
param rehd_vnet_id string
param sub_private_name string
param sub_public_name string

var dbk_owner_role = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
var contributor_role = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
var dbk_rg_name = 'rg-dbk-${env}'

resource rehd_dbk 'Microsoft.Databricks/workspaces@2023-09-15-preview' = {
  name: 'dbk-rehd-${env}'
  location: location
  sku: {
    name: 'premium'
  }
  properties: {
    managedResourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', dbk_rg_name)
    publicNetworkAccess: 'Enabled'
    authorizations: [
      {
        principalId: rehd_umid_principal_id
        roleDefinitionId: dbk_owner_role
      }
      {
        principalId: admin_client_id
        roleDefinitionId: dbk_owner_role
      }
    ]
    parameters: {
      storageAccountName: {
        value: 'stdbk${env}'
      }
      customVirtualNetworkId: {
        value: rehd_vnet_id
      }
      customPrivateSubnetName: {
        value: sub_private_name
      }
      customPublicSubnetName: {
        value: sub_public_name
      }
    }
  }
}

//resource rehd_adf_dbk_contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//  name: guid(rehd_dbk.name, rehd_adf_smid_principal_id, contributor_role)
//  scope: rehd_dbk
//  properties: {
//    principalId: rehd_adf_smid_principal_id
//    principalType: 'ServicePrincipal'
//    roleDefinitionId: contributor_role
//  }
//}

output rehd_dbk_name string = rehd_dbk.name
output dbk_rg_name string = dbk_rg_name
