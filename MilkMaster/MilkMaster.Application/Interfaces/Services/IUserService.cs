using Microsoft.AspNetCore.Identity;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserService
    {
        Task<PagedResult<UserDto>> GetAllUsersAsync(UserQueryFilter? filter);
        Task<User?> GetByIdAsync(string userId);
        //Task DeleteUserAsync(string userId);

        //Task UpdateUserDetailsAsync(string userId, UserDetails updatedDetails);
        //Task UpdateUserAddressAsync(string userId, UserAddress updatedAddress);
    }
}
