param env string = 'tst'
param location string = 'westeurope'
param participantInitials string = 'es'

var storageAccountName = 'storblazor${env}${participantInitials}001'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'

  resource queueService 'queueServices@2021-04-01' = {
    name: 'default'

    resource queue 'queues@2021-04-01' = {
      name: 'insurance'
    }
  }
}

var serverFarmName = 'plan-blazor-${env}${participantInitials}-001'
resource appServicePlan 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: serverFarmName
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
}

var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${stg.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${stg.listKeys().keys[0].value}'

var appServiceName = 'app-blazor-${env}${participantInitials}-001'
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
