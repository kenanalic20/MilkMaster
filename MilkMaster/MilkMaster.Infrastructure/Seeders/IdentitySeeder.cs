using Microsoft.AspNetCore.Identity;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;
using MilkMaster.Infrastructure.Seeders;

public class IdentitySeeder
{
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<Role> _roleManager;
    private readonly SettingsSeeder _settingsSeeder;

    public IdentitySeeder(
        UserManager<User> userManager, 
        RoleManager<Role> roleManager, 
        SettingsSeeder settingsSeeder)
    {
        _userManager = userManager;
        _roleManager = roleManager;
        _settingsSeeder = settingsSeeder;
    }

    public async Task SeedUsersAsync()
    {
        
        var roles = new[] { "Admin", "User" };

        foreach (var role in roles)
        {
            if (!await _roleManager.RoleExistsAsync(role))
                await _roleManager.CreateAsync(new Role { Name=role });
        }

        var adminEmail = "admin@milk.com";
        var adminUser = await _userManager.FindByEmailAsync(adminEmail);
        if (adminUser == null)
        {
            adminUser = new User
            {
                UserName = "desktop",
                Email = adminEmail,
                EmailConfirmed = true
            };
            await _userManager.CreateAsync(adminUser, "Test1234!");
            await _userManager.AddToRoleAsync(adminUser, "Admin");
        }

        var userEmail = "user@milk.com";
        var appUser = await _userManager.FindByEmailAsync(userEmail);
        if (appUser == null)
        {
            appUser = new User
            {
                UserName = "mobile",
                Email = userEmail,
                EmailConfirmed = true
            };
            await _userManager.CreateAsync(appUser, "Test1234!");
            await _userManager.AddToRoleAsync(appUser, "User");
            await _settingsSeeder.SeedSettingsAsync(appUser.Id);
        }

        for (var i = 0; i < 9; i++) 
        {
            var userEmailLoop = $"user{i+1}@milk.com";
            var appUserLoop = await _userManager.FindByEmailAsync(userEmailLoop);
            if (appUserLoop == null)
            {
                appUserLoop = new User
                {
                    UserName = $"mobile{i+1}",
                    Email = userEmailLoop,
                    EmailConfirmed = true
                };
                await _userManager.CreateAsync(appUserLoop, "Test1234!");
                await _userManager.AddToRoleAsync(appUserLoop, "User");
                await _settingsSeeder.SeedSettingsAsync(appUserLoop.Id);
            }
        }
    }
}
