using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IUserDetailsService:IService<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, string>
    {
    }
}
