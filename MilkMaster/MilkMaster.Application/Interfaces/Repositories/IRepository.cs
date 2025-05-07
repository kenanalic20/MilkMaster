namespace MilkMaster.Application.Interfaces.Repositories
{
    public interface IRepository<T, TKey> where T : class
    {
        Task<T> GetByIdAsync(TKey id);
        Task<IEnumerable<T>> GetAllAsync();
        Task AddAsync(T entity);
        Task UpdateAsync(T entity);
        Task DeleteAsync(T entity);
        IQueryable<T> AsQueryable(); 
        Task<bool> ExistsAsync(TKey id);
    }
}
