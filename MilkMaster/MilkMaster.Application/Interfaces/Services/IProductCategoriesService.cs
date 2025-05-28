using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IProductCategoriesService:IService<ProductCategories,ProductCategoriesDto,ProductCategoriesCreateDto,ProductCategoriesUpdateDto,int>
    {
        Task<List<ServiceResponse<ProductCategoriesAdminDto>>> GetByIdAdminAsync(int id);
    }
}
