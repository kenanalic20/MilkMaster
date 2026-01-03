using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.API.Controllers
{
    [Authorize]

    public class OrderItemsController : BaseController<OrderItems, OrderItemsDto, OrderItemsCreateDto, OrderItemsUpdateDto, OrderItemsQueryFilter, int>
    {
        private readonly IOrderItemsService _orderItemsService;
        public OrderItemsController(IOrderItemsService service) : base(service)
        {
            _orderItemsService = service;
        }
        [HttpGet]
        public override async Task<IActionResult> GetAll([FromQuery] OrderItemsQueryFilter? queryFilter = null)
        {
            if (queryFilter == null)
                queryFilter = new OrderItemsQueryFilter();
            if (queryFilter.PageSize <= 0 && queryFilter.PageNumber <= 0)
                return BadRequest("PageSize and PageNumber must be greater than zero.");
            var paginationRequest = new PaginationRequest
            {
                PageSize = queryFilter.PageSize,
                PageNumber = queryFilter.PageNumber
            };
            var result = await _orderItemsService.GetPagedAsync(paginationRequest, queryFilter);
            return Ok(result);
        }
    }
}
