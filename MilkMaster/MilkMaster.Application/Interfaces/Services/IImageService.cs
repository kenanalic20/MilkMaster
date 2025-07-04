using Microsoft.AspNetCore.Http;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IImageService
    {
        Task<string> SaveImageAsync(IFormFile imageFile, string subfolder);
        Task<string> UpdateImageAsync(IFormFile newImageFile, string existingImagePath, string subfolder);
        bool DeleteImage(string imageUrl, string subfolder);
    }
}
