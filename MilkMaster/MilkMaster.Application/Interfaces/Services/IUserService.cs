using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserService
    {
        Task<PagedResult<UserDto>> GetAllUsersAsync(UserQueryFilter? filter);
        Task<UserDto?> GetByIdAsync(string userId);
        Task<bool> DeleteUserAsync(string userId);
        Task<bool> UpdateUserCredentialsAsync(string userId,UserAdminDto dto);
    }
}
