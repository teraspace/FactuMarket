# ClientesService - FactuMarket

Microservicio **ClientesService** basado en .NET 8 Web API siguiendo principios de Clean Architecture.

## Estructura de carpetas

- `Domain/`: Entidades del dominio (`Cliente`).
- `Application/`: DTOs, interfaces y casos de uso (`CrearCliente`, `ObtenerCliente`, `ListarClientes`).
- `Infrastructure/`: Persistencia con EF Core y configuración de base de datos SQLite.
- `Api/`: Entradas HTTP con controladores y `Program.cs`.
- `Tests/`: Pruebas unitarias simples con xUnit.

## Ejecución

```bash
dotnet restore
dotnet run --project ClientesService
```

Endpoints disponibles:

- `GET /health`
- `GET /clientes`
- `GET /clientes/{id}`
- `POST /clientes`

## Docker

```bash
docker build -t clientesservice .
docker run -p 5001:5001 clientesservice
```

## Pruebas

```bash
dotnet test ClientesService.csproj
```
