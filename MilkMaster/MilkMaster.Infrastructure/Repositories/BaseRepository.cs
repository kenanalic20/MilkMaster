using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Common;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Domain.Data;

namespace MilkMaster.Infrastructure.Repositories
{
    public class BaseRepository<T, TKey> : IRepository<T, TKey> where T : class
    {
        private readonly ApplicationDbContext _context;
        private readonly DbSet<T> _dbSet;
        public BaseRepository(ApplicationDbContext context) {
            _context = context;
            _dbSet = context.Set<T>();
        }
        public virtual async Task<T> GetByIdAsync(TKey id)
        {
            return await _dbSet.FindAsync(id);
        }

        public virtual async Task<IEnumerable<T>> GetAllAsync()
        {
            return await _dbSet.ToListAsync();
        }

        public virtual async Task AddAsync(T entity)
        {
            await _dbSet.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public virtual async Task UpdateAsync(T entity)
        { 
            _dbSet.Update(entity);
            await _context.SaveChangesAsync();
        }

        public virtual async Task DeleteAsync(T entity)
        {
            _dbSet.Remove(entity);
            await _context.SaveChangesAsync();
        }

        public virtual IQueryable<T> AsQueryable()
        {
            return _dbSet.AsQueryable();
        }

        public virtual async Task<PagedResult<T>> GetPagedAsync(IQueryable<T> query, PaginationRequest pagination)
        {
            var totalCount = await query.CountAsync();

            var items = await query
                .Skip((pagination.PageNumber - 1) * pagination.PageSize)
                .Take(pagination.PageSize)
                .ToListAsync();

            return new PagedResult<T>
            {
                Items = items,
                TotalCount = totalCount,
                PageNumber = pagination.PageNumber,
            };
        }

        public virtual async Task<bool> ExistsAsync(TKey id)
        {
            var entity = await GetByIdAsync(id);
            return entity != null;
        }

    }
}
