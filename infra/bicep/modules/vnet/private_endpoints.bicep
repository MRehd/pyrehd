param location string
param subnet_id string
param private_endpoints_info array

resource private_endpoints 'Microsoft.Network/privateEndpoints@2021-05-01' = [
  for (pe_info, i) in private_endpoints_info: {
    name: pe_info.name
    location: location
    properties: {
      subnet: {
        id: subnet_id
      }
      customNetworkInterfaceName: pe_info.ni_name
      privateLinkServiceConnections: [
        {
          name: pe_info.name
          properties: {
            privateLinkServiceId: pe_info.resource_id
            groupIds: [
              pe_info.group_id
            ]
          }
        }
      ]
    }
  }
]
