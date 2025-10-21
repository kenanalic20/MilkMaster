using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Common;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MilkMaster.Infrastructure.Services
{
    public class BaseService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey> : IService<T, TDto, TCreateDto, TUpdateDto, TQueryFilter, TKey>
        where T : class
        where TDto : class
        where TCreateDto : class
        where TUpdateDto : class
        where TQueryFilter : class
    {
        protected readonly IRepository<T, TKey> _repository;
        protected readonly IMapper _mapper;
        protected bool _isSeeding = false;

        public BaseService(
            IRepository<T, TKey> repository,
            IMapper mapper
        )
        {
            _repository = repository;
            _mapper = mapper;
        }

        public void EnableSeedingMode()
        {
            _isSeeding = true;
        }

        public virtual async Task<TDto> GetByIdAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Entity with id '{id}' not found.");

            await AfterGetAsync(entity);
            return _mapper.Map<TDto>(entity);
        }

        public virtual async Task<IEnumerable<TDto>> GetAllAsync(TQueryFilter? queryFilter = null)
        {
            var query = _repository.AsQueryable();
            query = ApplyFilter(query, queryFilter);
            var entities = await query.ToListAsync();
            await AfterGetAllAsync(entities);
            return _mapper.Map<IEnumerable<TDto>>(entities);
        }

        public virtual async Task<TDto?> CreateAsync(TCreateDto dto)
        {
            var entity = _mapper.Map<T>(dto);
            await BeforeCreateAsync(entity, dto);
            await _repository.AddAsync(entity);
            await AfterCreateAsync(entity, dto);

            return _mapper.Map<TDto>(entity);
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

        public virtual async Task<PagedResult<TDto>> GetPagedAsync(PaginationRequest pagination, TQueryFilter? filter = null)
        {
            var query = _repository.AsQueryable();
            query = ApplyFilter(query, filter);

            await BeforePagedAsync(query);

            var pagedEntities = await _repository.GetPagedAsync(query, pagination);

            await AfterPagedAsync(pagedEntities.Items);

            return new PagedResult<TDto>
            {
                Items = _mapper.Map<List<TDto>>(pagedEntities.Items),
                TotalCount = pagedEntities.TotalCount,
                PageNumber = pagedEntities.PageNumber,
            };
        }

        public virtual async Task<bool> ExistsAsync(TKey id)
        {
            return await _repository.ExistsAsync(id);
        }



        // HOOK METODE

        protected virtual IQueryable<T> ApplyFilter(IQueryable<T> query, TQueryFilter? filter)
        {
            return query;
        }
        protected virtual Task BeforeCreateAsync(T entity, TCreateDto dto) => Task.CompletedTask;
        protected virtual Task AfterCreateAsync(T entity, TCreateDto dto) => Task.CompletedTask;

        protected virtual Task BeforeUpdateAsync(T entity, TUpdateDto dto) => Task.CompletedTask;
        protected virtual Task AfterUpdateAsync(T entity, TUpdateDto dto) => Task.CompletedTask;

        protected virtual Task BeforeDeleteAsync(T entity) => Task.CompletedTask;
        protected virtual Task AfterDeleteAsync(T entity) => Task.CompletedTask;

        protected virtual Task BeforePagedAsync(IQueryable<T> query) => Task.CompletedTask;
        protected virtual Task AfterPagedAsync(List<T> entities) => Task.CompletedTask;

        protected virtual Task AfterGetAsync(T entity) => Task.CompletedTask;
        protected virtual Task AfterGetAllAsync(IEnumerable<T> entities) => Task.CompletedTask;
    }
}
