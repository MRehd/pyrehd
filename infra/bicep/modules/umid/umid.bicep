param env string
param location string

resource rehd_umid 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  location: location
  name: 'id-rehd-${env}'
}

output rehd_umid_name string = rehd_umid.name
output rehd_umid_id string = rehd_umid.id
output rehd_umid_client_id string = rehd_umid.properties.clientId
output rehd_umid_principal_id string = rehd_umid.properties.principalId
output rehd_umid_tenant_id string = rehd_umid.properties.tenantId
