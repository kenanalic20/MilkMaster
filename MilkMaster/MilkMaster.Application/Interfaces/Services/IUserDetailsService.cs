using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;
using System.Security.Claims;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserDetailsService:IService<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, EmptyQueryFilter,string>
    {
        Task<UserDetailsDto> GetByIdAsync(string id, ClaimsPrincipal user);
    }
}
