namespace ClientesService.Domain.Entities;

/// <summary>
/// Entidad de la capa Domain que representa a un cliente dentro del sistema FactuMarket.
/// </summary>
public class Cliente
{
    /// <summary>
    /// Identificador único del cliente.
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Nombre descriptivo del cliente.
    /// </summary>
    public string Nombre { get; set; } = string.Empty;

    /// <summary>
    /// Número de identificación tributaria o documento del cliente.
    /// </summary>
    public string Identificacion { get; set; } = string.Empty;

    /// <summary>
    /// Correo electrónico de contacto del cliente.
    /// </summary>
    public string Correo { get; set; } = string.Empty;

    /// <summary>
    /// Dirección física del cliente.
    /// </summary>
    public string Direccion { get; set; } = string.Empty;
}
