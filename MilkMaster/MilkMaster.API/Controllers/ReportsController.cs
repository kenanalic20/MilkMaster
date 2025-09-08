using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")] 
    public class ReportsController : ControllerBase
    {
        private readonly IReportService _reportService;

        public ReportsController(IReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpPost("download")]
        public async Task<IActionResult> DownloadReport([FromBody] SalesReportOptionsDto options)
        {
            if (options == null)
                return BadRequest("Report options are required.");

            var pdfBytes = await _reportService.GenerateReport(options);

            // Return as downloadable file
            return File(pdfBytes, "application/pdf", $"SalesReport-{options.Name}.pdf");
        }
    }
}
