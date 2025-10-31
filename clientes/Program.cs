using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System.Threading;
using System.Threading.Tasks;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHostedService<DbWarmupHostedService>();

var app = builder.Build();

app.MapControllers();

app.MapGet("/health", () => Results.Json(new
{
    status = "ok",
    service = "clientes"
}));

app.Logger.LogInformation("Inicializando servicio clientes...");

app.Lifetime.ApplicationStarted.Register(() =>
{
    app.Logger.LogInformation("clientes ready");
});

app.Run();

public class DbWarmupHostedService : IHostedService
{
    private readonly ILogger<DbWarmupHostedService> _logger;
    private readonly IConfiguration _configuration;

    public DbWarmupHostedService(ILogger<DbWarmupHostedService> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await TryConnectMongo(cancellationToken);
        await TryConnectOracle(cancellationToken);
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;

    private async Task TryConnectMongo(CancellationToken cancellationToken)
    {
        var mongoUri = _configuration.GetValue<string>("MONGO_URI") ?? "mongodb://mongo-db:27017/factumarket";

        try
        {
            var client = new MongoDB.Driver.MongoClient(mongoUri);
            await client.ListDatabaseNamesAsync(cancellationToken);
            _logger.LogInformation("Conexion a MongoDB exitosa en {MongoUri}", mongoUri);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No fue posible conectar con MongoDB usando {MongoUri}", mongoUri);
        }
    }

    private async Task TryConnectOracle(CancellationToken cancellationToken)
    {
        var oracleConn = _configuration.GetValue<string>("ORACLE_CONN") ?? "User Id=system;Password=Oracle123;Data Source=oracle-db:1521/FREEPDB1";

        try
        {
            await using var connection = new Oracle.ManagedDataAccess.Client.OracleConnection(oracleConn);
            await connection.OpenAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = "SELECT 1 FROM dual";
            await command.ExecuteScalarAsync(cancellationToken);
            _logger.LogInformation("Conexion a Oracle exitosa usando {OracleConn}", oracleConn);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No fue posible conectar con Oracle usando {OracleConn}", oracleConn);
        }
    }
}
