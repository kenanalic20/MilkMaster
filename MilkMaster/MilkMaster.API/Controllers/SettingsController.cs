using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class SettingsController : BaseController<Settings, SettingsDto, SettingsCreateDto, SettingsUpdateDto, EmptyQueryFilter, string>
    {
        public SettingsController(ISettingsService service) : base(service)
        {
        }

        [HttpPost]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> Create([FromBody] SettingsCreateDto dto)
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }

        [HttpDelete("{id}")]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> Delete(string id)
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }

        [HttpGet]
        [ApiExplorerSettings(IgnoreApi = true)]
        public override Task<IActionResult> GetAll(EmptyQueryFilter? queryFilter)
        {
            return Task.FromResult<IActionResult>(BadRequest());
        }


    }
}
