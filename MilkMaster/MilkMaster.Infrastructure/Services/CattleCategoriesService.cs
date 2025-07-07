using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class CattleCategoriesService:BaseService<CattleCategories, CattleCategoriesDto, CattleCategoriesCreateDto, CattleCategoriesUpdateDto, int>, ICattleCategoriesService
    {
        private readonly ICattleCategoriesRepository _cattleCategoriesRepository;
        public CattleCategoriesService(ICattleCategoriesRepository cattleCategoriesRepository, IMapper mapper) : base(cattleCategoriesRepository, mapper)
        {
            _cattleCategoriesRepository = cattleCategoriesRepository;
        }
    }
 
}
