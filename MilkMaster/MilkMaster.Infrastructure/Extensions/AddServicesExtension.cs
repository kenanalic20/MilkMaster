using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Infrastructure.Services;

namespace MilkMaster.Infrastructure.Extensions
{
    public static class AddServicesExtension
    {
        public static IServiceCollection AddServices(this IServiceCollection services, IConfiguration configuration)
        {
            var rabbitMqHost = configuration.GetValue<string>("RabbitMq:ConnectionString")??"localhost";
            services.AddTransient<IJwtService, JwtService>();
            services.AddTransient<IAuthService, AuthService>();
            services.AddSingleton<IRabbitMqPublisher>(sp => new RabbitMqPublisherService(rabbitMqHost));
            return services;
        }
    }
}
