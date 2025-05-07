using AutoMapper;
using Microsoft.Extensions.Logging;
using MilkMaster.Application.Common;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Services
{
    public class BaseService<T, TDto, TKey> : IService<T, TDto, TKey>
        where T : class
        where TDto : class
    {
        protected readonly IRepository<T, TKey> _repository;
        protected readonly IMapper _mapper;

        public BaseService(
            IRepository<T, TKey> repository, 
            IMapper mapper
        )
        {
            _repository = repository;
            _mapper = mapper;
        }
        public async Task<TDto> GetByIdAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
           
            return _mapper.Map<TDto>(entity);
        }
        public async Task<IEnumerable<TDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            return _mapper.Map<IEnumerable<TDto>>(entities);
        }

        public async Task<TDto> CreateAsync(TDto dto)
        {
            var entity = _mapper.Map<T>(dto);
            await _repository.AddAsync(entity);
            return _mapper.Map<TDto>(entity);
        }

        public async Task<TDto> UpdateAsync(TKey id, TDto dto)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                return null;

            _mapper.Map(dto, entity);
            await _repository.UpdateAsync(entity);
            return _mapper.Map<TDto>(entity);
        }

        public async Task<bool> DeleteAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                return false;

            await _repository.DeleteAsync(entity);
            return true;
        }

        public async Task<bool> ExistsAsync(TKey id)
        {
            return await _repository.ExistsAsync(id);
        }
    }
}
