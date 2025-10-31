using ClientesService.Application.DTOs;
using ClientesService.Application.Interfaces;

namespace ClientesService.Application.UseCases;

/// <summary>
/// Caso de uso Application que lista todos los clientes disponibles.
/// </summary>
public class ListarClientes
{
    private readonly IClienteRepository _repository;

    public ListarClientes(IClienteRepository repository)
    {
        _repository = repository;
    }

    public async Task<IEnumerable<ClienteDto>> ExecuteAsync(CancellationToken cancellationToken = default)
    {
        var entities = await _repository.ListarAsync(cancellationToken);
        return entities.Select(entity => new ClienteDto
        {
            Id = entity.Id,
            Nombre = entity.Nombre,
            Identificacion = entity.Identificacion,
            Correo = entity.Correo,
            Direccion = entity.Direccion
        });
    }
}
