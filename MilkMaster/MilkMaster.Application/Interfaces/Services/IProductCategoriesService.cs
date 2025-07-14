using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IProductCategoriesService:IService<ProductCategories,ProductCategoriesDto,ProductCategoriesCreateDto,ProductCategoriesUpdateDto,int>
    {
    }
}
