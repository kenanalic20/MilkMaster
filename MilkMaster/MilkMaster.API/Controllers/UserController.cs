using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.Common;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.API.Controllers
{
    [Route("[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
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
        [HttpGet]
        public async Task<ActionResult<PagedResult<UserDto>>> GetUsers([FromQuery] UserQueryFilter? filter = null)
        {
            var result = await _userService.GetAllUsersAsync(filter);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            var result = await _userService.GetByIdAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUserCredentials(string id,[FromBody] UserAdminDto dto)
        {
            var result = await _userService.UpdateUserCredentialsAsync(id,dto);
            if (!result)
                return BadRequest("Could not update user credentials.");
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var result = await _userService.DeleteUserAsync(id);
            if (!result)
                return BadRequest("Failed to delete user.");
            return NoContent();
        }

    }
}
