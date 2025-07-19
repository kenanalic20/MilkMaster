using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface ICattleService:IService<Cattle, CattleDto, CattleCreateDto, CattleUpdateDto, CattleQueryFilter, int>
    {
    }
}
