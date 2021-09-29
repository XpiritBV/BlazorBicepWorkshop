using System.Net;
using Azure.Storage.Queues;
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
    private readonly QueueClient? _queueClient;

    public InsuranceController(ILogger<InsuranceController> logger, QuoteAmountService quoteAmountService, InsuranceService insuranceService, QueueClient? queueClient)
    {
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
        _quoteAmountService = quoteAmountService ?? throw new ArgumentNullException(nameof(quoteAmountService));
        _insuranceService = insuranceService ?? throw new ArgumentNullException(nameof(insuranceService));
        _queueClient = queueClient;
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
        var insurance = await _insuranceService.AddInsurance(quote with { UserName = userName, AmountPerMonth = amount });
        if (_queueClient != null)
        {
            await _queueClient.SendMessageAsync(System.Text.Json.JsonSerializer.Serialize(insurance));
        }
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

