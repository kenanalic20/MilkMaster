using MilkMaster.Application.Interfaces.Services;
using EasyNetQ;

namespace MilkMaster.Infrastructure.Services
{
    public class RabbitMqPublisherService:IRabbitMqPublisher
    {
        private readonly IBus _bus;

        public RabbitMqPublisherService(string hostName = "localhost")
        {
            _bus = RabbitHutch.CreateBus($"host={hostName}");
        }

        public async Task PublishAsync<T>(T message, string ? role = null, string? action = "*")
        {
            var dtoName = typeof(T).Name
            .Replace("MilkMaster.Application.Dtos.", "")
            .Replace("Dto", "") 
            .ToLower();  

            Console.WriteLine($"Publishing dtoName: {dtoName}");

            var topic = string.IsNullOrEmpty(role)
                ? $"{dtoName}.{action}" 
                : $"{role}.{dtoName}.{action}";  

            Console.WriteLine($"Publishing to topic: {topic}");

            await _bus.PubSub.PublishAsync(message, topic);
        }
    }
}
