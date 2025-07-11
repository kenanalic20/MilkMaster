using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Infrastructure.Services;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class UserAddressController : BaseController<UserAddress, UserAddressDto, UserAddressCreateDto, UserAddressUpdateDto, string>
    {
        IUserAddressService _service;
        public UserAddressController(IUserAddressService service) : base(service)
        {
            _service = service;
        }
        [HttpGet("{id}")]
        public override async Task<IActionResult> GetById(string id)
        {
            var result = await _service.GetByIdAsync(id, User);

            if (!result.Success)
            {
                if (result.StatusCode == 403)
                    return Forbid();
                if (result.StatusCode == 404)
                    return NotFound(result.Message);

                return StatusCode(result.StatusCode, result.Message);
            }

            return Ok(result.Data);
        }

        [HttpDelete("{id}")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> Delete(string id)
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }

        [HttpGet]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> GetAll()
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }
    }
}
