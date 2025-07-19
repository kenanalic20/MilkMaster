﻿using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;

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
            var token = await _authService.RegisterAsync(register);
            return Ok(new { token });
        }
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto login)
        {
            var token = await _authService.LoginAsync(login);
            return Ok(new { token });
        }

        [Authorize]
        [HttpGet("user")]
        public async Task<IActionResult> GetUser()
        {
            var userDto = await _authService.GetUserAsync(User);
            return Ok(new { user = userDto });
        }
        //temporary
        [HttpGet("RabbitMq")]
        public async Task<IActionResult> RabbitMQPublisher()
        {
            var message = new SettingsCreateDto
            {
                NotificationsEnabled = true,
                PushNotificationsEnabled = true
            };
            
            await _rabbitMqPublisher.PublishAsync(message);

            return Ok("Message published to RabbitMQ");
        }

    }
}
