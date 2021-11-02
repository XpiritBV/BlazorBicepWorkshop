# Lab 3 - Bicep 101

In this lab, you will learn the basics of Bicep, create a few resources and deploy them to Azure.

Goals for this lab: 
- [Creating the Queue](#queue)
- [Add the Azure App Service](#appservice)
- [Optionally add logging to your Azure App Service](#appservicelogging)
- [Publish your code to Azure](#publishcode)

## Prerequisites
Make sure you have completed [Lab 2 - Building a modern web application using Blazor](Lab2-Blazor.md)
This lab also requires some basic knowledge about these common Azure services.
- [Azure Storage Accounts](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview) 
- [Azure Queue Storage](https://docs.microsoft.com/en-us/azure/storage/queues/storage-queues-introduction)
- [Azure App Service](https://azure.microsoft.com/en-us/services/app-service)

## <a name="queue"></a> Creating the Queue
This workshop uses an Azure Storage Queue as its messaging service. That requires us to create an Azure Storage Account. 

Create a new file called main.bicep. The Bicep VS Code extension that you installed can help create resources as it provides a lot of snippets. Type 'stor' and the extension should provide you with a snippet.

![](media/storageaccountsnippet.png)

Hitting enter will insert a default template for a storage account. You can now use the tab key to move over the highlighted areas and modify them.

![](media/storageaccountsnippetinserted.png)

Notice how the extension also lists the available options for, for example, the 'kind'.

![](media/extensionlist.png)

The end result should look like the example below:
```arm

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'mystorageaccount'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
```

The name of the storage account is now hardcoded. That is not ideal since you want to use this template for both your test and production environment. The names of resources should reflect that. In Bicep, you can use a parameter to provide values, like the environment, at runtime. 

Defining one looks like this:

```arm
param env string = 'tst'
```
You start with the keyword 'param', then give it a name and define its type. Optionally, you can set a default value like the 'tst' above. The same can be done for the location property of the storage account. To ensure that every participant creates a unique name for the resources created throughout this lab, we add another parameter called 'participantInitials'.

The parameters now look like this:
```arm
param env string = 'tst'
param location string = 'westeurope'
param participantInitials string = 'es'
```

Next to parameters, we can use variables for values that you want to reuse across your templates. Creating a variable that holds the name of the storage account could look like this:
```arm
var storageAccountName = 'storblazor${env}${participantInitials}001'
```

The result of using both parameters and a variable is shown below:
```arm
param env string = 'tst'
param location string = 'westeurope'

var storageAccountName = 'storblazor${env}${participantInitials}001'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}
```
## <a name="queue"></a> Deploy the Storage Account
To deploy the storage account, you first need a resource group. Later in this lab, you will see how to create that using Bicep when we explore Bicep modules. For now, let's create it using the Azure CLI.
```
az group create -l westeurope -n rg-blazorbicepworkshop-tst-001
```

Now that your resource group is ready, you can deploy the template using the command below:
```
az deployment group create --resource-group rg-blazorbicepworkshop-tst-001 --template-file main.bicep
```
When you do not provide values for the parameters, the defaults in the template will be used. The following command shows an example of how to give a parameter while deploying the template.
```
az deployment group create --resource-group rg-blazorbicepworkshop-tst-001 \
    --template-file main.bicep  \
    --parameters '{ \"env\": { \"value\": \"prd\" } }'
```

Now open the Azure portal and verify that the storage account has been created.

## Adding the Queue on the storage account
Bicep allows you to write your infrastructure in a declarative way. That means that when you deploy your template, the Azure Resource Manager will figure out how to go from to current state into the state you describe in your template without you explicitly describing the steps. A deployment is also idempotent. That means that you can deploy the same template multiple times, and the outcome is always the same.

Now that we have defined and deployed the Storage Account, it is time to add the queue. Keeping the above in mind, we can simply add to the template we just created and deploy that again.

Adding a queue to a storage account means you first enable the Queue Services feature and create a queue. For both of those services, there is no built-in snippet available. The extension in VS Code is still handy to create both services.

The `QueueService` is a child resource of the Storage Account, so you define it within the storage account resource. To create the `QueueService`, start typing 'resource queueService que' within the storage account resource as shown below.
![](media/queueService.png)
As you can see, the extension helps to select the right resource and version. Hit enter and add an '=' to the line. As shown below, the extension again helps you by offering a few options. 

![](media/queueServiceRequiredProperties.png)
Selecting 'required-properties' will finish the resource by adding all properties that need a value. The name of the `QueueService` always needs to be 'default', so make that it's name. The `Queue` is a child resource of the `QueueService` and can be added similarly. The result should resemble the below template:

```arm
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
```
Deploy your template again using the same command you previously used to deploy it:
```
az deployment group create --resource-group rg-blazorbicepworkshop-tst-001 --template-file main.bicep
```

Navigate to your storage account in the Azure Portal and verify that your queue has been created.
## <a name="appservice"></a> Add the Azure App Service
The Blazor app you have built in the previous lab will run on an Azure App Service. It consists of two resources; an App Service Plan and an App Service. An App Service Plan defines a set of compute resources. On top of the plan, you run one or more App Services that share the compute resources.

### <a name="appservice"></a> App Service Plan
To create the Plan, type 'plan' and select 'res-app-plan'. Change the sku to 'B1' and give it a name. The resource should be similar to this example:
```arm
var serverFarmName = 'plan-blazor-${env}${participantInitials}-001'

resource appServicePlan 'Microsoft.Web/serverfarms@2019-08-01' = {
  name: serverFarmName
  location: location
  sku: {
    name: 'B1'
    capacity: 1
  }
}
```

Deploy your template using the following command:
```
az deployment group create --resource-group rg-blazorbicepworkshop-tst-001 --template-file main.bicep
```

Go back to the Azure Portal and verify that your App Service Plan has been created.

### <a name="appservice"></a> App Service
Creating the App Service is done using the 'res-web-app' snippet. Notice how the `serverFarmId` property is used to link this App Service to the plan you just created. There is one addition that you need to make to this template. Within the `properties` section, you need to add the required .NET Framework version. The Blazor app requires .NET 6 but as this is not the default value, you need to explicitly set it. The template should then resemble the below example:

```arm
var appServiceName = 'app-blazor-${env}${participantInitials}-001'
resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
  name: appServiceName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    
    siteConfig: {
      netFrameworkVersion: 'v6.0'
    }
  }
}
```
Deploy your template using the following command:
```
az deployment group create --resource-group rg-blazorbicepworkshop-tst-001 --template-file main.bicep
```
Open the Azure Portal and verify that your App Service has been created and is linked with the App Service Plan.

### <a name="appservice"></a> App Service Configuration
Remember how the Blazor app used an environment variable to get the connection information for the Storage Account Queue? Using Bicep, you can set these values as settings on your App Service while deploying it. To do that, add the appSettings property to the `siteConfig` section like this:

```
siteConfig: {
      netFrameworkVersion: 'v6.0'
      appSettings: [ ]
    }
```

The `appSettings` property is an array and allows for multiple key-value pairs to be inserted. In this lab, you only need one for the Storage Account connection string. Using Bicep, you can create a variable to construct it:

```arm
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${stg.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${stg.listKeys().keys[0].value}'
```
Notice how this line uses a reference to the Storage Account using the 'stg' object to get its name. It also uses the `.listKeys()` function to get an account key. Last but not least, it uses the `environment()` function to get the storage account base URL.

Below you will find the template containing the 'storageConnectionString' variable that is used in the appSettings array:

```arm
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
}
```
> WARNING: for the sake of simplicity, you have now set the connection string as a setting on the App Service. In a real-life scenario, that is not an option since that connection string will then be readable in plain-text in, for example, the Azure Portal. It's better to store this secret in Key Vault, or use a Managed Identity instead.

Deploy your template using the following command:
```
az deployment group create --resource-group rg-blazorbicepworkshop-tst-001 --template-file main.bicep
```
Open the Azure Portal and verify that the setting is deployed on the App Service.
## <a name="appservicelogging"></a> Optionally add logging to your Azure App Service
To make your life a little easier while debugging your app on Azure, you could add the following resource to your template to enable logging on the App Service. It is a child resource, and you will need to place it within the curly braces that describe your App Service Plan as shown below:
```arm
resource webApplication 'Microsoft.Web/sites@2018-11-01' = {
    name: appServiceName
    ...
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
  ```

## <a name="publishcode"></a> Publish your code to Azure

Copy the packaged Blazor app from the 'publish' folder to the current directory, and publish it to your App Service Plan by using these commands:

```
copy D:\Projects\clubcloud\XpiritInsurance\Server\bin\Release\net6.0\publish\package.zip .
az webapp deploy --resource-group rg-blazorbicepworkshop-tst-001 --name app-blazor-tst-001 --src-path package.zip
```

You should now be able to navigate to your app, log in, and buy a new insurance policy!

## Modularize your Bicep template
While you keep adding resources into the main.bicep file, you might notice it gets bigger and bigger. Eventually, it will get harder to read and maintain, and the template is not reusable. Luckily, Bicep has the concept of modules. Modules allow you to break up your template into smaller, reusable parts. Let's modularize the template you've build so far.

### The resource group
Start by creating a new folder and create a new main.bicep in it. The first thing we're going to do now is create the resource group you previously created using the Azure CLI, but now using Bicep.

Add the following snippet to the main.bicep to create the resource group:
```arm
param env string = 'tst'
param location string = 'westeurope'
param participantInitials string = 'es'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-blazorbicepworkshop-${env}${participantInitials}-001'
  location: location
}
```
Now you've done that, you will see that VS Code will show an error on the above new resource. By default, a bicep template is deployed at the scope of a resource group. You cannot create a resource group within a resource group, and thus you get the error. You will deploy this template at the scope of a subscription, so you need to add the following line to the top of the main.bicep:

```arm
targetScope = 'subscription'
```
The above line will indicate that you mean to deploy this template at the subscription scope.

### Storage Account
Create a new template in the same directory as the main.bicep and call it storage.bicep. Copy the storage account resource into it. You will notice that you now miss two parameters. Add them to the file as well. Your storage.bicep should look like this:

```arm
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
```
Last but not least, you need to return the connection string to the storage account because that needs to be set as a parameter on the App Service. To do that, you can declare an output in Bicep, as shown here. Add this to the storage.bicep file.

```arm
var storageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${stg.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${stg.listKeys().keys[0].value}'

output storageConnectionString string = storageConnectionString
```
> WARNING: The output above returns the connection string in plain text as there is no way in Bicep to do this securely. In a real-life scenario, that is not an option since that connection string will then be readable in plain text in, for example, the Azure DevOps pipeline or on the command line. It's better to store this secret in Key Vault, or use a Managed Identity instead.

### Using the storage module
Open main.bicep. You will now use the above-created module on the lines where the storage account used to be defined. To do that, you use the 'module' keyword instead of the 'resource' keyword. You give it a name like you would while using the 'resource' keyword. Instead of specifying a type, you now reference the just created module using its path. Start typing 'module stg ', and VS Code should show you all available modules. Select the storage account you just created. Type '=' and then select the 'required-properties' option in the drop-down. The generated snippet should look like this:
```arm
module stg 'storage.bicep' = {
  scope: 
  name: 
  params: {
    location: 
    storageAccountName: 
  }
}
```
On the first line in that module, you find 'scope'. That is where you get to define in which scope this module should be deployed. Remember that the main.bicep template targets the subscription scope, but a storage account can only be deployed within a resource group. This scope property allows you to set it. You simply do that by using the name of the resource group you declared earlier like so:
```arm
module stg 'storage.bicep' = {
  scope: rg
  name: 
  params: {
    location: 
    storageAccountName: 
  }
}
```
You need to give the module a name, and you see that the module requires a few parameters. Supply the values using the parameters in the main.bicep. The complete module definition is shown below:
```arm
module stg 'storage.bicep' = {
  scope: rg
  name: 'storage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}
```

### App Service and App Service Plan
Just like the storage account, we're going to create a module for the App Service and its App Service Plan. Create a file called appService.bicep and move all App Service related resources from the old main.bicep into this file. As with the storage module, you need to create a few parameters in this module. The appService module should look like the template below:

```arm
param serverFarmName string
param appServiceName string

@secure()
param storageConnectionString string

param location string

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

```
### Using the storage module
Using the App Service Module is similar to using the one for the storage account. Add the following snippet to main.bicep:
```arm
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
```
Have a look at the line where you give a value for the 'storageConnectionString'. The output from the storage module is used there. In Bicep, that is done by referencing the module's name, using the '.' notation to get its outputs, and selecting the correct output.

### Deploy
Deploying this template is slightly different from what you have done so far using the old main.bicep. Since we now target the subscription scope, you need to specify that in the command. The command now becomes:
```
az deployment sub create --template-file main.bicep -l westeurope
```
Notice that instead of 'group' you now use 'sub' to indicate the different deployment scope. When you now run the command, it should succeed, and the result in Azure should be the same.