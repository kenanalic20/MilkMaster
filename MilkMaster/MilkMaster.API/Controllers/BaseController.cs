using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.API.Controllers
{
    [Route("[controller]")]
    public class BaseController<T, TDto, TCreateDto, TUpdateDto, TKey> : ControllerBase
        where T : class
        where TDto : class
        where TCreateDto : class
        where TUpdateDto : class
    {
        private readonly IService<T, TDto, TCreateDto, TUpdateDto, TKey> _service;

        public BaseController(IService<T, TDto, TCreateDto, TUpdateDto, TKey> service)
        {
            _service = service;
        }

        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById(TKey id)
        {
            var result = await _service.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpGet]
        public virtual async Task<IActionResult> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpPost]
        public virtual async Task<IActionResult> Create([FromBody] TCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _service.CreateAsync(dto);
            return Created();
        }

        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Update(TKey id, [FromBody] TUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _service.UpdateAsync(id, dto);
            return Created();
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(TKey id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }
    }
}
