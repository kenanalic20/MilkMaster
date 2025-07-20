using AutoMapper;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Exceptions;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class ProductService:BaseService<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, ProductQueryFilter, int>,IProductsService
    {
        private readonly IProductsRepository _productRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public ProductService(
            IProductsRepository productRepository,
            IMapper mapper, 
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor
            ) 
            : base(productRepository, mapper)
        {
            _productRepository = productRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override async Task BeforeUpdateAsync(Products entity, ProductsUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Title))
                throw new MilkMasterValidationException("Product name cannot be empty.");


            if (dto.Nutrition != null)
            {
                if(entity.Nutrition == null)
                    entity.Nutrition = _mapper.Map<Nutritions>(dto.Nutrition);
                else
                    _mapper.Map(dto.Nutrition, entity.Nutrition);
            }
        }
        protected override async Task AfterUpdateAsync(Products entity, ProductsUpdateDto dto)
        {
            await _productRepository.RecalculateCategoryCountsAsync();
        }
        protected override async Task BeforeCreateAsync(Products entity, ProductsCreateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Title))
                throw new MilkMasterValidationException("Product name cannot be empty.");


            if (dto.Nutrition != null)
            {
                entity.Nutrition = _mapper.Map<Nutritions>(dto.Nutrition);
            }
        }
        protected override async Task AfterCreateAsync(Products entity, ProductsCreateDto dto)
        {
            await _productRepository.RecalculateCategoryCountsAsync();
        }

        protected override async Task BeforeDeleteAsync(Products entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }
        protected override async Task AfterDeleteAsync(Products entity)
        {
            await _productRepository.RecalculateCategoryCountsAsync();
        }
        protected override IQueryable<Products> ApplyFilter(IQueryable<Products> query, ProductQueryFilter? filter)
        {
            query = query.Include(p => p.ProductCategories)
                            .ThenInclude(pc => pc.ProductCategory)
                        .Include(p => p.CattleCategory).
                        Include(p=>p.Unit);

            if (filter == null)
                return query;

            if (!string.IsNullOrWhiteSpace(filter.Title))
                query = query.Where(p => p.Title.ToLower().Contains(filter.Title.ToLower()));

            if (filter.ProductCategoryId.HasValue)
                query = query.Where(p => p.ProductCategories.Any(pc => pc.ProductCategoryId == filter.ProductCategoryId));

            if (filter.CattleCategoryId.HasValue)
                query = query.Where(p => p.CattleCategoryId == filter.CattleCategoryId);

            query = filter.SortDescending
                ? query.OrderByDescending(p => p.CreatedAt)
                : query.OrderBy(p => p.CreatedAt);

            return query;
        }


    }
    
}
