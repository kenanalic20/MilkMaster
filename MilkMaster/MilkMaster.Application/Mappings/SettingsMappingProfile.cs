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
            CreateMap<Settings, SettingsDto>()
                .ForMember(dest => dest.PushNotificationsEnabled, opt => opt.MapFrom(src => src.PushNotificationsEnabled))
                .ForMember(dest => dest.NotificationsEnabled, opt => opt.MapFrom(src => src.NotificationsEnabled));
        }
    }
}
