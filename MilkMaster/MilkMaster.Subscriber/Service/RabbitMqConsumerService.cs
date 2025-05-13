using EasyNetQ;
using Newtonsoft.Json.Linq;

namespace MilkMaster.Subscriber.Service
{
    public class RabbitMqConsumerService
    {
        private readonly IBus _bus;

        public RabbitMqConsumerService(string hostName = "localhost")
        {
            _bus = RabbitHutch.CreateBus($"host={hostName}");
        }
        //will change
        public async Task StartListening<T>(string? role = null, string action = "*")
        {
            var dtoName = typeof(T).Name
            .Replace("MilkMaster.Application.Dtos.", "") 
            .Replace("Dto", "") 
            .ToLower(); 

            
            var routingKey = role == null
                ? $"{dtoName}.{action}"  
                : $"{role}.{dtoName}.{action}";  

            var subscriberId = role == null
                ? $"{dtoName}_{action}_subscriber" 
                : $"{role}_{dtoName}_{action}_subscriber";

            Console.WriteLine($"DtoName : {dtoName}");
            Console.WriteLine($"Subscriber ID: {subscriberId}");
            Console.WriteLine($"routingKey : {routingKey}");

            await _bus.PubSub.SubscribeAsync<T>(
                subscriberId,
                async (message) =>
                {
                    await HandleMessageAsync(message);
                },
                c => c.WithTopic(routingKey)  
            );

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
