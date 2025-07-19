using Microsoft.Extensions.Configuration;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Seeders
{
    public class CattleCategoriesSeeder
    {
        private readonly ICattleCategoriesService _cattleCategoriesService;
        private readonly string _baseUrl;

        public CattleCategoriesSeeder(
            ICattleCategoriesService cattleCategoriesService,
            IConfiguration configuration
            )
        {
            _cattleCategoriesService = cattleCategoriesService;
            _baseUrl = configuration["APP_BASE_URL"] ?? "http://localhost:5068";
        }   

        public async Task SeedCattleCategoriesAsync()
        {
            _cattleCategoriesService.EnableSeedingMode();
            var defaultCategories = new List<CattleCategoriesCreateDto>
            {
                new CattleCategoriesCreateDto
                {
                    Title = "Check out our cows",
                    Name = "Cows",
                    Description = "Meet our friendly cows – they're ready to say moo!",
                    ImageUrl = $"{_baseUrl}/Images/Categories/CowLogo.png"
                },
                new CattleCategoriesCreateDto
                {
                    Title = "Check out our goats",
                    Name = "Goats",
                    Description = "Our goats are full of energy – see them for yourself!",
                    ImageUrl = $"{_baseUrl}/Images/Categories/GoatLogo.png"
                },
                new CattleCategoriesCreateDto
                {
                    Title = "Check out our sheep",
                    Name = "Sheep",
                    Description = "Meet our woolly friends – our sheep are waiting for you!",
                    ImageUrl = $"{_baseUrl}/Images/Categories/SheepLogo.png"
                },

            };

            foreach (var category in defaultCategories)
            {
                await _cattleCategoriesService.CreateAsync(category);
            }
        }

    }
}
