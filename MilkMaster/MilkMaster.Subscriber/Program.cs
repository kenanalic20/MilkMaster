using MilkMaster.Application.DTOs;
using MilkMaster.Subscriber.Service;

Console.WriteLine("Starting RabbitMQ Consumer...");
var consumer = new RabbitMqConsumerService();
await consumer.StartListening<SettingsDto>();


Console.ReadKey();