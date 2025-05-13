namespace MilkMaster.Application.Interfaces.Services
{
    public interface IRabbitMqPublisher
    {
        Task PublishAsync<T>(T message);
    }
}
