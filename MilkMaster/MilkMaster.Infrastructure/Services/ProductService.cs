using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Services
{
    public class ProductService:BaseService<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, int>,IProductsService
    {
        private readonly IProductsRepository _productRepository;
        public ProductService(IProductsRepository productRepository, IMapper mapper) : base(productRepository, mapper)
        {
            _productRepository = productRepository;
        }
    }
    
}
