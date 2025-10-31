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
    /// Email de contacto del cliente.
    /// </summary>
    public string Email { get; set; } = string.Empty;
}
