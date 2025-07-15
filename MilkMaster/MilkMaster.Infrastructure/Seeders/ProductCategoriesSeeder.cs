using Microsoft.Extensions.Configuration;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Seeders
{
    public class ProductCategoriesSeeder
    {
        private readonly IProductCategoriesService _productCategoriesService;
        private readonly string _baseUrl;

        public ProductCategoriesSeeder(
            IProductCategoriesService productCategoriesService,
            IConfiguration configuration
            )
        {
            _productCategoriesService = productCategoriesService;
            _baseUrl = configuration["APP_BASE_URL"] ?? "http://localhost:5068";
        }   

        public async Task SeedProductCategoriesAsync()
        {
            _productCategoriesService.EnableSeedingMode();
            var defaultCategories = new List<ProductCategoriesCreateDto>
            {
                new ProductCategoriesCreateDto
                {
                    Name = "Milk",
                    ImageUrl = $"{_baseUrl}/Images/Categories/MilkLogo_White.png"
                },
                new ProductCategoriesCreateDto
                {
                    Name = "Yogurt",
                    ImageUrl = $"{_baseUrl}/Images/Categories/YogurtLogo_White.png"
                },
                new ProductCategoriesCreateDto
                {
                    Name = "Butter",
                    ImageUrl = $"{_baseUrl}/Images/Categories/ButterLogo_White.png"
                },
                new ProductCategoriesCreateDto
                {
                    Name = "Cheese",
                    ImageUrl = $"{_baseUrl}/Images/Categories/CheeseLogo_White.png"
                },
            };

            foreach (var category in defaultCategories)
            {
                await _productCategoriesService.CreateAsync(category);
            }
        }

    }
}
