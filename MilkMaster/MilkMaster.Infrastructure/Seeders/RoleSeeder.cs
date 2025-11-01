using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using MilkMaster.Domain.Models;


namespace MilkMaster.Infrastructure.Seeders
{
    public class RoleSeeder
    {
        private readonly RoleManager<Role> _roleManager;
        private readonly ILogger<RoleSeeder> _logger;
        public RoleSeeder(RoleManager<Role> roleManager, ILogger<RoleSeeder> logger)
        {
            _roleManager = roleManager;
            _logger = logger;
        }

        public async Task SeedRolesAsync()
        {
            var roles = new List<string> { "Admin", "User" };

            foreach (var roleName in roles)
            {
                if (!await _roleManager.RoleExistsAsync(roleName))
                {
                    var role = new Role { Name = roleName };
                    var result = await _roleManager.CreateAsync(role);

                    if (result.Succeeded)
                        _logger.LogInformation($"Role {roleName} created successfully.");
                    else
                        _logger.LogError($"Error creating role {roleName}: {string.Join(", ", result.Errors.Select(e => e.Description))}");
                }
            }
        }


    }
}
