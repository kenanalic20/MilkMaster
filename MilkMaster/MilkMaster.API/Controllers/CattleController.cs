using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.API.Controllers
{
    public class CattleController : BaseController<Cattle, CattleDto, CattleCreateDto, CattleUpdateDto, int>
    {
        public CattleController(ICattleService service) : base(service)
        {
        }
    }
}
