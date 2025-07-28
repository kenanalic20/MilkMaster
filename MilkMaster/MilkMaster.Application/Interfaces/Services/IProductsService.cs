using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IProductsService : IService<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, ProductQueryFilter, int>
    {
        Task<List<ProductsDto>> Recommand(int id);
    }
}
