using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using System.Security.Claims;

namespace MilkMaster.Infrastructure.Services
{
    public class UserDetailsService : BaseService<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, EmptyQueryFilter, string>, IUserDetailsService
    {
        private readonly IUserDetailsRepository _userDetailsRepository;
        public readonly IAuthService _authService;

        public UserDetailsService(IUserDetailsRepository userDetailsRepository,IAuthService authService, IMapper mapper) : base(userDetailsRepository, mapper)
        {
            _userDetailsRepository = userDetailsRepository;
            _authService = authService;
        }

        public async Task<UserDetailsDto> GetByIdAsync(string id, ClaimsPrincipal user)
        {
            var userDetails = await _userDetailsRepository.GetByIdAsync(id);

            if (userDetails == null)
                throw new KeyNotFoundException("User details not found");

            var isAdmin = await _authService.IsAdminAsync(user);
            var currentUserId = await _authService.GetUserIdAsync(user);

            if (!isAdmin && userDetails.UserId != currentUserId)
                throw new UnauthorizedAccessException("Forbidden");

            return _mapper.Map<UserDetailsDto>(userDetails);
        }


        public override async Task<UserDetailsDto?> CreateAsync(UserDetailsCreateDto dto)
        {
            var exists = await _userDetailsRepository.ExistsAsync(dto.UserId);
            if (exists)
                throw new InvalidOperationException("User details already exist");

            return await base.CreateAsync(dto);
        }


    }
}
