using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;

namespace MilkMaster.Infrastructure.Seeders
{
    public class ProductsSeeder
    {
        private readonly IProductsService _productsService;
        private readonly string _baseUrl;

        public ProductsSeeder(
            IProductsService productsService,
            IConfiguration configuration)
        {
            _productsService = productsService;
            _baseUrl = configuration["APP_BASE_URL"] ?? "http://localhost:5068";
        }

        public async Task SeedProductsAsync()
        {
            _productsService.EnableSeedingMode();

            var defaultProducts = new List<ProductsCreateDto>
            {
                new ProductsCreateDto
                {
                    Title = "Fresh Cow Milk",
                    ImageUrl = $"{_baseUrl}/Images/Products/Milk.jpg",
                    CattleCategoryId = 1,
                    UnitId = 1,
                    PricePerUnit = 2.5m,
                    Quantity = 100,
                    Description = "Locally sourced organic cow milk.",
                    ProductCategories = new List<int> { 1 }
                },
                new ProductsCreateDto
                {
                    Title = "Goat Cheese",
                    ImageUrl = $"{_baseUrl}/Images/Products/Cheese.jpg",
                    CattleCategoryId = 2,
                    UnitId = 2,
                    PricePerUnit = 12.0m,
                    Quantity = 30,
                    Description = "Soft and creamy goat cheese.",
                    ProductCategories = new List<int> { 4 } 
                },
                new ProductsCreateDto
                {
                    Title = "Goat Butter",
                    ImageUrl = $"{_baseUrl}/Images/Products/Butter.jpg",
                    CattleCategoryId = 2,
                    UnitId = 2,
                    PricePerUnit = 12.0m,
                    Quantity = 30,
                    Description = "Soft and creamy goat cheese.",
                    ProductCategories = new List<int> { 1,2,4 }
                }
            };

            for(int i = 0; i<7; i++)
            {
                defaultProducts.Add(new ProductsCreateDto
                {
                    Title = $"Product {i + 1}",
                    ImageUrl = $"{_baseUrl}/Images/Products/Cheese{i+1}.jpg",
                    CattleCategoryId = 1,
                    UnitId = 1,
                    PricePerUnit = 5.0m + i,
                    Quantity = 2*i,
                    Description = $"Description for Product {i + 1}",
                    ProductCategories = new List<int> { 1, 2 }
                });
            }

            foreach (var product in defaultProducts)
            {
                await _productsService.CreateAsync(product);
            }
        }
    }
}
