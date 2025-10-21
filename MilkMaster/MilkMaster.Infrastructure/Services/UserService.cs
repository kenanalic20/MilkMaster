using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;


namespace MilkMaster.Infrastructure.Services
{
    public class UserService:IUserService
    {
        private readonly UserManager<User> _userManager;
        private readonly IUserDetailsRepository _userDetailsRepository;
        private readonly IUserAddressRepository _userAddressRepository;
        private readonly IMapper _mapper;
        private readonly IOrdersRepository _ordersRepository;
        private readonly ApplicationDbContext _context;
        public UserService(
            UserManager<User> userManager,
            IUserDetailsRepository userDetailsRepository,
            IUserAddressRepository userAddressRepository,
            IMapper mapper,
            IOrdersRepository ordersRepository,
            ApplicationDbContext context

        )
        {
            _userManager = userManager;
            _userDetailsRepository = userDetailsRepository;
            _userAddressRepository = userAddressRepository;
            _mapper = mapper;
            _ordersRepository = ordersRepository;
            _context = context;
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
            var query = from u in _context.Users
                        join ur in _context.UserRoles on u.Id equals ur.UserId
                        join r in _context.Roles on ur.RoleId equals r.Id
                        where r.Name == "User"
                        select u;

            if (filter != null && !string.IsNullOrEmpty(filter.Search))
            {
                var search = filter.Search.ToLower();
                query = query.Where(u =>
                    u.UserName.ToLower().Contains(search.ToLower()) ||
                    u.Email.ToLower().Contains(search.ToLower()) ||
                    u.PhoneNumber.ToLower().Contains(search.ToLower()));
            }

            if (filter != null && !string.IsNullOrEmpty(filter.OrderBy))
            {
                switch (filter.OrderBy.ToLower())
                {
                    case "date_asc":
                        query = query.OrderBy(u => u.LastOrderDate);
                        break;
                    case "date_desc":
                        query = query.OrderByDescending(u => u.LastOrderDate);
                        break;
                    case "order_asc":
                        query = query.OrderBy(u => u.OrderCount);
                        break;
                    case "order_desc":
                        query = query.OrderByDescending(u => u.OrderCount);
                        break;
                    default:
                        query = query.OrderBy(u => u.UserName);
                        break;
                }
            }
            else
            {
                query = query.OrderBy(u => u.UserName);
            }

            var totalCount = await query.CountAsync();

            var users = await query
                .Skip((filter.PageNumber - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .ToListAsync();

            var userDtos = _mapper.Map<List<UserDto>>(users);

            var userIds = users.Select(u => u.Id).ToList();

            var orderStatsAll = await _ordersRepository.GetAllAsync();
            var userDetailsAll = await _userDetailsRepository.GetAllAsync();
            var userAddressAll = await _userAddressRepository.GetAllAsync();

            foreach (var user in userDtos)
            {

                var stats = orderStatsAll.Where(o => o.UserId == user.Id && o.StatusId==3);
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

            return new PagedResult<UserDto>
            {
                Items = userDtos,
                TotalCount = totalCount,
                PageNumber = filter?.PageNumber ?? 1
            };
        }

    }
}
