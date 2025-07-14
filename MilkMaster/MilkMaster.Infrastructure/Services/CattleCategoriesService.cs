using AutoMapper;
using Microsoft.AspNetCore.Http;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Exceptions;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Infrastructure.Repositories;

namespace MilkMaster.Infrastructure.Services
{
    public class CattleCategoriesService:BaseService<CattleCategories, CattleCategoriesDto, CattleCategoriesCreateDto, CattleCategoriesUpdateDto, int>, ICattleCategoriesService
    {
        private readonly ICattleCategoriesRepository _cattleCategoriesRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public CattleCategoriesService(
            ICattleCategoriesRepository cattleCategoriesRepository, 
            IMapper mapper,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor
            ) 
            : base(cattleCategoriesRepository, mapper)
        {
            _cattleCategoriesRepository = cattleCategoriesRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }
        
        protected override async Task BeforeCreateAsync(CattleCategories entity, CattleCategoriesCreateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Name))
                throw new MilkMasterValidationException("Cattle category name cannot be empty.");

            if (string.IsNullOrEmpty(dto.Title))
                throw new MilkMasterValidationException("Cattle category title cannot be empty.");

            if (string.IsNullOrEmpty(dto.Description))
                throw new MilkMasterValidationException("Cattle category description cannot be empty.");
        }
        protected override async Task BeforeUpdateAsync(CattleCategories entity, CattleCategoriesUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Name))
                throw new MilkMasterValidationException("Cattle category name cannot be empty.");

            if (string.IsNullOrEmpty(dto.Title))
                throw new MilkMasterValidationException("Cattle category title cannot be empty.");

            if (string.IsNullOrEmpty(dto.Description))
                throw new MilkMasterValidationException("Cattle category description cannot be empty.");
        }

        protected override async Task BeforeDeleteAsync(CattleCategories entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }

    }
 
}
