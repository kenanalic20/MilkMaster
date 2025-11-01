using MilkMaster.Application.DTOs;
using System.Security.Claims;


namespace MilkMaster.Application.Interfaces.Services
{
    public interface IAuthService
    {
        Task<string> RegisterAsync(RegisterDto register);
        Task<string> LoginAsync(LoginDto login);
        Task<UserAuthDto> GetUserAsync(ClaimsPrincipal user);
        Task<string> GetUserIdAsync(ClaimsPrincipal user);
        Task<bool> IsAdminAsync(ClaimsPrincipal user);
    }
}
