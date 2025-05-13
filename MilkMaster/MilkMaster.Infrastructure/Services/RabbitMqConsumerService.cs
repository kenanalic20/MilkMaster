using EasyNetQ;
using System;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace MilkMaster.Infrastructure.Services
{
    public class RabbitMqConsumerService
    {
        private readonly IBus _bus;

        public RabbitMqConsumerService(string hostName = "localhost")
        {
            _bus = RabbitHutch.CreateBus($"host={hostName}");
        }

        public async Task StartListening<T>()
        {
            var routingKey = typeof(T).Name;
            await _bus.PubSub.SubscribeAsync<T>(routingKey, async (message) =>
            {
                await HandleMessageAsync(message);
            });

            Console.WriteLine($"Listening for messages on topic: {routingKey}");
        }

        private async Task HandleMessageAsync<T>(T message)
        {
            var error = new
            {
                text = "There is no message"
            };

            JObject jsonMessage = JObject.FromObject(message??(object)error);

            await Task.Delay(1000);

            Console.WriteLine($"Handled message: {jsonMessage}");
        }
    }
}
