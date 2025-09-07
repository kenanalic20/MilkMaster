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
            for (int i = 0; i < 2; i++)
            {
                var selectedProducts = products.OrderBy(_ => random.Next()).Take(2).ToList();
                var quantity = random.Next(1, 5);
                var pricePerUnit = random.Next(1, 5);
                var statusId = random.Next(1, 5);
                Console.WriteLine($"Test for order seeder: {quantity}, {pricePerUnit}, {statusId} ");
                var orderItems = selectedProducts.Select(p => new OrderItemsSeederDto
                {
                    ProductId = p.Id,
                    Quantity = quantity, 
                    UnitSize = 1,
                    PricePerUnit = pricePerUnit,
                    TotalPrice = quantity * pricePerUnit,
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
                    StatusId = statusId
                };

                await _ordersService.CreateAsync(order);
            }
        }
    }
}
