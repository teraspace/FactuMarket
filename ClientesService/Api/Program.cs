using ClientesService.Application.Interfaces;
using ClientesService.Application.UseCases;
using ClientesService.Infrastructure.Config;
using ClientesService.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDatabase(builder.Configuration);

builder.Services.AddScoped<IClienteRepository, ClienteRepository>();
builder.Services.AddScoped<CrearCliente>();
builder.Services.AddScoped<ObtenerCliente>();
builder.Services.AddScoped<ListarClientes>();

builder.Services.AddControllers();

var app = builder.Build();

// Ejecuta migraciones automáticas para SQLite demo.
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ClientesDbContext>();
    db.Database.EnsureCreated();
}

app.MapControllers();
app.MapGet("/health", () => Results.Json(new { status = "ok", service = "clientes" }));

app.Logger.LogInformation("clientes ready");

app.Run("http://0.0.0.0:5001");
