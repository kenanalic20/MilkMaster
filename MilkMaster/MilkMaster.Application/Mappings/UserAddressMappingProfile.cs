using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class UserAddressMappingProfile:Profile
    {
        public UserAddressMappingProfile()
        {
            CreateMap<UserAddress, UserAddressDto>();
            CreateMap<UserAddressCreateDto, UserAddress>();
            CreateMap<UserAddressUpdateDto, UserAddress>();
        }
    }
}
