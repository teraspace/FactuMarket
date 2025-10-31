using ClientesService.Domain.Entities;

namespace ClientesService.Application.Interfaces;

/// <summary>
/// Contrato de la capa Application para interactuar con la persistencia de clientes.
/// </summary>
public interface IClienteRepository
{
    /// <summary>
    /// Persiste un cliente.
    /// </summary>
    Task<Cliente> CrearAsync(Cliente cliente, CancellationToken cancellationToken = default);

    /// <summary>
    /// Recupera un cliente por identificador.
    /// </summary>
    Task<Cliente?> ObtenerPorIdAsync(int id, CancellationToken cancellationToken = default);

    /// <summary>
    /// Lista todos los clientes disponibles.
    /// </summary>
    Task<IEnumerable<Cliente>> ListarAsync(CancellationToken cancellationToken = default);
}
