@description('Admin username for the Virtual Machine.')
param vmAdminUsername string

@description('Admin password for the Virtual Machine.')
@secure()
param vmAdminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param vmDnsName string

param vmName string

@description('Size of the Virtual Machine')
param vmSize string = 'Standard_D2_v2'
param diagnostics object

param nameSpace string

param vnetName string
param subnetName string

var location = resourceGroup().location
var tags = {
  vendor: 'Testing Things'
  description: 'Example deployment Windows Server.'
}

var publicIPAddressNamevar = '${nameSpace}-publicip'
var nic = {
  name: '${nameSpace}-nic'
  ipConfigName: '${nameSpace}-ipconfig'
}

resource diagnostics_storageAccount_name 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: diagnostics.storageAccount.name
  location: location
  tags: {
    vendor: tags.vendor
    description: tags.description
  }
  kind: 'Storage'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
  }
}


resource publicIPAddressName 'Microsoft.Network/publicIPAddresses@2022-09-01' = {
  name: publicIPAddressNamevar
  location: location
  tags: {
    vendor: tags.vendor
    description: tags.description
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: vmDnsName
    }
  }
}



resource nic_name 'Microsoft.Network/networkInterfaces@2022-09-01' = {
  name: nic.name
  location: location
  tags: {
    vendor: tags.vendor
    description: tags.description
  }
  properties: {
    ipConfigurations: [
      {
        name: nic.ipConfigName
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddressName.id
          }
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName) //'${vnetNameId}/subnets/${subnetName}'
          }
        }
      }
    ]
  }
  dependsOn: [
  ]
}

resource vm 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: vmName
  location: location
  tags: {
    vendor: tags.vendor
    description: tags.description
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Standard_LRS' //StandardSSD_LRS
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', nic_name.name)//nic_name.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: diagnostics_storageAccount_name.properties.primaryEndpoints.blob
      }
    }
  }
  dependsOn: [
  ]
}

