using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Common;
using System.Threading.Tasks;
using MilkMaster.Infrastructure.Repositories;
using System.Security.Claims;

namespace MilkMaster.Infrastructure.Services
{
    public class UserDetailsService : BaseService<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, string>, IUserDetailsService
    {
        private readonly IUserDetailsRepository _userDetailsRepository;
        public readonly IAuthService _authService;

        public UserDetailsService(IUserDetailsRepository userDetailsRepository, IMapper mapper) : base(userDetailsRepository, mapper)
        {
            _userDetailsRepository = userDetailsRepository;
        }

        public async Task<ServiceResponse<UserDetailsDto>> GetByIdAsync(string id, ClaimsPrincipal user)
        {
            var userAddress = await _userDetailsRepository.GetByIdAsync(id);

            if (userAddress == null)
                return ServiceResponse<UserDetailsDto>.FailureResponse("Address not found", 404);

            var isAdmin = await _authService.IsAdminAsync(user);
            var currentUserId = await _authService.GetUserIdAsync(user);

            if (!isAdmin && userAddress.UserId != currentUserId)
                return ServiceResponse<UserDetailsDto>.FailureResponse("Forbidden", 403);

            var dto = _mapper.Map<UserDetailsDto>(userAddress);
            return ServiceResponse<UserDetailsDto>.SuccessResponse(dto);
        }

        public override async Task<ServiceResponse<UserDetailsDto>> CreateAsync(UserDetailsCreateDto dto, bool returnDto = true)
        {
            var exists = await _userDetailsRepository.ExistsAsync(dto.UserId);
            if (exists)
            {
                return ServiceResponse<UserDetailsDto>.FailureResponse("User details already exist", 400);
            }

            var baseResponse = await base.CreateAsync(dto, returnDto);
            return ServiceResponse<UserDetailsDto>.SuccessResponse(baseResponse.Data, "User details created successfully");
        }

    }
}
