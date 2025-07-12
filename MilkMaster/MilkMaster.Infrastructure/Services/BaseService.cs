using AutoMapper;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MilkMaster.Infrastructure.Services
{
    public class BaseService<T, TDto, TCreateDto, TUpdateDto, TKey> : IService<T, TDto, TCreateDto, TUpdateDto, TKey>
        where T : class
        where TDto : class
        where TCreateDto : class
        where TUpdateDto : class
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

        public virtual async Task<TDto> GetByIdAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Entity with id '{id}' not found.");

            await AfterGetAsync(entity);
            return _mapper.Map<TDto>(entity);
        }

        public virtual async Task<IEnumerable<TDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            await AfterGetAllAsync(entities);
            return _mapper.Map<IEnumerable<TDto>>(entities);
        }

        public virtual async Task<TDto?> CreateAsync(TCreateDto dto, bool returnDto = true)
        {
            var entity = _mapper.Map<T>(dto);
            await BeforeCreateAsync(entity, dto);
            await _repository.AddAsync(entity);
            await AfterCreateAsync(entity, dto);

            return returnDto ? _mapper.Map<TDto>(entity) : null;
        }

        public virtual async Task<TDto> UpdateAsync(TKey id, TUpdateDto dto)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Entity with id '{id}' not found.");

            await BeforeUpdateAsync(entity, dto);
            _mapper.Map(dto, entity);
            await _repository.UpdateAsync(entity);
            await AfterUpdateAsync(entity, dto);

            return _mapper.Map<TDto>(entity);
        }

        public virtual async Task DeleteAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Entity with id '{id}' not found.");

            await BeforeDeleteAsync(entity);
            await _repository.DeleteAsync(entity);
            await AfterDeleteAsync(entity);
        }

        public virtual async Task<bool> ExistsAsync(TKey id)
        {
            return await _repository.ExistsAsync(id);
        }

        // HOOK METODE

        protected virtual Task BeforeCreateAsync(T entity, TCreateDto dto) => Task.CompletedTask;
        protected virtual Task AfterCreateAsync(T entity, TCreateDto dto) => Task.CompletedTask;

        protected virtual Task BeforeUpdateAsync(T entity, TUpdateDto dto) => Task.CompletedTask;
        protected virtual Task AfterUpdateAsync(T entity, TUpdateDto dto) => Task.CompletedTask;

        protected virtual Task BeforeDeleteAsync(T entity) => Task.CompletedTask;
        protected virtual Task AfterDeleteAsync(T entity) => Task.CompletedTask;

        protected virtual Task AfterGetAsync(T entity) => Task.CompletedTask;
        protected virtual Task AfterGetAllAsync(IEnumerable<T> entities) => Task.CompletedTask;
    }
}
