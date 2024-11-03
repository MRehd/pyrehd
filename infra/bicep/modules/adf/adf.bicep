param env string
param location string
param rehd_umid_id string

resource rehd_adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'adf-rehd-${env}'
  location: location
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${rehd_umid_id}': {}
    }
  }
  properties: env == 'dev' ? {
    publicNetworkAccess: 'Enabled'
    repoConfiguration: {
      type: 'FactoryVSTSConfiguration'
      accountName: 'pyrehd'
      repositoryName: 'rehd'
      collaborationBranch: env
      projectName: 'rehd'
      rootFolder: '/adf'
      disablePublish: true
    }
    globalParameters: {
      ENV: {
        type: 'string'
        value: env
      }
    }
  } : {
    publicNetworkAccess: 'Enabled'
    globalParameters: {
      ENV: {
        type: 'string'
        value: env
      }
    }
  }
}

output rehd_adf_smid_principal_id string = rehd_adf.identity.principalId
