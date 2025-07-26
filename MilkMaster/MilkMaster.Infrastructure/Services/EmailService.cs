
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Messages;

namespace MilkMaster.Infrastructure.Services
{
    public class EmailService : IEmailService
    {
        private readonly ISettingsRepository _settingsRepository;
        private readonly IRabbitMqPublisher _rabbitMqPublisher;
        public EmailService
        (
            ISettingsRepository settingsRepository,
            IRabbitMqPublisher rabbitMqPublisher 
        )
        {
            _settingsRepository = settingsRepository;
            _rabbitMqPublisher = rabbitMqPublisher;
        }

        public async Task SendEmailAsync(string userId, EmailMessage message)
        {
            var settings = await _settingsRepository.GetByIdAsync(userId);

            if (settings == null)
                throw new KeyNotFoundException("Email settings not found.");
            
            if (settings.NotificationsEnabled == false)
                return;

            await _rabbitMqPublisher.PublishAsync(message);
        }

    }
}
