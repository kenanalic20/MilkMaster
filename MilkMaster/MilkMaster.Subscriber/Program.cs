using MilkMaster.Messages;
using MilkMaster.Subscriber.Service;

Console.WriteLine("Starting RabbitMQ Consumer...");
var smtpHost = Environment.GetEnvironmentVariable("SMTP_HOST");
var smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT")!);
var smtpUser = Environment.GetEnvironmentVariable("SMTP_USERNAME");
var smtpPass = Environment.GetEnvironmentVariable("SMTP_PASSWORD");
var rabbitConnectionString = Environment.GetEnvironmentVariable("RABBITMQ_CONNECTIONSTRING") ??"localhost";

Console.WriteLine($"host {smtpHost}, {smtpPort}, {smtpUser}, {smtpPass}");

if (string.IsNullOrEmpty(smtpHost) || string.IsNullOrEmpty(smtpUser) || string.IsNullOrEmpty(smtpPass))
{
    Console.WriteLine("❌ SMTP configuration is missing. Please set the environment variables.");
    return;
}

var emailService = new EmailService(smtpHost,smtpPort,smtpUser,smtpPass);
var consumer = new RabbitMqConsumerService(emailService,rabbitConnectionString);
for (int i = 0; i < 10; i++)
{
    try
    {
        Console.WriteLine($"Attempt {i + 1} to start consumer...");
        await consumer.StartListening<EmailMessage>();
        break;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Waiting for API to start. Retrying in 5 seconds...");
        await Task.Delay(5000);
    }
}

while (true)
{
    Console.WriteLine("Consumer is running. Press Ctrl+C to exit.");
    await Task.Delay(10000);
}