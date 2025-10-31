using Microsoft.AspNetCore.Mvc;

namespace ClientesService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ClientesController : ControllerBase
{
    [HttpGet]
    public IActionResult GetClientes()
    {
        var clientes = new[]
        {
            new { id = 1, nombre = "Cliente Demo" }
        };

        return Ok(clientes);
    }
}
