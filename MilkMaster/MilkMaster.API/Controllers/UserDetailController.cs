using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class UserDetailController : BaseController<UserDetails, UserDetailsDto, UserDetailsCreateDto, UserDetailsUpdateDto, string>
    {
        public UserDetailController(IUserDetailsService service):base(service)
        {
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
