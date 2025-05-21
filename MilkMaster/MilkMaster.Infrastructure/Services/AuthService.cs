using Microsoft.AspNetCore.Identity;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Application.DTOs;
using System.Security.Claims;
using MilkMaster.Application.Common;
using AutoMapper;
using MilkMaster.Infrastructure.Seeders;

namespace MilkMaster.Infrastructure.Services
{
    public class AuthService : IAuthService
    {
        private readonly UserManager<IdentityUser> _userManager;
        private readonly RoleManager<IdentityRole> _roleManager;
        private readonly SettingsSeeder _settingsSeeder;
        private readonly IJwtService _jwtService;
        private readonly IMapper _mapper;

        public AuthService(
            UserManager<IdentityUser> userManager,
            RoleManager<IdentityRole> roleManager,
            SettingsSeeder settingsSeeder,
            IJwtService jwtService, 
            IMapper mapper
        )
        {
            _userManager = userManager;
            _roleManager = roleManager;
            _settingsSeeder = settingsSeeder;
            _jwtService = jwtService;
            _mapper = mapper;
        }
        public async Task<ServiceResponse<string>> RegisterAsync(RegisterDto register)
        {
            string username = register.Email.Split('@')[0];

            var user = new IdentityUser
            {
                UserName = username,
                Email = register.Email,
            };

            var result = await _userManager.CreateAsync(user, register.Password);

            if (!result.Succeeded)
            {
                string errorMessage = result.Errors.FirstOrDefault()?.Description ?? "Bad Request";

                return ServiceResponse<string>.FailureResponse(errorMessage);
            }

            string role = register.Platform.ToLower() == "desktop" ? "Admin" : "User";

            if (!await _roleManager.RoleExistsAsync(role))
                await _roleManager.CreateAsync(new IdentityRole(role));

            await _userManager.AddToRoleAsync(user, role);

            await _settingsSeeder.SeedSettingsAsync(user.Id);

            var token = await _jwtService.GenerateJwtToken(user);

            return ServiceResponse<string>.SuccessResponse(token, result.Succeeded.ToString());
        }

        public async Task<ServiceResponse<string>> LoginAsync(LoginDto login)
        {
            var user = await _userManager.FindByEmailAsync(login.Email);
            if (user == null)
                return ServiceResponse<string>.FailureResponse("User not found", 404);

            var result = await _userManager.CheckPasswordAsync(user, login.Password);
            if (!result)
                return ServiceResponse<string>.FailureResponse("Invalid password", 401);

            var token = await _jwtService.GenerateJwtToken(user);

            return ServiceResponse<string>.SuccessResponse(token);
        }

        public async Task<ServiceResponse<UserDto>> GetUserAsync(ClaimsPrincipal userPrincipal)
        {
            var userId = userPrincipal.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(userId))
                return ServiceResponse<UserDto>.FailureResponse("User not authenticated", 401);

            var user = await _userManager.FindByIdAsync(userId);
            if (user == null || user.UserName == null || user.Email == null)
                return ServiceResponse<UserDto>.FailureResponse("User not found", 404);

            var roles = await _userManager.GetRolesAsync(user);

            if (roles == null || roles.Count == 0)
                return ServiceResponse<UserDto>.FailureResponse("User has no roles", 400);
            
            var userDetails = _mapper.Map<UserDto>(user);

            userDetails.Roles = roles;

            return ServiceResponse<UserDto>.SuccessResponse(userDetails);
        }
    }
}
