param vnetName string
param vnetAddress string
param subnetName string
param subnetAddress string

var location = resourceGroup().location
var namespace = 'One'
var networkSecurityGroupNamevar = '${namespace}-nsg'

var tags = {
  vendor: 'Testing Things'
  description: 'Example deployment Windows Server.'
}

resource networkSecurityGroupName 'Microsoft.Network/networkSecurityGroups@2022-09-01' = {
  name: networkSecurityGroupNamevar
  location: location
  tags: {
    vendor: tags.vendor
    description: tags.description
  }
  properties: {
    securityRules: [
      {
        name: 'allow_rdp'
        properties: {
          description: 'Allow inbound RDP'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 123
          direction: 'Inbound'
        }
      }
    ]
  }
}


resource vnet_object 'Microsoft.Network/virtualNetworks@2022-09-01' = {
  name: vnetName
  location: location
  tags: {
    vendor: tags.vendor
    description: tags.description
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddress
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddress
          networkSecurityGroup: {
            id: networkSecurityGroupName.id
          }
        }
      }
    ]
  }
}
