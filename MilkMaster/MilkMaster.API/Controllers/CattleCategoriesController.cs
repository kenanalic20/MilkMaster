﻿using MilkMaster.Domain.Models;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Filters;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    public class CattleCategoriesController : BaseController<CattleCategories, CattleCategoriesDto, CattleCategoriesCreateDto, CattleCategoriesUpdateDto, CattleCategoriesQueryFilter, int>
    {
       public CattleCategoriesController(ICattleCategoriesService service):base(service)
       {
       }
        
    }
}
