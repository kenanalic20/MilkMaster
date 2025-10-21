
using MilkMaster.Application.Common;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey>
    where T : class
    where TDto : class
    where TCreateDto : class
    where TUpdateDto : class
    where TQueryFilter : class
    {
        Task<TDto> GetByIdAsync(TKey id);
        Task<IEnumerable<TDto>> GetAllAsync(TQueryFilter? queryFilter);
        Task<TDto> CreateAsync(TCreateDto dto);
        Task<TDto> UpdateAsync(TKey id, TUpdateDto dto);
        Task DeleteAsync(TKey id);
        Task<PagedResult<TDto>> GetPagedAsync(PaginationRequest pagination, TQueryFilter? filter = null);

        Task<bool> ExistsAsync(TKey id);
        void EnableSeedingMode();
    }
}
