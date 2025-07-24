using EasyNetQ;
using MilkMaster.Messages;
using Newtonsoft.Json.Linq;

namespace MilkMaster.Subscriber.Service
{
    public class RabbitMqConsumerService
    {
        private readonly IBus _bus;
        private readonly EmailService _emailService;

        public RabbitMqConsumerService(EmailService emailService, string hostName = "localhost")
        {
            if (hostName == "localhost")
                _bus = RabbitHutch.CreateBus($"host={hostName}");
            else
                _bus = RabbitHutch.CreateBus(hostName);

            _emailService = emailService;
        }
        public async Task StartListening<T>(string? role = null, string action = "*")
        {
            var dtoName = typeof(T).Name.ToLower(); 

            
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
            if (message == null)
            {
                Console.WriteLine("⚠️ Received null message.");
                return;
            }

            switch (message)
            {
                case EmailMessage emailMessage:
                    bool sent = await _emailService.SendEmailAsync(emailMessage);
                    Console.WriteLine(sent
                        ? $"✅ Email sent to: {emailMessage.Email}"
                        : $"❌ Failed to send email to: {emailMessage.Email}");
                    break;

                default:
                    JObject jsonMessage = JObject.FromObject(message);
                    Console.WriteLine($"ℹ️ Received unhandled message: {jsonMessage}");
                    break;
            }
        }
    }
}
