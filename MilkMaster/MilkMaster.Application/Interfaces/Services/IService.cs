namespace MilkMaster.Application.Interfaces.Services
{
    public interface IService<T, TDto, TCreateDto, TUpdateDto, TKey>
    where T : class
    where TDto : class
    where TCreateDto : class
    where TUpdateDto : class
    {
        Task<TDto> GetByIdAsync(TKey id);
        Task<IEnumerable<TDto>> GetAllAsync();
        Task<TDto> CreateAsync(TCreateDto dto, bool returnDto = true);
        Task<TDto> UpdateAsync(TKey id, TUpdateDto dto);
        Task<bool> DeleteAsync(TKey id);
        Task<bool> ExistsAsync(TKey id);
    }
}
