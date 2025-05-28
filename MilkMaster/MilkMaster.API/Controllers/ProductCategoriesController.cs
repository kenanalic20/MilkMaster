using MilkMaster.Domain.Models;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class ProductCategoriesController : BaseController<ProductCategories, ProductCategoriesDto, ProductCategoriesCreateDto, ProductCategoriesUpdateDto, int>
    {
       public ProductCategoriesController(IProductCategoriesService service):base(service)
       {
       }
        
    }
}
