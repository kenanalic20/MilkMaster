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
    public class CattleService : BaseService<Cattle, CattleDto, CattleCreateDto, CattleUpdateDto, int>, ICattleService
    {
        private readonly ICattleRepository _cattleRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public CattleService(
            ICattleRepository cattleRepository, 
            IAuthService authService,
            IMapper mapper,
            IHttpContextAccessor httpContextAccessor)
            :base(cattleRepository,mapper)
        {
            _cattleRepository = cattleRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override async Task BeforeUpdateAsync(Cattle entity, CattleUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
            
            if(string.IsNullOrEmpty(dto.Name))
                throw new MilkMasterValidationException("Product name cannot be empty.");

            if(string.IsNullOrEmpty(dto.MilkCartonUrl))
                throw new MilkMasterValidationException("Milk carton URL cannot be empty.");

            if (dto.Overview != null)
            {
                if (entity.Overview == null)
                    entity.Overview = _mapper.Map<CattleOverview>(dto.Overview);
                else
                    _mapper.Map(dto.Overview, entity.Overview);
            }

            if (dto.BreedingStatus != null)
            {
                if (entity.BreedingStatus == null)
                    entity.BreedingStatus = _mapper.Map<BreedingStatus>(dto.BreedingStatus);
                else
                    _mapper.Map(dto.BreedingStatus, entity.BreedingStatus);
            }

            entity.Age = CalculateAge(entity.BirthDate);
        }

        protected override async Task BeforeCreateAsync(Cattle entity, CattleCreateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.Name))
                throw new MilkMasterValidationException("Product name cannot be empty.");

            if (string.IsNullOrEmpty(dto.MilkCartonUrl))
                throw new MilkMasterValidationException("Milk carton URL cannot be empty.");

            if (dto.Overview != null)
            {
                entity.Overview = _mapper.Map<CattleOverview>(dto.Overview);
            }

            if (dto.BreedingStatus != null)
            {
                entity.BreedingStatus = _mapper.Map<BreedingStatus>(dto.BreedingStatus);
            }

            entity.Age = CalculateAge(entity.BirthDate);
        }

        protected override async Task BeforeDeleteAsync(Cattle entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }

        private int CalculateAge(DateTime birthDate)
        {
            var today = DateTime.Today;
            var age = today.Year - birthDate.Year;
            if (birthDate.Date > today.AddYears(-age)) 
                age--;
            return age;
        }

    }
}
