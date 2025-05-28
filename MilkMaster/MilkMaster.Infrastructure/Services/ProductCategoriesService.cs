using MilkMaster.Domain.Models;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Common;
using AutoMapper;

namespace MilkMaster.Infrastructure.Services
{
    public class ProductCategoriesService:BaseService<ProductCategories, ProductCategoriesDto, ProductCategoriesCreateDto, ProductCategoriesUpdateDto, int>, IProductCategoriesService
    {
        private readonly IProductCategoriesRepository _productCategoriesRepository;
        public ProductCategoriesService(IProductCategoriesRepository productCategoriesRepository, IMapper mapper) : base(productCategoriesRepository, mapper)
        {
            _productCategoriesRepository = productCategoriesRepository;
        }
        public Task<List<ServiceResponse<ProductCategoriesAdminDto>>> GetByIdAdminAsync(int id)
        {
            throw new NotImplementedException();
        }
    }
}
