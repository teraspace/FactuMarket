using System.Net;
using System.Threading.Tasks;
using ClientesService.Infrastructure.Config;
using ClientesService.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Xunit;

namespace ClientesService.Tests.Integration;

public class HealthTests : IClassFixture<ClientesServiceFactory>
{
    private readonly HttpClient _client;

    public HealthTests(ClientesServiceFactory factory)
    {
        _client = factory.CreateClient();
    }

    [Fact]
    public async Task Health_ReturnsOk()
    {
        var response = await _client.GetAsync("/health");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var json = await response.Content.ReadAsStringAsync();
        json.Should().Contain("\"status\"").And.Contain("ok");
    }
}

public class ClientesServiceFactory : WebApplicationFactory<Program>
{
    private SqliteConnection? _connection;

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.ConfigureAppConfiguration((context, config) =>
        {
            var inMemorySettings = new Dictionary<string, string?>
            {
                { "DB_PROVIDER", "sqlite" },
                { "ConnectionStrings:Clientes", "DataSource=:memory:" }
            };
            config.AddInMemoryCollection(inMemorySettings!);
        });

        builder.ConfigureServices(services =>
        {
            var descriptor = services.SingleOrDefault(d => d.ServiceType == typeof(DbContextOptions<ClientesDbContext>));
            if (descriptor is not null)
            {
                services.Remove(descriptor);
            }

            var optionsDescriptor = services.SingleOrDefault(d => d.ServiceType == typeof(DatabaseOptions));
            if (optionsDescriptor is not null)
            {
                services.Remove(optionsDescriptor);
            }

            _connection = new SqliteConnection("DataSource=:memory:;Cache=Shared");
            _connection.Open();

            services.AddSingleton(_connection);

            services.AddDbContext<ClientesDbContext>((sp, options) =>
            {
                var connection = sp.GetRequiredService<SqliteConnection>();
                options.UseSqlite(connection);
            });

            services.AddSingleton(new DatabaseOptions { Provider = "sqlite" });

            var serviceProvider = services.BuildServiceProvider();
            using var scope = serviceProvider.CreateScope();
            var db = scope.ServiceProvider.GetRequiredService<ClientesDbContext>();
            db.Database.EnsureCreated();
        });
    }

    protected override void Dispose(bool disposing)
    {
        base.Dispose(disposing);
        if (disposing)
        {
            _connection?.Dispose();
            _connection = null;
        }
    }
}
