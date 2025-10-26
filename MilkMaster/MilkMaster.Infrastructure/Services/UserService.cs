using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;
using MilkMaster.Infrastructure.Repositories;
using MilkMaster.Messages;


namespace MilkMaster.Infrastructure.Services
{
    public class UserService : IUserService
    {
        private readonly UserManager<User> _userManager;
        private readonly IUserDetailsRepository _userDetailsRepository;
        private readonly IUserAddressRepository _userAddressRepository;
        private readonly IMapper _mapper;
        private readonly IOrdersRepository _ordersRepository;
        private readonly ApplicationDbContext _context;
        private readonly IEmailService _emailService;
        private readonly ISettingsRepository _settingsRepository;
        public UserService(
            UserManager<User> userManager,
            IUserDetailsRepository userDetailsRepository,
            IUserAddressRepository userAddressRepository,
            IMapper mapper,
            IOrdersRepository ordersRepository,
            ApplicationDbContext context,
            IEmailService emailService,
            ISettingsRepository settingsRepository
        )
        {
            _userManager = userManager;
            _userDetailsRepository = userDetailsRepository;
            _userAddressRepository = userAddressRepository;
            _mapper = mapper;
            _ordersRepository = ordersRepository;
            _context = context;
            _emailService = emailService;
            _settingsRepository = settingsRepository;
        }
        public async Task<UserDto?> GetByIdAsync(string userId)
        {
            var user = await _userManager.Users.FirstOrDefaultAsync(u => u.Id == userId);
            if (user == null)
                return null;

            var userDto = _mapper.Map<UserDto>(user);

            var userDetails = await _userDetailsRepository.GetByIdAsync(user.Id);
            var userAddress = await _userAddressRepository.GetByIdAsync(user.Id);
            var orders = await _ordersRepository.GetByIdUserAsync(user.Id);

            if (orders.Any())
            {
                userDto.OrderCount = orders.Count();
                userDto.LastOrderDate = orders.Max(o => o.CreatedAt);
            }

            if (userDetails != null &&
                (!string.IsNullOrEmpty(userDetails.FirstName) || !string.IsNullOrEmpty(userDetails.LastName)))
            {
                userDto.CustomerName = $"{userDetails.FirstName} {userDetails.LastName}".Trim();
            }
            else
            {
                userDto.CustomerName = user.UserName;
            }

            userDto.Street = userAddress?.Street;
            userDto.ImageUrl = userDetails?.ImageUrl;

            return userDto;
        }

        public async Task<PagedResult<UserDto>> GetAllUsersAsync(UserQueryFilter? filter)
        {
            filter ??= new UserQueryFilter();
            var query = _context.Users
                        .Include(u => u.UserRoles)
                            .ThenInclude(ur => ur.Role)
                        .Where(u => u.UserRoles.Any(ur => ur.Role.Name == "User"))
                        .AsQueryable();

            

            var totalCount = await query.CountAsync();

            var users = await query.ToListAsync();

            var userDtos = _mapper.Map<List<UserDto>>(users);

            var userIds = users.Select(u => u.Id).ToList();

            var orderStatsAll = await _ordersRepository.GetAllAsync();
            var userDetailsAll = await _userDetailsRepository.GetAllAsync();
            var userAddressAll = await _userAddressRepository.GetAllAsync();

            foreach (var user in userDtos)
            {

                var stats = orderStatsAll.Where(o => o.UserId == user.Id && o.StatusId == 3);
                var userDetails = userDetailsAll.FirstOrDefault(ud => ud.UserId == user.Id);
                var userAddress = userAddressAll.FirstOrDefault(ua => ua.UserId == user.Id);


                if (userDetails == null || (string.IsNullOrEmpty(userDetails.FirstName) && string.IsNullOrEmpty(userDetails.LastName)))
                    user.CustomerName = user.UserName;
                else
                    user.CustomerName = $"{userDetails.FirstName} {userDetails.LastName}".Trim();
                var statsForUser = stats.ToList();
                if (statsForUser.Any())
                {
                    user.OrderCount = statsForUser.Count;
                    user.LastOrderDate = statsForUser.Max(o => o.CreatedAt);
                }
                user.Street = userAddress?.Street;

            }
            if (!string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                userDtos = userDtos.Where(u =>
                    (!string.IsNullOrEmpty(u.UserName) && u.UserName.ToLower().Contains(search)) ||
                    (!string.IsNullOrEmpty(u.CustomerName) && u.CustomerName.ToLower().Contains(search)) ||
                    (!string.IsNullOrEmpty(u.Street) && u.Street.ToLower().Contains(search))
                ).ToList();
            }
            IEnumerable<UserDto> sortedUsers = filter.OrderBy?.ToLower() switch
            {
                "date_asc" => userDtos.OrderBy(u => u.LastOrderDate),
                "date_desc" => userDtos.OrderByDescending(u => u.LastOrderDate),
                "order_asc" => userDtos.OrderBy(u => u.OrderCount),
                "order_desc" => userDtos.OrderByDescending(u => u.OrderCount),
                _ => userDtos.OrderBy(u => u.UserName)
            };
            var pagedUsers = sortedUsers
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToList();
            return new PagedResult<UserDto>
            {
                Items = pagedUsers,
                TotalCount = totalCount,
                PageNumber = filter?.PageNumber ?? 1
            };
        }

