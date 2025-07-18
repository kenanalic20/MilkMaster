using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface ICattleCategoriesService : IService<CattleCategories, CattleCategoriesDto, CattleCategoriesCreateDto, CattleCategoriesUpdateDto, CattleCategoriesQueryFilter, int>  
    {
    }
}
