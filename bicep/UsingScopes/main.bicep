targetScope = 'subscription'

param env string = 'tst'
param location string = 'westeurope'
param participantNumber string = '001'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-blazorbicepworkshop-${env}-${participantNumber}'
  location: location
}

var storageAccountName = 'storblazor${env}${participantNumber}'

module stg 'storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

var serverFarmName = 'plan-blazor-${env}-${participantNumber}'
var appServiceName = 'app-blazor-${env}-${participantNumber}'

module appService 'appService.bicep' = {
  scope: rg
  name: 'appService'
  params: {
    serverFarmName: serverFarmName
    appServiceName: appServiceName
    location: location
    storageConnectionString: stg.outputs.storageConnectionString
  }
}
