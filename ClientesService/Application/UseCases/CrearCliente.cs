using ClientesService.Application.DTOs;
using ClientesService.Application.Interfaces;
using ClientesService.Domain.Entities;

namespace ClientesService.Application.UseCases;

/// <summary>
/// Caso de uso Application encargado de crear clientes delegando en el repositorio.
/// </summary>
public class CrearCliente
{
    private readonly IClienteRepository _repository;

    public CrearCliente(IClienteRepository repository)
    {
        _repository = repository;
    }

    public async Task<ClienteDto> ExecuteAsync(ClienteDto dto, CancellationToken cancellationToken = default)
    {
        var entity = new Cliente
        {
            Nombre = dto.Nombre,
            Email = dto.Email
        };

        var created = await _repository.CrearAsync(entity, cancellationToken);

        return new ClienteDto
        {
            Id = created.Id,
            Nombre = created.Nombre,
            Email = created.Email
        };
    }
}
