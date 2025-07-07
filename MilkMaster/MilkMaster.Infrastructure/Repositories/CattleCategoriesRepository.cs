using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Interfaces.Repositories;

namespace MilkMaster.Infrastructure.Repositories
{
    public class CattleCategoriesRepository:BaseRepository<CattleCategories, int>, ICattleCategoriesRepository
    {
        private readonly ApplicationDbContext _context;
        public CattleCategoriesRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
  
}
