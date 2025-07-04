using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using MilkMaster.Application.Interfaces.Services;

namespace MilkMaster.Infrastructure.Services
{
    public class ImageService:IImageService
    {
        private readonly string _baseUrl;
        private readonly string _webRootPath;

        public ImageService(IWebHostEnvironment env, IConfiguration config)
        {
            _webRootPath = env.WebRootPath;
            _baseUrl = config["APP_BASE_URL"] ?? "http://localhost:5068";
        }

        public async Task<string> SaveImageAsync(IFormFile imageFile, string subfolder)
        {
            if (imageFile == null || imageFile.Length==0)
            {
                return null;
            }

            var uploadPath = Path.Combine(_webRootPath, "Images", subfolder);

            if (!Directory.Exists(uploadPath))
            {
                Directory.CreateDirectory(uploadPath);
            }

            var uniqueFileName = $"{Guid.NewGuid()}_{imageFile.FileName}";
            var filePath = Path.Combine(uploadPath, uniqueFileName);

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
               await imageFile.CopyToAsync(fileStream);
            }

            var imageUrl = $"{_baseUrl}/Images/{subfolder}/{uniqueFileName}";

            return imageUrl;
        }

        public async Task<string> UpdateImageAsync(IFormFile newImageFile, string existingImagePath, string subfolder)
        {

            if (!string.IsNullOrEmpty(existingImagePath))
            {
                DeleteImage(existingImagePath, subfolder);
            }


            return await SaveImageAsync(newImageFile, subfolder);
        }

        public bool DeleteImage(string imageUrl, string subfolder)
        {
            var fileName = Path.GetFileName(imageUrl);
            var fullPath = Path.Combine(_webRootPath, "Images", subfolder, fileName);

            if (File.Exists(fullPath))
            {
                File.Delete(fullPath);
                return true;
            }

            return false;
        }
    }
}
