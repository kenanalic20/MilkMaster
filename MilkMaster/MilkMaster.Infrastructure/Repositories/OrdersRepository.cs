

using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Repositories
{
    public class OrdersRepository : BaseRepository<Orders, int>, IOrdersRepository
    {
        private readonly ApplicationDbContext _context;
        public OrdersRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
       
    }
}
