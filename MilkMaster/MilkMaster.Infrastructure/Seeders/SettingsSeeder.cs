using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;


namespace MilkMaster.Infrastructure.Seeders
{
    public class SettingsSeeder
    {
        private readonly ISettingsService _settingsService;
        public SettingsSeeder(ISettingsService settingsService)
        {
            _settingsService = settingsService;
        }

        public async Task SeedSettingsAsync(string userId)
        {
            var defaultSettingsDto = new SettingsCreateDto
            {
                UserId = userId,
                PushNotificationsEnabled = true,
                NotificationsEnabled = true,
            };
            await _settingsService.CreateAsync(defaultSettingsDto);
        }   
    }
}
