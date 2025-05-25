using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class UserDetailsService : BaseService<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, string>, IUserDetailsService
    {
        private readonly IUserDetailsRepository _userDetailsRepository;
        public UserDetailsService(IUserDetailsRepository userDetailsRepository, IMapper mapper) : base(userDetailsRepository, mapper)
        {
            _userDetailsRepository = userDetailsRepository;
        }
        public override async Task<UserDetailsDto> GetByIdAsync(string id)
        {
            var userDetails = await _userDetailsRepository.GetByIdAsync(id);

            return _mapper.Map<UserDetailsDto>(userDetails);
        }

        public override async Task<UserDetailsDto> CreateAsync(UserDetailsCreateDto dto, bool returnDto = true)
        {
            var exists = await _userDetailsRepository.ExistsAsync(dto.UserId);
            if (exists)
            {
                return null;
            }

            return await base.CreateAsync(dto, returnDto);
        }
    }
}
