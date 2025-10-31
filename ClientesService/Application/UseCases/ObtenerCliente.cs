using ClientesService.Application.DTOs;
using ClientesService.Application.Interfaces;

namespace ClientesService.Application.UseCases;

/// <summary>
/// Caso de uso Application que recupera un cliente por identificador.
/// </summary>
public class ObtenerCliente
{
    private readonly IClienteRepository _repository;

    public ObtenerCliente(IClienteRepository repository)
    {
        _repository = repository;
    }

    public async Task<ClienteDto?> ExecuteAsync(int id, CancellationToken cancellationToken = default)
    {
        var entity = await _repository.ObtenerPorIdAsync(id, cancellationToken);
        return entity is null
            ? null
            : new ClienteDto
            {
                Id = entity.Id,
                Nombre = entity.Nombre,
                Email = entity.Email
            };
    }
}
