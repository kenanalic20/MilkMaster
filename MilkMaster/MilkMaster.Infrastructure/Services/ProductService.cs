using AutoMapper;
using Microsoft.AspNetCore.Http;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class ProductService:BaseService<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, int>,IProductsService
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
            {
                throw new UnauthorizedAccessException("User is not admin.");
            }
            await Task.CompletedTask;
        }
        protected override async Task BeforeCreateAsync(Products entity, ProductsCreateDto dto)
        {
            var user = _httpContextAccessor.HttpContext?.User!;
            var isAdmin = await _authService.IsAdminAsync(user);
            if (!isAdmin)
            {
                throw new UnauthorizedAccessException("User is not admin.");
            }

            await Task.CompletedTask;
        }

    }
    
}
