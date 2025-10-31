namespace ClientesService.Application.DTOs;

/// <summary>
/// DTO de la capa Application usado para transferir datos de clientes hacia y desde la API.
/// </summary>
public class ClienteDto
{
    /// <summary>
    /// Identificador del cliente.
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Nombre del cliente.
    /// </summary>
    public string Nombre { get; set; } = string.Empty;

    /// <summary>
    /// Email del cliente.
    /// </summary>
    public string Email { get; set; } = string.Empty;
}
