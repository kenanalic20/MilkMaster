using Microsoft.Extensions.DependencyInjection;
using MilkMaster.Infrastructure.Seeders;

namespace MilkMaster.Infrastructure.Extensions
{
    public static class SeederExtension
    {
        public static IServiceCollection AddSeeders(this IServiceCollection services)
        {
            services.AddTransient<RoleSeeder>();
            return services;
        }
    }
}
