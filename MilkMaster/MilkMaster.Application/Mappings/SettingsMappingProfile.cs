using AutoMapper;
using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Mappings
{
    public class SettingsMappingProfile:Profile
    {
        public SettingsMappingProfile() 
        {
            CreateMap<SettingsCreateDto, Settings>();
            CreateMap<Settings, SettingsDto>();
            CreateMap<SettingsDto, Settings>();

        }
    }
}
