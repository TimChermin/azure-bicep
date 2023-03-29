@description('Admin username for the Virtual Machine.')
param vmAdminUsername string

@description('Admin password for the Virtual Machine.')
@secure()
param vmAdminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param vmDnsName string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param vmDnsNameTwo string

@description('Unique Name for the Virtual Machine.')
param vmName string = 'nameformeone'

@description('Unique Name for the Virtual Machine.')
param vmNameTwo string = 'nameformetwo'

@description('Size of the Virtual Machine')
param vmSize string = 'Standard_D1_v2'

var diagnosticsOne = {
  storageAccount: {
    name: 'diagnostics${uniqueString(resourceGroup().id)}'
  }
}
var diagnosticsTwo = {
  storageAccount: {
    name: 'diagnostic${uniqueString(resourceGroup().id)}'
  }
}

var nameSpaceOne = 'One'
var nameSpaceTwo = 'Two'

var vnet = {
  name: 'plea-vnet'
  addressPrefix: '10.0.0.0/16'
  subnet: {
    name: 'plea-subnet'
    addressPrefix: '10.0.0.0/24'
  }
}

module networkModule 'modules/networkmodule.bicep' = {
  name: 'NetworkModule'
  params: {
    vnetName: vnet.name
    subnetName: vnet.subnet.name
    vnetAddress: vnet.addressPrefix
    subnetAddress: vnet.subnet.addressPrefix
  }
}

module vmModuleOne 'modules/vmmodule.bicep' = { 
  name: 'vmModuleOne'
  params: {
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmDnsName: vmDnsName
    vmSize: vmSize
    vnetName: vnet.name
    subnetName: vnet.subnet.name
    diagnostics: diagnosticsOne
    vmName: vmName
    nameSpace: nameSpaceOne
  }
  dependsOn:[
    networkModule
  ]
}

module vmModuleTwo 'modules/vmmodule.bicep' = { 
  name: 'vmModuleTwo'
  params: {
    vmAdminUsername: vmAdminUsername
    vmAdminPassword: vmAdminPassword
    vmDnsName: vmDnsNameTwo
    vmSize: vmSize
    vnetName: vnet.name
    subnetName: vnet.subnet.name
    diagnostics: diagnosticsTwo
    vmName: vmNameTwo
    nameSpace: nameSpaceTwo
  }
  dependsOn:[
    networkModule
    vmModuleOne
  ]
}