        public async Task<bool> UpdateUserCredentialsAsync(UserAdminDto dto)
        {
            var user = await _userManager.FindByIdAsync(dto.UserId);
            if (user == null)
                throw new KeyNotFoundException("User not found.");
            var oldEmail = user.Email;

            bool updated = false;

            if (!string.IsNullOrEmpty(dto.Email) && dto.Email != user.Email)
            {
                var token = await _userManager.GenerateChangeEmailTokenAsync(user, dto.Email);
                var result = await _userManager.ChangeEmailAsync(user, dto.Email, token);

                if (!result.Succeeded)
                    throw new InvalidOperationException($"Credential update failed");


                updated = true;
            }

            if (!string.IsNullOrEmpty(dto.Password))
            {
                var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
                var result = await _userManager.ResetPasswordAsync(user, resetToken, dto.Password);

                if (!result.Succeeded)
                    throw new InvalidOperationException($"Credential update failed");

                updated = true;
            }

            if (updated)
            {
                var messages = new List<EmailMessage>
                {
                    new EmailMessage
                    {
                        Email = dto.Email,
                        Subject = "Your Email Address Has Been Changed",
                        Body = $"Hello {user.UserName},\n\nYour account email has been changed to {dto.Email}."
                    },
                    new EmailMessage
                    {
                        Email = oldEmail,
                        Subject = "Your Account Email Was Updated",
                        Body = $"Hello {user.UserName},\n\nYour account email has been changed from {oldEmail} to {dto.Email}. If this wasn't you, please contact support immediately."
                    }
                };

                foreach (var emailMessage in messages)
                    await _emailService.SendEmailAsync(user.Id, emailMessage, skipSettingsCheck: true);
            }

            return updated;
        }

        public async Task<bool> DeleteUserAsync(string userId)
        {
            var user = await _userManager.FindByIdAsync(userId);
            if (user == null)
                throw new KeyNotFoundException("User not found.");
            var settings = await _settingsRepository.GetByIdAsync(userId);

            var result = await _userManager.DeleteAsync(user);
            if (!result.Succeeded)
                throw new InvalidOperationException($"Failed to delete user");

            if (!string.IsNullOrEmpty(user.Email))
            {
                var emailMessage = new EmailMessage
                {
                    Email = user.Email,
                    Subject = "Your Account Has Been Deleted",
                    Body = $"Hello {user.UserName},\n\nYour account has been permanently deleted by an administrator.\nIf you believe this was a mistake, please contact support."
                };

                await _emailService.SendEmailAsync(user.Id, emailMessage, skipSettingsCheck: true);
            }

            return true;
        }


    }
}
