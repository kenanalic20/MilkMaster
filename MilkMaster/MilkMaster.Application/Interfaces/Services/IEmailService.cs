using MilkMaster.Messages;

namespace MilkMaster.Application.Interfaces.Services
{
    public interface IEmailService
    {
        Task SendEmailAsync(string userId, EmailMessage message);
    }
}
