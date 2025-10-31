using ClientesService.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace ClientesService.Infrastructure.Persistence;

/// <summary>
/// DbContext de la capa Infrastructure que mapea las entidades hacia la base de datos.
/// </summary>
public class ClientesDbContext : DbContext
{
    public ClientesDbContext(DbContextOptions<ClientesDbContext> options) : base(options)
    {
    }

    /// <summary>
    /// Colección persistida de clientes.
    /// </summary>
    public DbSet<Cliente> Clientes => Set<Cliente>();
}
