

using Microsoft.EntityFrameworkCore;
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

        public override async Task<Orders> GetByIdAsync(int id)
        {
            return await _context.Orders
                .Include(o => o.Items)
                    .ThenInclude(p => p.Product)
                    .ThenInclude(u => u.Unit)
                .Include(o => o.Status)
                .FirstOrDefaultAsync(o => o.Id == id);
        }


    }
}
