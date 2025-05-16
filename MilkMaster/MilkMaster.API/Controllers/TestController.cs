using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
//Temporary
namespace MilkMaster.API.Controllers
{
    [ApiController]
    public class TestController : BaseController<Settings, SettingsDto, string>
    {
        public TestController(IService<Settings, SettingsDto, string> service) : base(service)
        {
        }

       
    }
}
