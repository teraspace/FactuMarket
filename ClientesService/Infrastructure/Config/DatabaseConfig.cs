using ClientesService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace ClientesService.Infrastructure.Config;

/// <summary>
/// Configuración Infrastructure para inicializar el DbContext con SQLite in-memory.
/// </summary>
public static class DatabaseConfig
{
    public static IServiceCollection AddDatabase(this IServiceCollection services, IConfiguration configuration)
    {
        // Se utiliza SQLite in-memory como placeholder; puede reemplazarse por Oracle.
        services.AddDbContext<ClientesDbContext>(options =>
        {
            var connectionString = configuration.GetConnectionString("Clientes") ?? "DataSource=clientes.db";
            options.UseSqlite(connectionString);
        });

        return services;
    }
}
