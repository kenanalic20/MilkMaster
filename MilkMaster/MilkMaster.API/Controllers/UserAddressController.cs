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
    public class UserAddressController : BaseController<UserAddress, UserAddressDto, UserAddressCreateDto, UserAddressUpdateDto, string>
    {
        IUserAddressService _service;
        public UserAddressController(IUserAddressService service) : base(service)
        {
            _service = service;
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
