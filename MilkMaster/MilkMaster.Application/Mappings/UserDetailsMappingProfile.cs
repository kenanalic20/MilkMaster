using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;


namespace MilkMaster.Application.Mappings
{
    public class UserDetailsMappingProfile:Profile
    {
        public UserDetailsMappingProfile()
        {
            CreateMap<UserDetails, UserDetailsDto>();
            CreateMap<UserDetailsCreateDto, UserDetails>();
            CreateMap<UserDetailsUpdateDto, UserDetails>();
        }
    }
}
