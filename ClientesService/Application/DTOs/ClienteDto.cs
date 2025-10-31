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
    /// Número de identificación del cliente.
    /// </summary>
    public string Identificacion { get; set; } = string.Empty;

    /// <summary>
    /// Correo electrónico del cliente.
    /// </summary>
    public string Correo { get; set; } = string.Empty;

    /// <summary>
    /// Dirección física del cliente.
    /// </summary>
    public string Direccion { get; set; } = string.Empty;
}
