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
