
using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Domain.Models;


namespace MilkMaster.Infrastructure.Seeders
{
    public class SettingsSeeder
    {
        private readonly IMapper _mapper;
        private readonly IRepository<Settings, string> _repository;

        public SettingsSeeder(IMapper mapper, IRepository<Settings, string> repository)
        {
            _mapper = mapper;
            _repository = repository;
        }

        public async Task SeedSettingsAsync(string userId)
        {
            var defaultSettingsDto = new SettingsCreateDto
            {
                UserId = userId,
                PushNotificationsEnabled = true,
                NotificationsEnabled = true,
            };
            var entity = _mapper.Map<Settings>(defaultSettingsDto);
            await _repository.AddAsync(entity);
        }   
    }
}
