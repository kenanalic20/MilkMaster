using Microsoft.Extensions.DependencyInjection;

namespace MilkMaster.Application.Extensions
{
    public static class AddAutoMapperExtension
    {
        public static IServiceCollection AddAutoMapperService(this IServiceCollection services)
        {
            services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());
            return services;
        }
    }
}
