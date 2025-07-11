using AutoMapper;
using MilkMaster.Application.Common;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;

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

        public virtual async Task<ServiceResponse<TDto>> GetByIdAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                return ServiceResponse<TDto>.FailureResponse("Not found", 404);

            await AfterGetAsync(entity);
            return ServiceResponse<TDto>.SuccessResponse(_mapper.Map<TDto>(entity));
        }

        public virtual async Task<ServiceResponse<IEnumerable<TDto>>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            await AfterGetAllAsync(entities);
            return ServiceResponse<IEnumerable<TDto>>.SuccessResponse(_mapper.Map<IEnumerable<TDto>>(entities));
        }

        public virtual async Task<ServiceResponse<TDto>> CreateAsync(TCreateDto dto, bool returnDto = true)
        {
            var entity = _mapper.Map<T>(dto);
            await BeforeCreateAsync(entity, dto);
            await _repository.AddAsync(entity);
            await AfterCreateAsync(entity, dto);

            if (!returnDto)
                return ServiceResponse<TDto>.SuccessResponse(null);

            return ServiceResponse<TDto>.SuccessResponse(_mapper.Map<TDto>(entity));
        }

        public virtual async Task<ServiceResponse<TDto>> UpdateAsync(TKey id, TUpdateDto dto)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                return ServiceResponse<TDto>.FailureResponse("Not found", 404);

            await BeforeUpdateAsync(entity, dto);
            _mapper.Map(dto, entity);
            await _repository.UpdateAsync(entity);
            await AfterUpdateAsync(entity, dto);

            return ServiceResponse<TDto>.SuccessResponse(_mapper.Map<TDto>(entity));
        }

        public virtual async Task<ServiceResponse<bool>> DeleteAsync(TKey id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                return ServiceResponse<bool>.FailureResponse("Not found", 404);

            await BeforeDeleteAsync(entity);
            await _repository.DeleteAsync(entity);
            await AfterDeleteAsync(entity);

            return ServiceResponse<bool>.SuccessResponse(true);
        }

        public virtual async Task<ServiceResponse<bool>> ExistsAsync(TKey id)
        {
            var exists = await _repository.ExistsAsync(id);
            return ServiceResponse<bool>.SuccessResponse(exists);
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
