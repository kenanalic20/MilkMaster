using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.API.Controllers
{
    [Route("[controller]")]
    //[ApiController]
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
            var response = await _service.GetByIdAsync(id);
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Ok(response.Data);
        }

        [HttpGet]
        public virtual async Task<IActionResult> GetAll()
        {
            var response = await _service.GetAllAsync();
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Ok(response.Data);
        }

        [HttpPost]
        public virtual async Task<IActionResult> Create([FromBody] TCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var response = await _service.CreateAsync(dto);
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Created(string.Empty, response.Data);
        }

        [HttpPut("{id}")]
        public virtual async Task<IActionResult> Update(TKey id, [FromBody] TUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var response = await _service.UpdateAsync(id, dto);
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Ok(response.Data);
        }

        [HttpDelete("{id}")]
        public virtual async Task<IActionResult> Delete(TKey id)
        {
            var response = await _service.DeleteAsync(id);
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return NoContent();
        }
    }
}
