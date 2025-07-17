

using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface ICattleService:IService<Cattle, CattleDto, CattleCreateDto, CattleUpdateDto, int>
    {
    }
}
