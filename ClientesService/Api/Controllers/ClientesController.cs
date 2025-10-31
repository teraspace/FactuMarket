using ClientesService.Application.DTOs;
using ClientesService.Application.UseCases;
using Microsoft.AspNetCore.Mvc;

namespace ClientesService.Api.Controllers;

/// <summary>
/// Controlador API (capa Api) que expone endpoints REST para gestionar clientes.
/// </summary>
[ApiController]
[Route("[controller]")]
public class ClientesController : ControllerBase
{
    [HttpGet("health")]
    public IActionResult Health() =>
        Ok(new { status = "ok", service = "clientes" });

    [HttpPost]
    public async Task<IActionResult> CrearCliente(
        [FromBody] ClienteDto dto,
        [FromServices] CrearCliente crearCliente,
        CancellationToken cancellationToken)
    {
        var resultado = await crearCliente.ExecuteAsync(dto, cancellationToken);
        return CreatedAtAction(nameof(ObtenerCliente), new { id = resultado.Id }, resultado);
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> ObtenerCliente(
        int id,
        [FromServices] ObtenerCliente obtenerCliente,
        CancellationToken cancellationToken)
    {
        var cliente = await obtenerCliente.ExecuteAsync(id, cancellationToken);
        return cliente is null ? NotFound() : Ok(cliente);
    }

    [HttpGet]
    public async Task<IActionResult> ListarClientes(
        [FromServices] ListarClientes listarClientes,
        CancellationToken cancellationToken)
    {
        var clientes = await listarClientes.ExecuteAsync(cancellationToken);
        return Ok(clientes);
    }
}
