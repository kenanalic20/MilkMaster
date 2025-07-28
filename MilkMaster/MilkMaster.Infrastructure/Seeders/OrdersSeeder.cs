using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using MilkMaster.Application.Filters;

namespace MilkMaster.Infrastructure.Seeders;

public class OrdersSeeder
{
    private readonly IOrdersService _ordersService;
    private readonly IProductsService _productsService;
    private readonly UserManager<IdentityUser> _userManager;

    public OrdersSeeder(
        IOrdersService ordersService,
        IProductsService productsService,
        UserManager<IdentityUser> userManager)
    {
        _ordersService = ordersService;
        _productsService = productsService;
        _userManager = userManager;
    }

    public async Task SeedOrdersAsync()
    {
        _ordersService.EnableSeedingMode();
        var users = await _userManager.Users.ToListAsync();
        var products = await _productsService.GetAllAsync(null); 

        if (!users.Any() || !products.Any())
            throw new Exception("No users or products found. Ensure users and products are seeded before orders.");

        var random = new Random();
        
        foreach (var user in users)
        {
            for (int i = 0; i < random.Next(1, 3); i++)
            {
                var selectedProducts = products.OrderBy(_ => random.Next()).Take(2).ToList();

                var orderItems = selectedProducts.Select(p => new OrderItemsCreateDto
                {
                    ProductId = p.Id,
                    Quantity = random.Next(1, 2), 
                    UnitSize = 1 
                }).ToList();

                var order = new OrdersSeederDto
                {
                    UserId = user.Id,
                    OrderNumber = await _ordersService.GenerateOrderNumberAsync(),
                    Customer = $"{user.UserName}",
                    Email = user.Email!,
                    PhoneNumber = user.PhoneNumber ?? "Phone number not set",
                    Items = orderItems,
                    CreatedAt = DateTime.UtcNow,
                    Total = orderItems.Sum(item => item.Quantity * selectedProducts.First(p => p.Id == item.ProductId).PricePerUnit),
                    ItemCount = orderItems.Count,
                    StatusId = 1 
                };

                await _ordersService.CreateAsync(order);
            }
        }
    }
}
