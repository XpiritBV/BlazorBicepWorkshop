# Club Cloud workshop


## Getting started

### Tools

- Install [Visual Studio Code](https://code.visualstudio.com/download) or [Visual Studio 2019/2022](https://visualstudio.microsoft.com/downloads/).  
- Install [.NET 6](https://dotnet.microsoft.com/download/dotnet/6.0)
- If you don't have an Azure Subscription, install [Azurite](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio#install-and-run-azurite) 

### Get or Create Project

#### Option 1 - Using your own environment

> Please note that this option will take you about 15 minutes to complete.

- Follow the [walkthrough](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant) to create a new Azure AD B2C Tenant.
- Follow the [walkthrough](https://docs.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/hosted-with-azure-active-directory-b2c?view=aspnetcore-6.0) to create the initial Blazor project.

#### Option 2 - Using our prepared 'Xpirit Insurance' demo environment

> This option will get you started quickly, but includes some manual work.

- Create a new folder to host the project. E.g. `d:\projects\clubcloud`
- Open a terminal and navigate to the folder. E.g. `cd d:\projects\clubcloud`
- Run this commmand to generate a skeleton project:

```
dotnet new blazorwasm -au IndividualB2C --aad-b2c-instance "https://xpiritinsurance.b2clogin.com/" --api-client-id "3b551417-548e-4e8e-80c3-44bb06f3aa64" --app-id-uri "3b551417-548e-4e8e-80c3-44bb06f3aa64" --client-id "e280fc38-2898-4fad-baaf-fbeb1d306bd1" --default-scope "API.Access" --domain "xpiritinsurance.onmicrosoft.com" -ho -o XpiritInsurance -ssp "B2C_1_UserFlowSuSi"
```

This will scaffold a new solution, configured to use the Xpirit Insurance demo Azure AD B2C environment.

##### Modify before running

1. Launch Settings

    Open the file `launchsettings.json` in the 'Server' project:

    ```
    code d:\projects\clubcloud\XpiritInsurance\Server\Properties\launchSettings.json
    ```

    Modify the `applicationUrl` value:

    ```json
    "applicationUrl": "https://localhost:7293;http://localhost:5088",
    ```

    into:
    ```json
    "applicationUrl": "https://localhost:5001;http://localhost:5000",
    ```

2. Program.cs
Open the file `Program.cs` in the 'Client project:

    ```
    code d:\projects\clubcloud\XpiritInsurance\Client\Program.cs
    ```

    Modify the `LoginMode` so users are redirected to login, instead of showing a pop-up window:

    Change:
    ```csharp
        builder.Services.AddMsalAuthentication(options =>
        {
            builder.Configuration.Bind("AzureAdB2C", options.ProviderOptions.Authentication);
            options.ProviderOptions.DefaultAccessTokenScopes.Add("https://xpiritinsurance.onmicrosoft.com/3b551417-548e-4e8e-80c3-44bb06f3aa64/API.Access");
        });
    ```
    into: 

    ```csharp
        builder.Services.AddMsalAuthentication(options =>
        {
            builder.Configuration.Bind("AzureAdB2C", options.ProviderOptions.Authentication);
            options.ProviderOptions.DefaultAccessTokenScopes.Add("https://xpiritinsurance.onmicrosoft.com/3b551417-548e-4e8e-80c3-44bb06f3aa64/API.Access");
            options.ProviderOptions.LoginMode = "redirect";
        });
    ```

3. Client Project file

    Modify the project file 'XpiritInsurance.Client.csproj' and exempt the reference `Microsoft.Authentication.WebAssembly.Msal' from trimming.

    Change the references from:
    ```xml
    <ItemGroup>
        <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly" Version="6.0.0-rc.1.21452.15" />
        <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly.DevServer" Version="6.0.0-rc.1.21452.15" PrivateAssets="all" />
        <PackageReference Include="Microsoft.Authentication.WebAssembly.Msal" Version="6.0.0-rc.1.21452.15" />
        <PackageReference Include="Microsoft.Extensions.Http" Version="6.0.0-rc.1.21451.13" />
    </ItemGroup>
    ```
    into:

    ```xml
    <ItemGroup>
        <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly" Version="6.0.0-rc.1.21452.15" />
        <PackageReference Include="Microsoft.AspNetCore.Components.WebAssembly.DevServer" Version="6.0.0-rc.1.21452.15" PrivateAssets="all" />
        <PackageReference Include="Microsoft.Authentication.WebAssembly.Msal" Version="6.0.0-rc.1.21452.15" />
        <TrimmerRootAssembly Include="Microsoft.Authentication.WebAssembly.Msal"  />
        <PackageReference Include="Microsoft.Extensions.Http" Version="6.0.0-rc.1.21451.13" />
    </ItemGroup>
    ```

4. API Controller Scopes

    In the 'Server' project, open the file ''.
    Change the attribute code from:

    ```csharp
    [RequiredScope(RequiredScopesConfigurationKey = "AzureAd:Scopes")]
    ```

    into:
    ```csharp
    [RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes")]
    ```

    In the same project change the configuration to define the required API scope. Modify the appsettings.json from:

    ```json
    {
    "AzureAdB2C": {
        "Instance": "https://xpiritinsurance.b2clogin.com/",
        "ClientId": "3b551417-548e-4e8e-80c3-44bb06f3aa64",
        "Domain": "xpiritinsurance.onmicrosoft.com",
        "SignUpSignInPolicyId": "B2C_1_UserFlowSuSi"
    },
    ```
    into
    ```json
    {
    "AzureAdB2C": {
        "Instance": "https://xpiritinsurance.b2clogin.com/",
        "ClientId": "3b551417-548e-4e8e-80c3-44bb06f3aa64",
        "Domain": "xpiritinsurance.onmicrosoft.com",
        "SignUpSignInPolicyId": "B2C_1_UserFlowSuSi",
        "Scopes": "API.Access"
    },
    ```
#### Option 3 - Using our prepared 'Xpirit Insurance' demo environment

The easiest option to get started is to run the source code included in this repo. It works straight out of the box.
You can find it in the `src` folder.

## Testing your code

### VS Code
- Open the terminal
- Navigate to the 'Server' project ``
- Run the project:

```
cd d:\projects\clubcloud\XpiritInsurance\Server

dotnet run
```

### Visual Studio
Start debugging by pressing F5 or select `Start debugging` from the `Debug` menu. Or select the option to run without debugging.

### Logging in
Create a test account in your own B2C environment, and attempt to log in. 
When using the Xpirit Insurance Demo B2C tenant, use one of these existing accounts to log in:

| User account | Password   |
|--------------|----------- |
| user01       | please ask |
| user02       | please ask |


## Publish your code locally

```
dotnet publish --configuration Release

Microsoft (R) Build Engine version 17.0.0-preview-21460-01+8f208e609 for .NET
Copyright (C) Microsoft Corporation. All rights reserved.

  Determining projects to restore...
  All projects are up-to-date for restore.
  You are using a preview version of .NET. See: https://aka.ms/dotnet-core-preview
  You are using a preview version of .NET. See: https://aka.ms/dotnet-core-preview
  XpiritInsurance.Shared -> d:\projects\clubcloud\XpiritInsurance\Shared\bin\Release\net6.0\XpiritInsurance.Shared.dll
  XpiritInsurance.Client -> d:\projects\clubcloud\XpiritInsurance\Client\bin\Release\net6.0\XpiritInsurance.Client.dll
  XpiritInsurance.Client (Blazor output) -> d:\projects\clubcloud\XpiritInsurance\Client\bin\Release\net6.0\wwwroot
  XpiritInsurance.Server -> d:\projects\clubcloud\XpiritInsurance\Server\bin\Release\net6.0\XpiritInsurance.Server.dll
  Optimizing assemblies for size, which may change the behavior of the app. Be sure to test after publishing. See: https://aka.ms/dotnet-illink
  Compressing Blazor WebAssembly publish artifacts. This may take a while...
  XpiritInsurance.Server -> d:\projects\clubcloud\XpiritInsurance\Server\bin\Release\net6.0\publish\
```
Copy the output folder name, output by the `publish` command.
Zip the output for simple deployment:

```
# Bash
zip -r package.zip \projects\clubcloud\XpiritInsurance\Server\bin\Release\net6.0\publish\

# PowerShell
Compress-Archive -Path d:\projects\clubcloud\XpiritInsurance\Server\bin\Release\net6.0\publish\* -DestinationPath package.zip -Force

```

# Summary
You have now completed this lab. Please go to the next lab, where you will learn how to provision the required Azure resources to run this modern web application in an Azure App Service.


