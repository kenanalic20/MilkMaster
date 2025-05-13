using MilkMaster.Application.DTOs;
using MilkMaster.Infrastructure.Services;

Console.WriteLine("Starting RabbitMQ Consumer...");
var consumer = new RabbitMqConsumerService();
await consumer.StartListening<SettingsDto>();

Console.WriteLine("Press any key to exit...");
Console.ReadKey();