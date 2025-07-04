using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class ImageController : ControllerBase
    {
        private readonly IImageService _imageService;
        public ImageController(IImageService imageService)
        {
            _imageService = imageService;
        }

        [HttpPost]
        public async Task<IActionResult> UploadImage([FromForm] ImageDto dto)
        {
            if (dto.ImageFile == null || dto.ImageFile.Length == 0)
            {
                return BadRequest("No file uploaded.");
            }

            var permittedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            var extension = Path.GetExtension(dto.ImageFile.FileName).ToLowerInvariant();

            if (string.IsNullOrEmpty(extension) || !permittedExtensions.Contains(extension))
            {
                return BadRequest("Invalid image file type.");
            }

            var permittedMimeTypes = new[] { "image/jpeg", "image/png", "image/gif" };
            if (!permittedMimeTypes.Contains(dto.ImageFile.ContentType))
            {
                return BadRequest("Invalid image MIME type.");
            }

            var imageUrl = await _imageService.SaveImageAsync(dto.ImageFile, dto.Subfolder);

            if (string.IsNullOrEmpty(imageUrl))
            {
                return StatusCode(500, "Error saving image.");
            }

            return Ok(new { ImageUrl = imageUrl });
        }
        

    }
}
