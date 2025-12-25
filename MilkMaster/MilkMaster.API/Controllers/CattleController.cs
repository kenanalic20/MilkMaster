using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Infrastructure.Services;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    public class CattleController : BaseController<Cattle, CattleDto, CattleCreateDto, CattleUpdateDto, CattleQueryFilter, int>
    {
        private readonly ICattleService _cattleService;

        public CattleController(ICattleService service) : base(service)
        {
            _cattleService = service;
        }
        [HttpGet]
        public override async Task<IActionResult> GetAll([FromQuery] CattleQueryFilter? queryFilter = null)
        {

            if (queryFilter == null)
                queryFilter = new CattleQueryFilter();


            if (queryFilter.PageSize <= 0 && queryFilter.PageNumber <= 0)
                return BadRequest("PageSize and PageNumber must be greater than zero.");

            var paginationRequest = new PaginationRequest
            {
                PageSize = queryFilter.PageSize,
                PageNumber = queryFilter.PageNumber
            };

            var result = await _cattleService.GetPagedAsync(paginationRequest, queryFilter);

            return Ok(result);
        }
    }
}
