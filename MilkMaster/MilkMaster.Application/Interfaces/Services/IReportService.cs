using MilkMaster.Application.DTOs;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IReportService
    {
        Task<byte[]> GenerateReport(SalesReportOptionsDto options);
    }
}
