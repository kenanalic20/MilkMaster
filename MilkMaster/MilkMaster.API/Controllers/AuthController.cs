using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.IdentityModel.Tokens;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Win32;

namespace MilkMaster.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly IRabbitMqPublisher _rabbitMqPublisher;
        public AuthController(
            IAuthService authService,
            IRabbitMqPublisher rabbitMqPublisher
        )
        {
            _authService = authService;
            _rabbitMqPublisher = rabbitMqPublisher;
        }
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto register)
        {
           var response = await _authService.RegisterAsync(register);

           if(!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Ok(response.Data);
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto login)
        {
            var response = await _authService.LoginAsync(login);
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Ok(response.Data);
        }
        //Temporary
        [Authorize]
        [HttpGet("user")]
        public async Task<IActionResult> GetUser()
        {
            var response = await _authService.GetUserAsync(HttpContext.User);
            if (!response.Success)
                return StatusCode(response.StatusCode, response.Message);

            return Ok(response.Data);
        }

        [HttpGet("RabbitMq")]
        public async Task<IActionResult> RabbitMQPublisher()
        {
            var message = new SettingsDto
            {
                NotificationsEnabled = true,
                PushNotificationsEnabled = true
            };
            await _rabbitMqPublisher.PublishAsync(message);

            return Ok("Message published to RabbitMQ");
        }

    }
}
