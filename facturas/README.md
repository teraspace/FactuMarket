# FactuMarket - Servicio Facturas

Estructura inicial del microservicio **Facturas** siguiendo principios de Clean Architecture y Domain-Driven Design.

## Estructura de carpetas

- `domain/`: Modelos y reglas del dominio (entidades, value objects, servicios y contratos de repositorio).
- `application/`: Casos de uso y DTO que orquestan la lógica del dominio para la interfaz.
- `infrastructure/`: Adaptadores concretos (persistencia, controladores HTTP, configuración de bases de datos).
- `interfaces/`: Entradas del sistema; en este caso la API HTTP basada en Sinatra.

Cada clase contiene un comentario que describe su responsabilidad y la capa a la que pertenece, lista para implementar la lógica real posteriormente.

## Ejecutar el servicio

Instala dependencias y levanta la API Sinatra:

```bash
bundle install
ruby interfaces/api.rb
```

La API expone endpoints básicos (`/health`, `/facturas`, `/facturas/:id`, `/facturas?fechaInicio&fechaFin`) listos para conectar con los casos de uso y adaptadores de infraestructura.
