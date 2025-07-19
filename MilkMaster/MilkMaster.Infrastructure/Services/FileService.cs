using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Services
{
    public class FileService:IFileService
    {
        private readonly string _baseUrl;
        private readonly string _webRootPath;

        public FileService(IWebHostEnvironment env, IConfiguration config)
        {
            _webRootPath = env.WebRootPath;
            _baseUrl = config["APP_BASE_URL"] ?? "http://localhost:5068";
        }

        public async Task<string> SaveFileAsync(IFormFile file, string subfolder, string[]? allowedExtensions = null)
        {
            if (file == null || file.Length == 0)
                return null;

            var extension = Path.GetExtension(file.FileName);
            if (allowedExtensions != null && !allowedExtensions.Contains(extension.ToLower()))
                return null;

            var uploadPath = Path.Combine(_webRootPath, subfolder);
            if (!Directory.Exists(uploadPath))
                Directory.CreateDirectory(uploadPath);

            var uniqueFileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(uploadPath, uniqueFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            var fileUrl = $"{_baseUrl}/{subfolder.Replace("\\", "/")}/{uniqueFileName}";
            return fileUrl;
        }

        public async Task<string> UpdateFileAsync(IFormFile newFile, string existingFilePath, string subfolder, string[]? allowedExtensions = null)
        {
            if (!string.IsNullOrEmpty(existingFilePath))
            {
                await DeleteFileAsync(existingFilePath, subfolder);
            }

            return await SaveFileAsync(newFile, subfolder, allowedExtensions);
        }

        public async Task<bool> DeleteFileAsync(string fileUrl, string subfolder)
        {
            if (string.IsNullOrEmpty(fileUrl))
                return false;

            var fileName = Path.GetFileName(fileUrl);
            var fullPath = Path.Combine(_webRootPath, subfolder, fileName);

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
                return true;
            }

            return false;
        }
    }
}
