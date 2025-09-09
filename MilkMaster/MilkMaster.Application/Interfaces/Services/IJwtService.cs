using Microsoft.AspNetCore.Identity;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IJwtService
    {
        Task<string> GenerateJwtToken(User user);
    }
}
