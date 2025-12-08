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
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult<PagedResult<UserDto>>> GetUsers([FromQuery] UserQueryFilter? filter = null)
        {
            var result = await _userService.GetAllUsersAsync(filter);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
        [HttpGet("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetById(string id)
        {
            var result = await _userService.GetByIdAsync(id);
            if (result == null)
                return NotFound();
            return Ok(result);
        }
        [HttpPut("{id}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UpdateUserCredentials(string id,[FromBody] UserAdminDto dto)
        {
            var result = await _userService.UpdateUserCredentialsAsync(id,dto);
            if (!result)
                return BadRequest("Could not update user credentials.");
            return NoContent();
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var result = await _userService.DeleteUserAsync(id);
            if (!result)
                return BadRequest("Failed to delete user.");
            return NoContent();
        }

        [HttpPut("{id}/phone")]
        [Authorize]
        public async Task<IActionResult> UpdatePhoneNumber(string id, [FromBody] UpdatePhoneNumberDto dto)
        {
            var result = await _userService.UpdatePhoneNumberAsync(id, dto.PhoneNumber);
            if (!result)
                return BadRequest("Failed to update phone number.");
            return Ok(new { message = "Phone number updated successfully. Confirmation email sent." });
        }

        [HttpPut("{id}/email")]
        [Authorize]
        public async Task<IActionResult> UpdateEmail(string id, [FromBody] UpdateEmailDto dto)
        {
            var result = await _userService.UpdateEmailAsync(id, dto.Email);
            if (!result)
                return BadRequest("Failed to update email. Email may already be in use.");
            return Ok(new { message = "Email updated successfully. Confirmation emails sent to both old and new addresses." });
        }

    }
}
