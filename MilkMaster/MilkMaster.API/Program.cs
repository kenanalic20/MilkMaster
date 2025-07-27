using Microsoft.EntityFrameworkCore;
using MilkMaster.Infrastructure.Extensions;
using MilkMaster.Domain.Data;
using MilkMaster.Infrastructure.Seeders;
using MilkMaster.API.Extensions;
using MilkMaster.Application.Extensions;
using MilkMaster.API.Middleware;


var builder = WebApplication.CreateBuilder(args);
builder.Configuration
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false)
    .AddEnvironmentVariables();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerService();
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString, b => b.MigrationsAssembly("MilkMaster.Domain")));

builder.Services.AddAutoMapperService();
builder.Services.AddServices(builder.Configuration);
builder.Services.AddSeeders();


builder.Services.AddAuthService(builder.Configuration);
var app = builder.Build();

app.UseStaticFiles();
app.UseMiddleware<ExceptionHandlingMiddleware>();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "MilkMaster API v1");
    });
}


using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    for (int i = 0; i < 10; i++)
    {
        try
        {
            context.Database.Migrate();
            break;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Migration failed: {ex.Message}");
            Thread.Sleep(5000);
        }
    }

    var roleSeeder = scope.ServiceProvider.GetRequiredService<RoleSeeder>();
    await roleSeeder.SeedRolesAsync();

    var productCategorySeeder = scope.ServiceProvider.GetRequiredService<ProductCategoriesSeeder>();
    await productCategorySeeder.SeedProductCategoriesAsync();

    var cattleCategorySeeder = scope.ServiceProvider.GetRequiredService<CattleCategoriesSeeder>();
    await cattleCategorySeeder.SeedCattleCategoriesAsync();

    var userSeeder = scope.ServiceProvider.GetRequiredService<IdentitySeeder>();
    await userSeeder.SeedUsersAsync();

    var productSeeder = scope.ServiceProvider.GetRequiredService<ProductsSeeder>();
    await productSeeder.SeedProductsAsync();
}


app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
