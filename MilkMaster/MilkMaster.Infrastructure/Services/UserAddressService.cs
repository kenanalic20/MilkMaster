using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Application.Interfaces.Repositories;
using AutoMapper;
using System.Security.Claims;
using MilkMaster.Application.Common;

namespace MilkMaster.Infrastructure.Services
{
    public class UserAddressService:BaseService<UserAddress, UserAddressDto, UserAddressCreateDto, UserAddressUpdateDto, string>, IUserAddressService
    {
        private readonly IUserAddressRepository _userAddressRepository;
        private readonly IAuthService _authService;
        public UserAddressService(IUserAddressRepository userAddressRepository, IMapper mapper, IAuthService authService) : base(userAddressRepository, mapper)
        {
            _userAddressRepository = userAddressRepository;
            _authService = authService;
        }
        public async Task<ServiceResponse<UserAddressDto>> GetByIdAsync(string id, ClaimsPrincipal user)
        {
            var isAdmin = await _authService.IsAdminAsync(user);
            var currentUserId = await _authService.GetUserIdAsync(user);

            var userAddress = await _userAddressRepository.GetByIdAsync(id);

            if (userAddress == null)
                return ServiceResponse<UserAddressDto>.FailureResponse("Address not found", 404); ;

            if (!isAdmin && userAddress.UserId != currentUserId)
                return ServiceResponse<UserAddressDto>.FailureResponse("Forbidden", 403);

            var dto = _mapper.Map<UserAddressDto>(userAddress);

            return ServiceResponse<UserAddressDto>.SuccessResponse(dto);
        }
        public override async Task<UserAddressDto> CreateAsync(UserAddressCreateDto dto, bool returnDto = true)
        {
            var exists = await _userAddressRepository.ExistsAsync(dto.UserId);
            if (exists)
            {
                return null;
            }

            return await base.CreateAsync(dto, returnDto);
        }
    }
}
