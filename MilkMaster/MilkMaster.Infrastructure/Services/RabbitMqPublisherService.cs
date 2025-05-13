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

        public async Task PublishAsync<T>(T message)
        {
            var routingKey = typeof(T).Name;
            await _bus.PubSub.PublishAsync(message, routingKey);
        }
    }
}
