using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IProductsService : IService<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, int>
    {
    }
}
