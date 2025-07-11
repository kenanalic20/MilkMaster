using MilkMaster.Domain.Models;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class ProductController : BaseController<Products, ProductsDto, ProductsCreateDto, ProductsUpdateDto, int>
    {
       public ProductController(IProductsService service):base(service)
       {
       }
        
    }
}
