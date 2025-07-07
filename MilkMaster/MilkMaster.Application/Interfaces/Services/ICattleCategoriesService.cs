using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface ICattleCategoriesService : IService<CattleCategories, CattleCategoriesDto, CattleCategoriesCreateDto, CattleCategoriesUpdateDto, int>  
    {
    }
}
