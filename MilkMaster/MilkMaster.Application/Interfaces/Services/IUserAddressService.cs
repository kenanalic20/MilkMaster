using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;
using System.Security.Claims;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserAddressService:IService<UserAddress, UserAddressDto, UserAddressCreateDto, UserAddressUpdateDto, string>
    {
        Task<UserAddressDto> GetByIdAsync(string id, ClaimsPrincipal user);
    }
}
