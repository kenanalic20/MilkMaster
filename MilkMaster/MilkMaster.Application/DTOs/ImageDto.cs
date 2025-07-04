using Microsoft.AspNetCore.Http;

namespace MilkMaster.Application.DTOs
{
    public class ImageDto
    {
        public IFormFile ImageFile { get; set; }
        public string Subfolder { get; set; } = "General";
    }
}
