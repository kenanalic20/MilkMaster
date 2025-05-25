using MilkMaster.Application.Common;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IService<T, TDto, TCreateDto, TUpdateDto, TKey>
    where T : class
    where TDto : class
    where TCreateDto : class
    where TUpdateDto : class
    {
        Task<ServiceResponse<TDto>> GetByIdAsync(TKey id);
        Task<ServiceResponse<IEnumerable<TDto>>> GetAllAsync();
        Task<ServiceResponse<TDto>> CreateAsync(TCreateDto dto, bool returnDto = true);
        Task<ServiceResponse<TDto>> UpdateAsync(TKey id, TUpdateDto dto);
        Task<ServiceResponse<bool>> DeleteAsync(TKey id);
        Task<ServiceResponse<bool>> ExistsAsync(TKey id);
    }
}
