using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Exceptions;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace MilkMaster.Infrastructure.Services
{
    public class CattleService : BaseService<Cattle, CattleDto, CattleCreateDto, CattleUpdateDto, CattleQueryFilter, int>, ICattleService
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

            if (string.IsNullOrEmpty(dto.TagNumber))
                throw new MilkMasterValidationException("Tag number cannot be empty.");

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
            if(_isSeeding)
                return;

            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.Name))
                throw new MilkMasterValidationException("Product name cannot be empty.");

            if (string.IsNullOrEmpty(dto.MilkCartonUrl))
                throw new MilkMasterValidationException("Milk carton URL cannot be empty.");

            if(string.IsNullOrEmpty(dto.TagNumber))
                throw new MilkMasterValidationException("Tag number cannot be empty.");


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

       


        protected override IQueryable<Cattle> ApplyFilter(IQueryable<Cattle> query, CattleQueryFilter? filter)
        {
            query = query.Include(p => p.CattleCategory);

            if (filter == null)
                return query;

            if (!string.IsNullOrWhiteSpace(filter.Search))
                query = query.Where(p => 
                    p.Name.ToLower().Contains(filter.Search.ToLower()) 
                    || p.CattleCategory.Name.ToLower().Contains(filter.Search.ToLower())
                );

            if (filter.CattleCategoryId.HasValue)
                query = query.Where(p => p.CattleCategoryId == filter.CattleCategoryId);

            if (!string.IsNullOrEmpty(filter.OrderBy))
            {
                switch (filter.OrderBy.ToLower())
                {
                    case "age_asc":
                        query = query.OrderBy(o => o.Age);
                        break;
                    case "age_desc":
                        query = query.OrderByDescending(o => o.Age);
                        break;
                    case "revenue_asc":
                        query = query.OrderBy(o => o.MonthlyValue);
                        break;
                    case "revenue_desc":
                        query = query.OrderByDescending(o => o.MonthlyValue);
                        break;
                    case "milk_asc":
                        query = query.OrderBy(o => o.LitersPerDay);
                        break;
                    case "milk_desc":
                        query = query.OrderByDescending(o => o.LitersPerDay);
                        break;
                }
            }

            return query;
        }
        public override async Task<PagedResult<CattleDto>> GetPagedAsync(PaginationRequest pagination, CattleQueryFilter? filter = null)
        {
            var query = _cattleRepository.AsQueryable();
            query = ApplyFilter(query, filter);

            await BeforePagedAsync(query);

            var pagedEntities = await _cattleRepository.GetPagedAsync(query, pagination);

            await AfterPagedAsync(pagedEntities.Items);

            var totalRevenue = Math.Round(await query.SumAsync(c => c.MonthlyValue));
            var totalLiters = Math.Round(await query.SumAsync(c => c.LitersPerDay));

            return new CattlePagedResult
            {
                Items = _mapper.Map<List<CattleDto>>(pagedEntities.Items),
                TotalCount = pagedEntities.TotalCount,
                PageNumber = pagedEntities.PageNumber,
                TotalRevenue = totalRevenue,
                TotalLiters = totalLiters,
            };
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
