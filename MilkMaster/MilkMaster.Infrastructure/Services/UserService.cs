using AutoMapper;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
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
        public UserService(
            UserManager<User> userManager,
            IUserDetailsRepository userDetailsRepository,
            IUserAddressRepository userAddressRepository,
            IMapper mapper,
            IOrdersRepository ordersRepository

        )
        {
            _userManager = userManager;
            _userDetailsRepository = userDetailsRepository;
            _userAddressRepository = userAddressRepository;
            _mapper = mapper;
            _ordersRepository = ordersRepository;
        }
        public async Task<PagedResult<UserDto>> GetAllUsersAsync(UserQueryFilter? filter)
        {
            filter ??= new UserQueryFilter();
            var query = _userManager.Users.AsQueryable();

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

            foreach (var user in userDtos)
            {
                var orderStats = await _ordersRepository.GetByIdUserAsync(user.Id);
                var userDetails = await _userDetailsRepository.GetByIdAsync(user.Id);
                var userAddress = await _userAddressRepository.GetByIdAsync(user.Id);

                var stats = orderStats.FirstOrDefault();

                if (stats != null)
                {
                    if (userDetails == null || (string.IsNullOrEmpty(userDetails.FirstName) && string.IsNullOrEmpty(userDetails.LastName)))
                        user.CustomerName = user.UserName;
                    else
                        user.CustomerName = $"{userDetails.FirstName} {userDetails.LastName}".Trim();
                    user.OrderCount = orderStats.Count();
                    user.LastOrderDate = stats.CreatedAt;
                    user.Street = userAddress?.Street;
                }
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
