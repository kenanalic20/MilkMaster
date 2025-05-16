using MilkMaster.Application.DTOs;
using MilkMaster.Subscriber.Service;

Console.WriteLine("Starting RabbitMQ Consumer...");
//This is it runs in docker pass rabbitmq as host otherwise default is localhost(no need to pass)
var consumer = new RabbitMqConsumerService();
// Start listening for messages of type TestRabbitMessagingDto
await consumer.StartListening<TestRabbitMessagingDto>();

Console.ReadKey();