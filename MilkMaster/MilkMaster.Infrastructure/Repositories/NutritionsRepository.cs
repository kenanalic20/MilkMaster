using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Interfaces.Repositories;

namespace MilkMaster.Infrastructure.Repositories
{
    public class NutritionsRepository:BaseRepository<Nutritions, int>, INutritionsRepository
    {
        private readonly ApplicationDbContext _context;
        public NutritionsRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
