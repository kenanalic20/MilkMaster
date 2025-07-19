using MilkMaster.Domain.Models;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;

namespace MilkMaster.Infrastructure.Repositories
{
    public class ProductCategoriesRepository:BaseRepository<ProductCategories, int>, IProductCategoriesRepository
    {
        private readonly ApplicationDbContext _context;
        public ProductCategoriesRepository(ApplicationDbContext context) : base(context)
        {
            _context = context;
        }
    }
}
