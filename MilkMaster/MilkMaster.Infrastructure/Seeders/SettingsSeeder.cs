
using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;


namespace MilkMaster.Infrastructure.Seeders
{
    public class SettingsSeeder
    {
        private readonly IService<Settings, SettingsCreateDto ,string> _service;

        public SettingsSeeder(IService<Settings, SettingsCreateDto, string> service)
        {
            _service = service;
        }

        public async Task SeedSettingsAsync(string userId)
        {
            var defaultSettingsDto = new SettingsCreateDto
            {
                UserId = userId,
                PushNotificationsEnabled = true,
                NotificationsEnabled = true,
            };
            await _service.CreateAsync(defaultSettingsDto,false);
        }   
    }
}
