using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using System.Threading.Tasks;
using ClientesService.Infrastructure.Persistence;
using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace ClientesService.Tests.Integration;

public class ClientesEndpointsTests : IClassFixture<ClientesServiceFactory>, IAsyncLifetime
{
    private readonly ClientesServiceFactory _factory;
    private readonly HttpClient _client;

    public ClientesEndpointsTests(ClientesServiceFactory factory)
    {
        _factory = factory;
        _client = factory.CreateClient();
    }

    public async Task InitializeAsync()
    {
        await ResetDatabaseAsync();
    }

    public Task DisposeAsync() => Task.CompletedTask;

    [Fact]
    public async Task CrearCliente_DevuelveCreated()
    {
        var payload = new
        {
            nombre = "Carlos Patiño",
            identificacion = "12345",
            correo = "carlos@example.com",
            direccion = "Barranquilla"
        };

        var response = await _client.PostAsJsonAsync("/clientes", payload);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        json.GetProperty("id").GetInt32().Should().BeGreaterThan(0);
        json.GetProperty("nombre").GetString().Should().Be("Carlos Patiño");
        json.GetProperty("identificacion").GetString().Should().Be("12345");
        json.GetProperty("correo").GetString().Should().Be("carlos@example.com");
        json.GetProperty("direccion").GetString().Should().Be("Barranquilla");
    }

    [Fact]
    public async Task ObtenerClientePorId_RetornaDatos()
    {
        var clienteId = await CrearClienteAsync("Ana", "67890", "ana@example.com", "Bogotá");

        var response = await _client.GetAsync($"/clientes/{clienteId}");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        json.GetProperty("id").GetInt32().Should().Be(clienteId);
        json.GetProperty("nombre").GetString().Should().Be("Ana");
    }

    [Fact]
    public async Task ListarClientes_RetornaColeccion()
    {
        await CrearClienteAsync("Laura", "111", "laura@example.com", "Cali");
        await CrearClienteAsync("Pedro", "222", "pedro@example.com", "Medellín");

        var response = await _client.GetAsync("/clientes");
        response.StatusCode.Should().Be(HttpStatusCode.OK);

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        json.ValueKind.Should().Be(JsonValueKind.Array);
        json.GetArrayLength().Should().BeGreaterOrEqualTo(2);
    }

    private async Task ResetDatabaseAsync()
    {
        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<ClientesDbContext>();
        await db.Database.EnsureCreatedAsync();
        db.Clientes.RemoveRange(db.Clientes);
        await db.SaveChangesAsync();
    }

    private async Task<int> CrearClienteAsync(string nombre, string identificacion, string correo, string direccion)
    {
        var payload = new { nombre, identificacion, correo, direccion };
        var response = await _client.PostAsJsonAsync("/clientes", payload);
        response.StatusCode.Should().Be(HttpStatusCode.Created);

        var json = await response.Content.ReadFromJsonAsync<JsonElement>();
        return json.GetProperty("id").GetInt32();
    }
}
