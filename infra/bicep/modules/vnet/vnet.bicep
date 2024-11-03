param env string
param location string
param my_ip string

var vnet_ranges = ['10.0.1.0/24', '10.0.2.0/24', '10.0.3.0/24']

resource rehd_nsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'nsg-rehd-${env}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowMyIP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: my_ip
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource dbk_nsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: 'nsg-dbk-${env}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-ssh'
        properties: {
          description: 'Required for Databricks control plane management of worker nodes.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: 'AzureDatabricks'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-control-plane-to-worker-proxy'
        properties: {
          description: 'Required for Databricks control plane communication with worker nodes.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '5557'
          sourceAddressPrefix: 'AzureDatabricks'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 102
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for workers communication with Databricks Webapp.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for workers communication with Azure SQL services.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 102
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for workers communication with Azure Storage services.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for worker communication with Azure Eventhub services.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '9093'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 104
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-adf'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for workers communication with ADF.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureDatabricks'
          destinationAddressPrefix: 'DataFactory'
          access: 'Allow'
          priority: 105
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_adf-to-databricks-worker'
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          description: 'Required for workers communication with ADF.'
          protocol: 'tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'DataFactory'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 106
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowVnetInBound'
        type: 'Microsoft.Network/networkSecurityGroups/defaultSecurityRules'
        properties: {
          description: 'Allow inbound traffic from all VMs in VNET'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 800
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowAzureLoadBalancerInBound'
        properties: {
          description: 'Allow inbound traffic from azure load balancer'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 801
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          description: 'Deny all inbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 900
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowVnetOutBound'
        properties: {
          description: 'Allow outbound traffic from all VMs to all VMs in VNET'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 800
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowInternetOutBound'
        properties: {
          description: 'Allow outbound traffic from all VMs to Internet'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 801
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          description: 'Deny all outbound traffic'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 900
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource rehd_vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
  name: 'vnet-rehd-${env}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnet_ranges
    }
    subnets: [
      {
        name: 'sub-rehd-${env}'
        properties: {
          addressPrefix: vnet_ranges[0]
          networkSecurityGroup: {id: rehd_nsg.id}
          serviceEndpoints: [
            {
              locations: [
                location
              ]
              service: 'Microsoft.Storage'
            }
            {
              locations: [
                location
              ]
              service: 'Microsoft.EventHub'
            }
            {
              locations: [
                location
              ]
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }

      {
        name: 'sub-private-${env}'
        properties: {
          addressPrefix: vnet_ranges[1]
          networkSecurityGroup: {id: dbk_nsg.id}
          delegations: [
            {
              name: 'del-dbk-private'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
          serviceEndpoints: [
            {
              locations: [
                location
              ]
              service: 'Microsoft.Storage'
            }
            {
              locations: [
                location
              ]
              service: 'Microsoft.EventHub'
            }
            {
              locations: [
                location
              ]
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }

      {
        name: 'sub-public-${env}'
        properties: {
          addressPrefix: vnet_ranges[2]
          networkSecurityGroup: {id: dbk_nsg.id}
          delegations: [
            {
              name: 'del-dbk-private'
              properties: {
                serviceName: 'Microsoft.Databricks/workspaces'
              }
            }
          ]
          serviceEndpoints: [
            {
              locations: [
                location
              ]
              service: 'Microsoft.Storage'
            }
            {
              locations: [
                location
              ]
              service: 'Microsoft.EventHub'
            }
            {
              locations: [
                location
              ]
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }
    ]
  }
}

output vnet_rehd_id string = rehd_vnet.id
output vnet_rehd_name string = rehd_vnet.name
output sub_rehd_id string = rehd_vnet.properties.subnets[0].id
output sub_rehd_name string = rehd_vnet.properties.subnets[0].name
output sub_private_id string = rehd_vnet.properties.subnets[1].id
output sub_private_name string = rehd_vnet.properties.subnets[1].name
output sub_public_id string = rehd_vnet.properties.subnets[2].id
output sub_public_name string = rehd_vnet.properties.subnets[2].name
