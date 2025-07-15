using MilkMaster.Domain.Models;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Application.Interfaces.Repositories;
using AutoMapper;
using Microsoft.AspNetCore.Http;
using MilkMaster.Application.Exceptions;

namespace MilkMaster.Infrastructure.Services
{
    public class ProductCategoriesService:BaseService<ProductCategories, ProductCategoriesDto, ProductCategoriesCreateDto, ProductCategoriesUpdateDto, int>, IProductCategoriesService
    {
        private readonly IProductCategoriesRepository _productCategoriesRepository;
        private readonly IAuthService _authService;
        private readonly IHttpContextAccessor _httpContextAccessor;
        public ProductCategoriesService(
            IProductCategoriesRepository productCategoriesRepository, 
            IMapper mapper,
            IAuthService authService,
            IHttpContextAccessor httpContextAccessor
            ) 
            : base(productCategoriesRepository, mapper)
        {
            _productCategoriesRepository = productCategoriesRepository;
            _authService = authService;
            _httpContextAccessor = httpContextAccessor;
        }
        protected override async Task BeforeCreateAsync(ProductCategories entity, ProductCategoriesCreateDto dto)
        {
            if (_isSeeding)
                return;

            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");

            if (string.IsNullOrEmpty(dto.Name))
                throw new MilkMasterValidationException("Product name cannot be empty.");
        }
        protected override async Task BeforeUpdateAsync(ProductCategories entity, ProductCategoriesUpdateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");

            if (string.IsNullOrEmpty(dto.ImageUrl))
                throw new MilkMasterValidationException("Image URL cannot be empty.");
        }
        protected override async Task BeforeDeleteAsync(ProductCategories entity)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
                throw new UnauthorizedAccessException("User is not admin.");
        }

        public override async Task<IEnumerable<ProductCategoriesDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();

            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);

            if (isAdmin)
            {
                return _mapper.Map<IEnumerable<ProductCategoriesAdminDto>>(entities);
            }

            return _mapper.Map<IEnumerable<ProductCategoriesDto>>(entities);
        }


    }
}
