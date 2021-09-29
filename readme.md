# Club Cloud workshop


## Getting started

### Tools

- Install [Visual Studio Code](https://code.visualstudio.com/download) or [Visual Studio 2019/2022](https://visualstudio.microsoft.com/downloads/).  
- Install [.NET 6](https://dotnet.microsoft.com/download/dotnet/6.0)
- If you don't have an Azure Subscription, install [Azurite](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azurite?tabs=visual-studio#install-and-run-azurite) 

# Building the Application

## Option 1 - Using your own Azure AD B2C environment

> Please note that this option will take you about 15 minutes to complete.

- Follow the [walkthrough](https://docs.microsoft.com/en-us/azure/active-directory-b2c/tutorial-create-tenant) to create a new Azure AD B2C Tenant.
- Follow the [walkthrough](https://docs.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/hosted-with-azure-active-directory-b2c?view=aspnetcore-6.0) to create the initial Blazor project.

Continue with the steps from option 2.

## Option 2 - Using our 'Xpirit Insurance' demo Azure AD B2C environment

> This option will get you started quickly, but includes some manual work.

- Create a new folder to host the project. E.g. `d:\projects\clubcloud`
- Open a terminal and navigate to the folder. E.g. `cd d:\projects\clubcloud`
- Run this commmand to generate a skeleton project:

```
dotnet new blazorwasm -au IndividualB2C --aad-b2c-instance "https://xpiritinsurance.b2clogin.com/" --api-client-id "3b551417-548e-4e8e-80c3-44bb06f3aa64" --app-id-uri "3b551417-548e-4e8e-80c3-44bb06f3aa64" --client-id "e280fc38-2898-4fad-baaf-fbeb1d306bd1" --default-scope "API.Access" --domain "xpiritinsurance.onmicrosoft.com" -ho -o XpiritInsurance -ssp "B2C_1_UserFlowSuSi"
```

This will scaffold a new solution, configured to use the Xpirit Insurance demo Azure AD B2C environment.

### Required modifications

**1. Launch Settings**

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

**2. Program.cs**
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

**3. Client Project file**

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

**4. API Controller Scopes**

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

    > Your project should now compile and run without errors. Use `dotnet run` from the 'Server' project to ensure everything works.

### Adding custom code

**1. Adding custom code to the Web API**

    We will now change the scaffolded code, to create some insurance selling functionality.
    To do this, we will add a Web API controller that can serve insurance quotes, and be used to purchase & view insurances.

    Open the folder 'XpiritInsurance.Shared' and add these files:

    - Insurance.cs
        ```csharp
        namespace XpiritInsurance.Shared;
        public record Insurance(InsuranceType InsuranceType, decimal AmountPerMonth);
        ```
    - InsuranceType.cs
        ```csharp
        namespace XpiritInsurance.Shared;
        public enum InsuranceType { House, Boat, Health }
        ```
    - Quote.cs
        ```csharp
        namespace XpiritInsurance.Shared;
        public record Quote(string UserName, InsuranceType InsuranceType, decimal AmountPerMonth);
        ```

    Open the folder 'XpiritInsurance.Server' and add these files:

    - Controllers\InsuranceController.cs
        ```csharp
        using System.Net;
        using Microsoft.AspNetCore.Authorization;
        using Microsoft.AspNetCore.Mvc;
        using Microsoft.Identity.Web;
        using Microsoft.Identity.Web.Resource;
        using XpiritInsurance.Server.Services;
        using XpiritInsurance.Shared;

        namespace XpiritInsurance.Server.Controllers;

        [RequiredScope(RequiredScopesConfigurationKey = "AzureAdB2C:Scopes")]
        [ApiController]
        [Route("[controller]")]
        public class InsuranceController : ControllerBase
        {
            private readonly ILogger<InsuranceController> _logger;
            private readonly QuoteAmountService _quoteAmountService;
            private readonly InsuranceService _insuranceService;

            public InsuranceController(ILogger<InsuranceController> logger, QuoteAmountService quoteAmountService, InsuranceService insuranceService)
            {
                _logger = logger ?? throw new ArgumentNullException(nameof(logger));
                _quoteAmountService = quoteAmountService ?? throw new ArgumentNullException(nameof(quoteAmountService));
                _insuranceService = insuranceService ?? throw new ArgumentNullException(nameof(insuranceService));
            }

            [ProducesResponseType((int)HttpStatusCode.OK, Type = typeof(IEnumerable<Insurance>))]
            [HttpGet]
            public async Task<IActionResult> GetInsurances()
            {
                string userName = HttpContext.User.GetDisplayName();
                var insurances = await _insuranceService.GetInsurances(userName);
                return Ok(insurances);
            }

            [ProducesDefaultResponseType]
            [HttpPost]
            public async Task<IActionResult> BuyInsurance(Quote quote)
            {
                string userName = HttpContext.User.GetDisplayName();
                decimal amount = quote.AmountPerMonth;
                if (amount < 5 || amount > 150)
                {
                    amount = await _quoteAmountService.CalculateQuote(userName, quote.InsuranceType);
                }
                await _insuranceService.AddInsurance(quote with { UserName = userName, AmountPerMonth = amount });

                _logger.LogInformation("Sold insurance {InsuranceType} to user {UserName} for {AmountPerMonth}", quote.InsuranceType, userName, amount);
                return Ok();
            }

            [ProducesResponseType((int)HttpStatusCode.OK, Type = typeof(Quote))]
            [HttpGet("quote")]
            public async Task<IActionResult> CalculateQuote(InsuranceType insuranceType)
            {
                string userName = HttpContext.User.GetDisplayName();
                decimal amount = await _quoteAmountService.CalculateQuote(userName, insuranceType);

                return Ok(new Quote(userName, insuranceType, amount));
            }
        }
    ```

    > Create a folder named 'Services' in the root of the project. (So, at the same level of the 'Controllers' folder)
    > Add a Nuget Package reference to include 'Microsoft.Experimental.Collections':
    ```
    cd .\Server
    dotnet add package Microsoft.Experimental.Collections -v 1.0.6-e190117-3
    ```

    - Services\InsuranceService.cs
        ```csharp
        using Microsoft.Collections.Extensions;
        using XpiritInsurance.Shared;
        namespace XpiritInsurance.Server.Services;

        public class InsuranceService
        {
            private readonly MultiValueDictionary<string, Insurance> Data = new()
            {
                { "user 01", new Insurance(InsuranceType.Boat, 15) } //add some seed data
            };

            public Task<IReadOnlyCollection<Insurance>> GetInsurances(string userName)
            {
                IReadOnlyCollection<Insurance> result = Array.Empty<Insurance>();
                if (Data.TryGetValue(userName, out var insurances))
                {
                    result = insurances;
                }
                return Task.FromResult(result);
            }

            public virtual Task<IReadOnlyCollection<Insurance>> AddInsurance(Quote quote)
            {
                if (Data.TryGetValue(quote.UserName, out var insurances) && insurances.Any(i => i.InsuranceType == quote.InsuranceType))
                {
                    var existing = insurances.Single(i => i.InsuranceType == quote.InsuranceType);
                    var copy = existing with
                    {
                        AmountPerMonth = quote.AmountPerMonth
                    };
                    Data.Remove(quote.UserName, existing);
                }


                Data.Add(quote.UserName, new Insurance(quote.InsuranceType, quote.AmountPerMonth));
                return GetInsurances(quote.UserName);
            }
        }
        ```
    - Services\QuoteAmountService.cs
        ```csharp
        using XpiritInsurance.Shared;
        namespace XpiritInsurance.Server.Services;

        public class QuoteAmountService
        {
            public virtual Task<decimal> CalculateQuote(string userName, InsuranceType insuranceType)
            {
                decimal amount = 0M;
                switch (insuranceType)
                {
                    case InsuranceType.House:
                        amount = new Random().Next(30, 70);
                        break;
                    case InsuranceType.Boat:
                        amount = new Random(Guid.NewGuid().GetHashCode()).Next(5, 15);
                        break;
                    case InsuranceType.Health:
                        amount = new Random(Guid.NewGuid().GetHashCode()).Next(79, 150);
                        break;
                }

                return Task.FromResult<decimal>(amount);
            }
        }
        ```

#### Using our prepared 'Xpirit Insurance' demo environment

The easiest option to get started is to run the source code included in this repo. It works straight out of the box.
You can find it in the `src` folder. You can also use this as a reference if you get stuck somewhere.

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


