using ClientesService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace ClientesService.Infrastructure.Config;

/// <summary>
/// Inicializador con reintentos para asegurar la disponibilidad de la base de datos al inicio del servicio.
/// </summary>
public static class DatabaseInitializer
{
    private const string MaxRetriesKey = "DB_MAX_RETRIES";
    private const string DelaySecondsKey = "DB_RETRY_DELAY_SECONDS";

    public static async Task EnsureCreatedWithRetryAsync(IServiceProvider services, ILogger logger, IConfiguration configuration, CancellationToken cancellationToken = default)
    {
        using var scope = services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<ClientesDbContext>();
        var options = scope.ServiceProvider.GetRequiredService<DatabaseOptions>();
        var isSqlite = string.Equals(options.Provider, "sqlite", StringComparison.OrdinalIgnoreCase);
        var maxRetries = GetMaxRetries(configuration);
        var delay = GetRetryDelay(configuration);

        for (var attempt = 1; attempt <= maxRetries; attempt++)
        {
            try
            {
                if (isSqlite)
                {
                    await context.Database.EnsureCreatedAsync(cancellationToken);
                }
                else
                {
                    await context.Database.CanConnectAsync(cancellationToken);
                }

                logger.LogInformation("Conexión a base de datos establecida (intento {Attempt}/{Max}).", attempt, maxRetries);
                return;
            }
            catch (Exception ex)
            {
                if (attempt == maxRetries)
                {
                    logger.LogError(ex, "No se pudo conectar a la base de datos después de {MaxRetries} intentos.", maxRetries);
                    throw;
                }

                logger.LogWarning(ex, "No se pudo conectar a la base de datos. Reintentando en {Delay}s (intento {Attempt}/{Max}).", delay.TotalSeconds, attempt, maxRetries);
                await Task.Delay(delay, cancellationToken);
            }
        }
    }

    private static int GetMaxRetries(IConfiguration configuration)
    {
        var value = configuration[MaxRetriesKey];
        return int.TryParse(value, out var parsed) && parsed > 0 ? parsed : 20;
    }

    private static TimeSpan GetRetryDelay(IConfiguration configuration)
    {
        var value = configuration[DelaySecondsKey];
        return int.TryParse(value, out var parsed) && parsed > 0 ? TimeSpan.FromSeconds(parsed) : TimeSpan.FromSeconds(10);
    }
}
