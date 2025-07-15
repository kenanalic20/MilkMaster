using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using MilkMaster.Application.Interfaces.Repositories;
using MilkMaster.Application.Interfaces.Services;
using MilkMaster.Infrastructure.Repositories;
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
            services.AddScoped(typeof(IRepository<,>), typeof(BaseRepository<,>));
            services.AddScoped(typeof(IService<,,,,>), typeof(BaseService<,,,,>));
            services.AddScoped<ISettingsRepository,SettingsRepository>();
            services.AddScoped<ISettingsService, SettingsService>();
            services.AddScoped<IUserDetailsRepository, UserDetailsRepository>();
            services.AddScoped<IUserDetailsService, UserDetailsService>();
            services.AddScoped<IUserAddressRepository, UserAddressRepository>();
            services.AddScoped<IUserAddressService, UserAddressService>();
            services.AddScoped<IProductCategoriesRepository, ProductCategoriesRepository>();
            services.AddScoped<IProductCategoriesService, ProductCategoriesService>();
            services.AddTransient<IFileService, FileService>();
            services.AddScoped<ICattleCategoriesRepository, CattleCategoriesRepository>();
            services.AddScoped<ICattleCategoriesService, CattleCategoriesService>();
            services.AddScoped<IProductsRepository, ProductRepository>();
            services.AddScoped<IProductsService, ProductService>();
            services.AddScoped<INutritionsRepository, NutritionsRepository>();



            return services;
        }
    }
}
