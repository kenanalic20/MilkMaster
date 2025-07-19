using MilkMaster.Application.DTOs;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IGeneralSearchService
    {
        Task<GeneralSearchResultDto> GeneralSearchAsync(string query);
    }
}
