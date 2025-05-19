using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Repositories
{
    public class SettingsRepository:BaseRepository<Settings,string>,ISettingsRepository
    {
        private readonly ApplicationDbContext _context;
        public SettingsRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
        public override async Task<Settings> GetByIdAsync(string id)
        {
            return await _context.Settings
                .Include(s => s.User).
                FirstOrDefaultAsync(s=>s.UserId==id);
        }
    }
    
}
