using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Common;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class ProductController : BaseController<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, ProductQueryFilter, int>
    {
        private readonly IProductsService _productService;
        public ProductController(IProductsService service) : base(service)
        {
            _productService = service;
        }

        [HttpGet]
        public override async Task<IActionResult> GetAll([FromQuery] ProductQueryFilter? queryFilter = null)
        {

            if (queryFilter == null)
                queryFilter = new ProductQueryFilter();


            if (queryFilter.PageSize <= 0 && queryFilter.PageNumber <= 0)
                return BadRequest("PageSize and PageNumber must be greater than zero.");

            var paginationRequest = new PaginationRequest
            {
                PageSize = queryFilter.PageSize,
                PageNumber = queryFilter.PageNumber
            };

            var result = await _productService.GetPagedAsync(paginationRequest, queryFilter);

            return Ok(result);
        }

        [HttpGet("recommend")]
        public async Task<IActionResult> Recommend()
        {
            var recommendations = await _productService.Recommand();
            if (recommendations == null || !recommendations.Any())
                return NotFound("No recommanded products found for this user.");
            return Ok(recommendations);

        }
    }
}
