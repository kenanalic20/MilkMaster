using Microsoft.AspNetCore.Http;

namespace MilkMaster.Application.DTOs
{
    public class FileDto
    {
        public IFormFile? File { get; set; }
        public string Subfolder { get; set; } = "General";
    }
    public class FileUpdateDto : FileDto
    {
        public string? OldFileUrl { get; set; }
    }
    public class FileDeleteDto
    {
        public string FileUrl { get; set; } = string.Empty;
        public string Subfolder { get; set; } = "General";
    }
}
