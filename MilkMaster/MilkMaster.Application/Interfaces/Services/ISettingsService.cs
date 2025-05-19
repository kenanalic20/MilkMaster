using MilkMaster.Application.DTOs;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface ISettingsService : IService<Settings, SettingsDto, string>
    {
    }
}
