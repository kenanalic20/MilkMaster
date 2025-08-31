using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;

namespace MilkMaster.Infrastructure.Seeders
{
    public class CattleSeeder
    {
        private readonly ICattleService _cattleService;
        private readonly IConfiguration _configuration;
        private readonly string _baseUrl;

        public CattleSeeder(
            ICattleService cattleService,
            IConfiguration configuration)
        {
            _cattleService = cattleService;
            _configuration = configuration;
            _baseUrl = _configuration["APP_BASE_URL"] ?? "http://localhost:5068";
        }

        public async Task SeedCattleAsync()
        {
             _cattleService.EnableSeedingMode();
            var cattleToSeed = new List<CattleCreateDto>
            {
                new CattleSeederDto
                {
                    Name = "Bella",
                    ImageUrl = $"{_baseUrl}/Images/Cattle/Cow.png",
                    MilkCartonUrl = $"{_baseUrl}/Documents/MilkCartons/BellaCarton.pdf",
                    CattleCategoryId = 1,
                    BreedOfCattle = "Holstein",
                    TagNumber = "s03Um",
                    LitersPerDay = 15.5f,
                    MonthlyValue = 450.0f,
                    BirthDate = new DateTime(2018, 3, 15),
                    HealthCheck = DateTime.Today.AddMonths(-1),
                    Age = 4,
                    Overview = new CattleOverviewDto
                    {
                        Description = "Healthy and productive dairy cow.",
                        Weight = 700f,
                        Height = 150f,
                        Diet = "Hay, grains, and fresh grass"
                    },
                    BreedingStatus = new BreedingStatusDto
                    {
                        PragnancyStatus = true,
                        LastCalving = new DateTime(2023, 5, 10),
                        NumberOfCalves = 2
                    }
                },
                new CattleSeederDto
                {
                    Name = "Daisy",
                    ImageUrl = $"{_baseUrl}/Images/Cattle/Goat.png",
                    MilkCartonUrl = $"{_baseUrl}/Documents/MilkCartons/BellaCarton.pdf",
                    CattleCategoryId = 2,
                    BreedOfCattle = "Nubian",
                    TagNumber = "i6Vft",
                    LitersPerDay = 8.2f,
                    MonthlyValue = 250.0f,
                    BirthDate = new DateTime(2020, 7, 10),
                    HealthCheck = DateTime.Today.AddMonths(-2),
                    Age = 2,
                    Overview = new CattleOverviewDto
                    {
                        Description = "Young and energetic goat.",
                        Weight = 400f,
                        Height = 120f,
                        Diet = "Fresh grass and grains"
                    },
                    BreedingStatus = new BreedingStatusDto
                    {
                        PragnancyStatus = false,
                        LastCalving = new DateTime(2022, 11, 20),
                        NumberOfCalves = 1
                    }
                },
                new CattleSeederDto
                {
                    Name = "Molly",
                    ImageUrl = $"{_baseUrl}/Images/Cattle/Sheep.png",
                    MilkCartonUrl = $"{_baseUrl}/Documents/MilkCartons/BellaCarton.pdf",
                    CattleCategoryId = 3,
                    BreedOfCattle = "Jersey",
                    TagNumber = "io3TD",
                    LitersPerDay = 12.0f,
                    MonthlyValue = 380.0f,
                    BirthDate = new DateTime(2019, 10, 5),
                    HealthCheck = DateTime.Today.AddMonths(-3),
                    Age = 3,
                    Overview = new CattleOverviewDto
                    {
                        Description = "Reliable milk producer.",
                        Weight = 650f,
                        Height = 145f,
                        Diet = "Hay and silage"
                    },
                    BreedingStatus = new BreedingStatusDto
                    {
                        PragnancyStatus = true,
                        LastCalving = new DateTime(2023, 1, 15),
                        NumberOfCalves = 3
                    }
                }
            };

            foreach (var cattle in cattleToSeed)
            {
                await _cattleService.CreateAsync(cattle);
            }
        }
    }
}
