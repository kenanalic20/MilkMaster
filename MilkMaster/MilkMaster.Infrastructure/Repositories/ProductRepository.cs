using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;
using MilkMaster.Domain.Models;

namespace MilkMaster.Infrastructure.Repositories
{
    public class ProductRepository:BaseRepository<Products, int>, IProductsRepository
    {
        private readonly ApplicationDbContext _context;
        public ProductRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
        public override async Task<IEnumerable<Products>> GetAllAsync()
        {
            return await _context.Products
                .Include(p => p.ProductCategories)
                    .ThenInclude(pc => pc.ProductCategory)
                .Include(p => p.CattleCategory)
                .ToListAsync();
        }
        public override async Task<Products> GetByIdAsync(int id)
        {
            return await _context.Products
                    .Include(p => p.ProductCategories)
                        .ThenInclude(pc => pc.ProductCategory)
                    .Include(p => p.CattleCategory)
                    .FirstOrDefaultAsync(p => p.Id == id);
        }
        
    }
}
