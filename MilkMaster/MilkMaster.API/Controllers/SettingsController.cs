using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
//Temporary
namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class SettingsController : BaseController<Settings, SettingsDto, string>
    {
        public SettingsController(ISettingsService service) : base(service)
        {
        }

        [HttpPost]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> Create([FromBody] SettingsDto dto)
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }

        [HttpPost]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> Delete(string id)
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }

        [HttpPost]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> GetAll()
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }


    }
}
