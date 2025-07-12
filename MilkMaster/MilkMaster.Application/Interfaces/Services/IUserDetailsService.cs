using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;
using System.Security.Claims;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserDetailsService:IService<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, string>
    {
        Task<UserDetailsDto> GetByIdAsync(string id, ClaimsPrincipal user);
    }
}
