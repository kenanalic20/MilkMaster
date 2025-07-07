using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class CattleCategoriesMappingProfile:Profile
    {
        public CattleCategoriesMappingProfile() 
        { 
            CreateMap<CattleCategories, CattleCategoriesDto>();
            CreateMap<CattleCategoriesCreateDto, CattleCategories>();
            CreateMap<CattleCategoriesUpdateDto, CattleCategories>();
        }
    }
}
