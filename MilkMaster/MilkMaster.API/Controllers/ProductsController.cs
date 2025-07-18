using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class ProductController : BaseController<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, ProductQueryFilter, int>
    {
       public ProductController(IProductsService service):base(service)
       {
       }
        
    }
}
