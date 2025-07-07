using Microsoft.AspNetCore.Http;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IFileService
    {
        Task<string> SaveFileAsync(IFormFile file, string subfolder, string[] allowedExtensions);
        Task<string> UpdateFileAsync(IFormFile newFile, string existingFilePath, string subfolder, string[]? allowedExtensions = null);
        Task<bool> DeleteFileAsync(string fileUrl, string subfolder);
    }
}
