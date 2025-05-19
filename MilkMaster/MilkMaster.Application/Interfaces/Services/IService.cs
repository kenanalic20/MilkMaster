using MilkMaster.Application.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Text;
using System.Threading.Tasks;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IService<T, TDto, TKey>
    where T : class
    where TDto : class
    {
        Task<TDto> GetByIdAsync(TKey id);
        Task<IEnumerable<TDto>> GetAllAsync();
        Task<TDto> CreateAsync(TDto dto, bool returnDto = true);
        Task<TDto> UpdateAsync(TKey id, TDto dto);
        Task<bool> DeleteAsync(TKey id);
        Task<bool> ExistsAsync(TKey id);
    }
}
