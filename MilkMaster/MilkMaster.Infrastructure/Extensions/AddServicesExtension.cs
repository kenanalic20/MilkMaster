using Microsoft.Extensions.DependencyInjection;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Infrastructure.Services;

namespace MilkMaster.Infrastructure.Extensions
{
    public static class AddServicesExtension
    {
        public static IServiceCollection AddServices(this IServiceCollection services)
        {
            services.AddTransient<IJwtService, JwtService>();
            services.AddTransient<IAuthService, AuthService>();
            return services;
        }
    }
}
