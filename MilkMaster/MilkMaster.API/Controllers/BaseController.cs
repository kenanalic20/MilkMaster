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
        private readonly IService<T,TDto,TCreateDto,TUpdateDto, TKey> _service;

        public BaseController(IService<T, TDto, TCreateDto, TUpdateDto, TKey> service)
        {
            _service = service;
        }
        [HttpGet("{id}")]
        public virtual async Task<IActionResult> GetById(TKey id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }

        [HttpGet]
        public virtual async Task<IActionResult> GetAll()
        {
            var results = await _service.GetAllAsync();
            return Ok(results);
        }

        [HttpPost]
        public virtual async Task<IActionResult> Create([FromBody] TCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _service.CreateAsync(dto);

            if (created == null)
                return BadRequest("Failed to create entity.");

            return Created(string.Empty, created);
        }

        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Update(TKey id, [FromBody] TUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _service.UpdateAsync(id, dto);
            if (updated == null)
                return NotFound();
            return Ok(updated);
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(TKey id)
        {
            var success = await _service.DeleteAsync(id);
            if (!success)
                return NotFound();
            return NoContent();
        }


    }
}
