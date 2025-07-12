using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Common;
using AutoMapper;
using System.Security.Claims;

namespace MilkMaster.Infrastructure.Services
{
    public class UserAddressService : BaseService<UserAddress, UserAddressDto, UserAddressCreateDto, UserAddressUpdateDto, string>, IUserAddressService
    {
        private readonly IUserAddressRepository _userAddressRepository;
        private readonly IAuthService _authService;

        public UserAddressService(
            IUserAddressRepository userAddressRepository,
            IMapper mapper,
            IAuthService authService
        ) : base(userAddressRepository, mapper)
        {
            _userAddressRepository = userAddressRepository;
            _authService = authService;
        }

        public async Task<UserAddressDto> GetByIdAsync(string id, ClaimsPrincipal user)
        {
            var userAddress = await _userAddressRepository.GetByIdAsync(id);

            if (userAddress == null)
                throw new KeyNotFoundException("Address not found");

            var isAdmin = await _authService.IsAdminAsync(user);
            var currentUserId = await _authService.GetUserIdAsync(user);

            if (!isAdmin && userAddress.UserId != currentUserId)
                throw new UnauthorizedAccessException("Forbidden");

            return _mapper.Map<UserAddressDto>(userAddress);
        }


        public override async Task<UserAddressDto?> CreateAsync(UserAddressCreateDto dto, bool returnDto = true)
        {
            var exists = await _userAddressRepository.ExistsAsync(dto.UserId);
            if (exists)
                throw new InvalidOperationException("User already has an address");

            var result = await base.CreateAsync(dto, returnDto);
            return result;
        }

    }
}
