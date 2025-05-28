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

        public async Task<ServiceResponse<UserAddressDto>> GetByIdAsync(string id, ClaimsPrincipal user)
        {
            var userAddress = await _userAddressRepository.GetByIdAsync(id);

            if (userAddress == null)
                return ServiceResponse<UserAddressDto>.FailureResponse("Address not found", 404);

            var isAdmin = await _authService.IsAdminAsync(user);
            var currentUserId = await _authService.GetUserIdAsync(user);

            if (!isAdmin && userAddress.UserId != currentUserId)
                return ServiceResponse<UserAddressDto>.FailureResponse("Forbidden", 403);

            var dto = _mapper.Map<UserAddressDto>(userAddress);
            return ServiceResponse<UserAddressDto>.SuccessResponse(dto);
        }

        public override async Task<ServiceResponse<UserAddressDto>> CreateAsync(UserAddressCreateDto dto, bool returnDto = true)
        {
            var exists = await _userAddressRepository.ExistsAsync(dto.UserId);
            if (exists)
            {
                return ServiceResponse<UserAddressDto>.FailureResponse("User already has an address", 400);
            }

            var baseResponse = await base.CreateAsync(dto, returnDto);
            return ServiceResponse<UserAddressDto>.SuccessResponse(baseResponse.Data, "Address created successfully");
        }
    }
}
