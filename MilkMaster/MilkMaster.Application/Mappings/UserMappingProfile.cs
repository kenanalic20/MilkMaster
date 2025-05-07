using AutoMapper;
using Microsoft.AspNetCore.Identity;
using MilkMaster.Application.DTOs;

namespace MilkMaster.Application.Mappings
{
    public class UserMappingProfile:Profile
    {
        public UserMappingProfile() 
        { 
            CreateMap<IdentityUser, UserDetailsDto>()
                .ForMember(dest => dest.UserName, opt => opt.MapFrom(src => src.UserName))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email));
        }
    }
}
