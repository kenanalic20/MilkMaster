using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IProductCategoriesService:IService<ProductCategories, ProductCategoriesDto,ProductCategoriesCreateDto,ProductCategoriesUpdateDto,EmptyQueryFilter, int>
    {
    }
}
