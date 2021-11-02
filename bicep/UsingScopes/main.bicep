targetScope = 'subscription'

param env string = 'tst'
param location string = 'westeurope'
param participantInitials string = 'es'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-blazorbicepworkshop-${env}${participantInitials}-001'
  location: location
}

var storageAccountName = 'storblazor${env}${participantInitials}002'

module stg 'storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

var serverFarmName = 'plan-blazor-${env}${participantInitials}-001'
var appServiceName = 'app-blazor-${env}${participantInitials}-001'

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
