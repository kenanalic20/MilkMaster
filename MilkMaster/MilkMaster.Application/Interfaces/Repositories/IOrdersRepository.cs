using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Repositories
{
    public interface IOrdersRepository : IRepository<Orders, int>
    {
        Task<List<Orders>> GetByIdUserAsync(string id);

    }
}
