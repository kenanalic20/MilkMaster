using MilkMaster.Application.DTOs;
using MilkMaster.Application.Filters;
using MilkMaster.Domain.Models;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface ISettingsService : IService<Settings, SettingsDto, SettingsCreateDto, SettingsUpdateDto, EmptyQueryFilter,string>
    {
    }
}
