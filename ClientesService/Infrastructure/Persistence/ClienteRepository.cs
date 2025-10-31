using ClientesService.Application.Interfaces;
using ClientesService.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace ClientesService.Infrastructure.Persistence;

/// <summary>
/// Implementación Infrastructure del repositorio de clientes usando Entity Framework Core.
/// </summary>
public class ClienteRepository : IClienteRepository
{
    private readonly ClientesDbContext _context;

    public ClienteRepository(ClientesDbContext context)
    {
        _context = context;
    }

    public async Task<Cliente> CrearAsync(Cliente cliente, CancellationToken cancellationToken = default)
    {
        _context.Clientes.Add(cliente);
        await _context.SaveChangesAsync(cancellationToken);
        return cliente;
    }

    public Task<Cliente?> ObtenerPorIdAsync(int id, CancellationToken cancellationToken = default)
    {
        return _context.Clientes.AsNoTracking().FirstOrDefaultAsync(c => c.Id == id, cancellationToken);
    }

    public async Task<IEnumerable<Cliente>> ListarAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Clientes.AsNoTracking().ToListAsync(cancellationToken);
    }
}
