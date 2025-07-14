using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Repositories
{
    public interface IProductsRepository : IRepository<Products, int>
    {
        Task RecalculateCategoryCountsAsync();
    }
}
