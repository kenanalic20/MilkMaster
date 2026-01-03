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

    public class OrdersController : BaseController<Orders, OrdersDto, OrdersCreateDto, OrdersUpdateDto, OrderQueryFilter, int>
    {
        private readonly IOrdersService _ordersService;
        public OrdersController(IOrdersService service) : base(service) 
        {
            _ordersService = service;
        }
        [HttpGet]
        public override async Task<IActionResult> GetAll([FromQuery] OrderQueryFilter? queryFilter = null)
        {
            if (queryFilter == null)
                queryFilter = new OrderQueryFilter();
            if (queryFilter.PageSize <= 0 && queryFilter.PageNumber <= 0)
                return BadRequest("PageSize and PageNumber must be greater than zero.");
            var paginationRequest = new PaginationRequest
            {
                PageSize = queryFilter.PageSize,
                PageNumber = queryFilter.PageNumber
            };
            var result = await _ordersService.GetPagedAsync(paginationRequest, queryFilter);
            return Ok(result);
        }
        [Authorize(Roles = "Admin")]
        [HttpGet("total-revenue")]
        public async Task<ActionResult<decimal>> GetTotalSoldProductsCountAsync()
        {
            var result = await _ordersService.GetTotalRevenueAsync();
            return Ok(result);
        }

        [Authorize]
        [HttpPost("create-with-payment")]
        public async Task<ActionResult<OrderWithPaymentResponseDto>> CreateOrderWithPayment([FromBody] OrdersCreateDto dto)
        {
            try
            {
                var result = await _ordersService.CreateOrderWithPaymentAsync(dto);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
