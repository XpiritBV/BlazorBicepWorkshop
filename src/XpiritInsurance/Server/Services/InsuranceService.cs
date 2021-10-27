using Microsoft.Collections.Extensions;
using XpiritInsurance.Shared;
namespace XpiritInsurance.Server.Services;

public class InsuranceService
{
    private readonly MultiValueDictionary<string, Insurance> Data = new()
    {
        { "user 01", new Insurance(InsuranceType.Boat, 15) },
        { "user 02", new Insurance(InsuranceType.House, 50) }
        //add some seed data
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

    public virtual Task<Insurance> AddInsurance(Quote quote)
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


        Insurance insurance = new Insurance(quote.InsuranceType, quote.AmountPerMonth);
        Data.Add(quote.UserName, insurance);
        return Task.FromResult(insurance);
    }
}
