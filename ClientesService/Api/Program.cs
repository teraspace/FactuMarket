using ClientesService.Application.Interfaces;
using ClientesService.Application.UseCases;
using ClientesService.Infrastructure.Config;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDatabase(builder.Configuration);

builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<CrearCliente>();
builder.Services.AddScoped<ObtenerCliente>();
builder.Services.AddScoped<ListarClientes>();

builder.Services.AddControllers();

var app = builder.Build();

await DatabaseInitializer.EnsureCreatedWithRetryAsync(app.Services, app.Logger, app.Configuration);

app.MapControllers();
app.MapGet("/health", () => Results.Json(new { status = "ok", service = "clientes" }));

app.Logger.LogInformation("clientes ready");

app.Run("http://0.0.0.0:5001");
