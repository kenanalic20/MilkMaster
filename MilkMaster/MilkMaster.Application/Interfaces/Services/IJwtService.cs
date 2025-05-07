using Microsoft.AspNetCore.Identity;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IJwtService
    {
        Task<string> GenerateJwtToken(IdentityUser user);
    }
}
