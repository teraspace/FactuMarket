namespace ClientesService.Infrastructure.Config;

/// <summary>
/// Opciones simples para identificar el proveedor de base de datos configurado.
/// </summary>
public class DatabaseOptions
{
    /// <summary>
    /// Nombre del proveedor de base de datos utilizado (sqlite u oracle).
    /// </summary>
    public string Provider { get; set; } = "sqlite";
}
