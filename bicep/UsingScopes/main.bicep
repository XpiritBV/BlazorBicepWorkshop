targetScope = 'subscription'

param env string = 'tst'
param location string = 'westeurope'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-blazorbicepworkshop-${env}-001'
  location: location
}

var storageAccountName = 'storblazor${env}001'

module stg 'storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

var serverFarmName = 'plan-blazor-${env}-001'
var appServiceName = 'app-blazor-${env}-001'

module appService 'appService.bicep' = {
  scope: rg
  name: 'appService'
  params: {
    serverFarmName: serverFarmName
    appServiceName: appServiceName
    storageConnectionString: stg.outputs.storageConnectionString
  }
}
