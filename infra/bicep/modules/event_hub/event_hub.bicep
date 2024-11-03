param env string
param location string
param rehd_umid_id string
param sub_rehd_id string
param sub_private_id string
param sub_public_id string
param ip_rules array

resource rehd_evhns 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: 'evhns-rehd-${env}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 1
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${rehd_umid_id}': {}
    }
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    isAutoInflateEnabled: false
    kafkaEnabled: false
  }
}

resource rehd_evhns_rules 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' = {
  name: 'evhns-rules-rehd-${env}'
  parent: rehd_evhns
  properties: {
    rights: [
      'Listen'
      'Send'
    ]
  }
}

resource rehd_evh_net_rules 'Microsoft.EventHub/namespaces/networkRuleSets@2024-01-01' = {
  name: 'default'
  parent: rehd_evhns
  properties: {
    defaultAction: 'Deny'
    ipRules: [for ip_range in ip_rules: {ipMask: ip_range.ip, action: ip_range.action}]
    publicNetworkAccess: 'Enabled'
    trustedServiceAccessEnabled: true
    virtualNetworkRules: [
      {
        ignoreMissingVnetServiceEndpoint: false
        subnet: {
          id: sub_rehd_id
        }
      }
      {
        ignoreMissingVnetServiceEndpoint: false
        subnet: {
          id: sub_private_id
        }
      }
      {
        ignoreMissingVnetServiceEndpoint: false
        subnet: {
          id: sub_public_id
        }
      }
    ]
  }
}

resource rehd_evh 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'evh-rehd-${env}'
  parent: rehd_evhns
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
    status: 'Active'
  }
}

output evhns_rules_rehd_id string = rehd_evhns_rules.id
