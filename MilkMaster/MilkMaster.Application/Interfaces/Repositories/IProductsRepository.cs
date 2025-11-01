using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Repositories
{
    public interface IProductsRepository : IRepository<Products, int>
    {
        Task RecalculateCategoryCountsAsync();
    }
}
