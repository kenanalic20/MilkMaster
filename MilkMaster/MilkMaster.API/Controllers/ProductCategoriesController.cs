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
    public class ProductCategoriesController : BaseController<ProductCategories, ProductCategoriesDto, ProductCategoriesCreateDto, ProductCategoriesUpdateDto, EmptyQueryFilter, int>
    {
       public ProductCategoriesController(IProductCategoriesService service):base(service)
       {
       }
    }

}
