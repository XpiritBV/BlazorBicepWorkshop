param storageAccountName string
param location string

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
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

var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${stg.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${stg.listKeys().keys[0].value}'

output storageConnectionString string = storageConnectionString
