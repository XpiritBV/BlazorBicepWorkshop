param serverFarmName string
param appServiceName string

@secure()
param storageConnectionString string

param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: serverFarmName
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      appSettings: [
        {
          name: 'storageAccountConnectionString'
          value: storageConnectionString
        }
      ]
    }
  }
   
  resource logs 'config@2021-01-15' = {
    name: 'logs'
    properties: {
      httpLogs: {
         fileSystem: {
           enabled: true
           retentionInDays: 2
           retentionInMb: 35
         }
      }
      detailedErrorMessages: {
        enabled: true
      }
      applicationLogs: {
        fileSystem: {
          level: 'Verbose'
        }
      }
      failedRequestsTracing: {
        enabled: true
      }
    }
  }
}
