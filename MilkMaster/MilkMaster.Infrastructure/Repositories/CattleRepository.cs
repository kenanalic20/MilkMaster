using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Repositories
{
    public class CattleRepository : BaseRepository<Cattle, int>, ICattleRepository
    {
        private readonly ApplicationDbContext _context;

        public CattleRepository(ApplicationDbContext context) : base(context) 
        { 
            _context = context;
        }
        public override async Task<IEnumerable<Cattle>> GetAllAsync()
        {
            return await _context.Cattle
                .Include(c=>c.CattleCategory)
                .ToListAsync();
        }
        public override async Task<Cattle> GetByIdAsync(int id)
        {
            return await _context.Cattle
                .Include(bs => bs.BreedingStatus)
                .Include(o => o.Overview)
                .Include(c => c.CattleCategory).
                FirstOrDefaultAsync(c => c.Id == id);
        }
    }
}
