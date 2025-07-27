using Microsoft.Extensions.DependencyInjection;
using MilkMaster.Infrastructure.Seeders;

namespace MilkMaster.Infrastructure.Extensions
{
    public static class SeederExtension
    {
        public static IServiceCollection AddSeeders(this IServiceCollection services)
        {
            services.AddTransient<RoleSeeder>();
            services.AddScoped<SettingsSeeder>();
            services.AddScoped<ProductCategoriesSeeder>();
            services.AddScoped<CattleCategoriesSeeder>();
            services.AddScoped<IdentitySeeder>();
            services.AddScoped<ProductsSeeder>();
            return services;
        }
    }
}
