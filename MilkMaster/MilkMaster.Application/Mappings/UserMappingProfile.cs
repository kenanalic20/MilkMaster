using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class UserMappingProfile:Profile
    {
        public UserMappingProfile() 
        { 
            CreateMap<User, UserDto>();
        }
    }
}
