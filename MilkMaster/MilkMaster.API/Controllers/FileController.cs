using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MilkMaster.Application.DTOs;
using MilkMaster.Application.Interfaces.Services;
using System.Security.Claims;

namespace MilkMaster.API.Controllers
{
    [Authorize]
    [ApiController]
    [Route("[controller]")]
    public class FileController : ControllerBase
    {
        private readonly IFileService _fileService;
        private readonly IAuthService _authService;
        private static readonly string[] AllowedImageExtensions = [".jpg", ".jpeg", ".png"];
        private static readonly string[] AllowedPdfExtensions = [".pdf"];
        public FileController(IFileService fileService, IAuthService authService)
        {
            _fileService = fileService;
            _authService = authService;
        }
        [HttpPost]
        public async Task<IActionResult> UploadFile([FromForm] FileDto dto)
        {
            var isPdf = dto.File?.FileName?.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase)??false;
            var isAdmin = await _authService.IsAdminAsync(User);

            if (isPdf && !isAdmin)
            {
                return StatusCode(StatusCodes.Status403Forbidden, "Only admins can upload PDF files.");
            }

            var allowed = isPdf ? AllowedPdfExtensions : AllowedImageExtensions;

            if (dto.File == null)
                return BadRequest("File is required.");

            var url = await _fileService.SaveFileAsync(dto.File, dto.Subfolder, allowed);

            if (url == null)
                return BadRequest("Invalid file or unsupported format.");

            return Ok(new { FileUrl = url });
        }
        [HttpDelete("delete")]
        public async Task<IActionResult> DeleteFile([FromForm]FileDeleteDto dto)
        {
            var isAdmin = await _authService.IsAdminAsync(User);
            var extension = Path.GetExtension(dto.FileUrl)?.ToLower();

            var isPdf = extension == ".pdf";

            if (isPdf && !isAdmin)
            {
                return StatusCode(StatusCodes.Status403Forbidden, "Only admins can upload PDF files.");
            }

            var success = await _fileService.DeleteFileAsync(dto.FileUrl, dto.Subfolder);

            if (!success)
                return NotFound("File not found.");

            return Ok("File deleted successfully.");
        }

        [HttpPut("update")]
        public async Task<IActionResult> UpdateFile([FromForm] FileUpdateDto dto)
        {
            var isAdmin = await _authService.IsAdminAsync(User);

            if(dto.File==null)
                return BadRequest("File is required for update.");

            var extension = Path.GetExtension(dto.File.FileName).ToLower();
            var allowed = extension == ".pdf" ? AllowedPdfExtensions : AllowedImageExtensions;

            var isPdf = extension == ".pdf";
            if (isPdf && !isAdmin)
            {
                return StatusCode(StatusCodes.Status403Forbidden, "Only admins can upload PDF files.");
            }

            if (dto.OldFileUrl == null)
                return BadRequest();

            var url = await _fileService.UpdateFileAsync(dto.File, dto.OldFileUrl, dto.Subfolder, allowed);
            if (url == null)
                return BadRequest("Update failed. Check file type or path.");

            return Ok(new { FileUrl = url });
        }
    }
}
