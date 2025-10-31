using ClientesService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ClientesService.Infrastructure.Config;

/// <summary>
/// Configuración Infrastructure para inicializar el DbContext con SQLite por defecto o Oracle según entorno.
/// </summary>
public static class DatabaseConfig
{
    private const string ProviderKey = "DB_PROVIDER";

    public static IServiceCollection AddDatabase(this IServiceCollection services, IConfiguration configuration)
    {
        var provider = (configuration[ProviderKey] ?? "sqlite").ToLowerInvariant();
        var connectionString = configuration.GetConnectionString("Clientes");

        if (provider == "oracle")
        {
            connectionString ??= "User Id=system;Password=Oracle123;Data Source=oracle-db:1521/FREEPDB1";
            services.AddDbContext<ClientesDbContext>(options => options.UseOracle(connectionString));
        }
        else
        {
            provider = "sqlite";
            connectionString ??= "Data Source=clientes.db";
            services.AddDbContext<ClientesDbContext>(options => options.UseSqlite(connectionString));
        }

        services.AddSingleton(new DatabaseOptions { Provider = provider });
        return services;
    }
}
