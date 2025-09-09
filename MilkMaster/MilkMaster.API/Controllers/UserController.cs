using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Common;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;

namespace MilkMaster.API.Controllers
{
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;
        public UserController
        (
            IUserService userService    
        ) 
        {
            _userService = userService;
        }
        [HttpGet("users")]
        public async Task<ActionResult<PagedResult<User>>> GetUsers([FromQuery] UserQueryFilter? filter = null)
        {
            var result = await _userService.GetAllUsersAsync(filter);
            return Ok(result);
        }
    }
}
