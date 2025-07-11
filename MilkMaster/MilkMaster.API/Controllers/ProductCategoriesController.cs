using MilkMaster.Domain.Models;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class ProductCategoriesController : BaseController<ProductCategories, ProductCategoriesDto, ProductCategoriesCreateDto, ProductCategoriesUpdateDto, int>
    {
        private readonly IProductCategoriesService _service;
       public ProductCategoriesController(IProductCategoriesService service):base(service)
       {
            _service = service;
       }

        [HttpGet("test")]
        public async Task<IActionResult> GetTestData()
        {
            var response = await _service.GetAllAsync();
            Console.WriteLine("Response");
            Console.WriteLine(response);
            if (!response.Success) {
                return StatusCode(response.StatusCode, response.Message);
            }

            return Ok(response.Data);
        }
    }

    [ApiController]
    [Route("[controller]")]
    public class ProductCategoriesControllerTest:ControllerBase
    {
        private readonly IProductCategoriesService _service;
        public ProductCategoriesControllerTest(IProductCategoriesService service)
        {
            _service = service;
        }

        [HttpGet("test")]
        public async Task<IActionResult> GetTestData()
        {
            var response = await _service.GetAllAsync();
            Console.WriteLine("Response");
            Console.WriteLine(response);
            if (!response.Success)
            {
                return StatusCode(response.StatusCode, response.Message);
            }

            return Ok(response.Data);
        }
    }

}
