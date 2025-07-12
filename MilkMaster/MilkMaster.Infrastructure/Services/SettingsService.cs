using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Common;
using AutoMapper;

namespace MilkMaster.Infrastructure.Services
{
    public class SettingsService : BaseService<Settings, SettingsDto, SettingsCreateDto, SettingsUpdateDto, string>, ISettingsService
    {
        private readonly ISettingsRepository _settingsRepository;

        public SettingsService(ISettingsRepository settingsRepository, IMapper mapper)
            : base(settingsRepository, mapper)
        {
            _settingsRepository = settingsRepository;
        }

        public override async Task<SettingsDto> GetByIdAsync(string id)
        {
            var settings = await _settingsRepository.GetByIdAsync(id);

            if (settings == null)
                throw new KeyNotFoundException("Settings not found");

            var dto = _mapper.Map<SettingsDto>(settings);
            return dto;
        }
    }
}
