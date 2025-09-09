using Microsoft.AspNetCore.Identity;
using MilkMaster.Domain.Models;

public class IdentitySeeder
{
    private readonly UserManager<User> _userManager;
    private readonly RoleManager<IdentityRole> _roleManager;

    public IdentitySeeder(UserManager<User> userManager, RoleManager<IdentityRole> roleManager)
    {
        _userManager = userManager;
        _roleManager = roleManager;
    }

    public async Task SeedUsersAsync()
    {
        var roles = new[] { "Admin", "User" };

        foreach (var role in roles)
        {
            if (!await _roleManager.RoleExistsAsync(role))
                await _roleManager.CreateAsync(new IdentityRole(role));
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
            }
        }
    }
}
