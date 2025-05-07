using Microsoft.AspNetCore.Identity;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using System.Security.Claims;


namespace MilkMaster.Application.Interfaces.Services
{
    public interface IAuthService
    {
        Task<ServiceResponse<string>> RegisterAsync(RegisterDto register);
        Task<ServiceResponse<string>> LoginAsync(LoginDto login);
        Task<ServiceResponse<UserDetailsDto>> GetUserAsync(ClaimsPrincipal user);
    }
}
