using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;
using System.Security.Claims;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserAddressService:IService<UserAddress, UserAddressDto, UserAddressCreateDto, UserAddressUpdateDto, EmptyQueryFilter, string>
    {
        Task<UserAddressDto> GetByIdAsync(string id, ClaimsPrincipal user);
    }
}
