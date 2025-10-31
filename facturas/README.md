# FactuMarket - Servicio Facturas

Estructura inicial del microservicio **Facturas** siguiendo principios de Clean Architecture y Domain-Driven Design.

## Estructura de carpetas

- `domain/`: Modelos y reglas del dominio (entidades, value objects, servicios y contratos de repositorio).
- `application/`: Casos de uso y DTO que orquestan la lógica del dominio para la interfaz.
- `infrastructure/`: Adaptadores concretos (persistencia, controladores HTTP, configuración de bases de datos).
- `interfaces/`: Entradas del sistema; en este caso la API HTTP basada en Sinatra.

Cada clase contiene un comentario que describe su responsabilidad y la capa a la que pertenece, lista para implementar la lógica real posteriormente.

## Ejecutar el servicio

Instala dependencias (requiere `sqlite3` headers en el sistema) y levanta la API Sinatra:

```bash
bundle install
ruby interfaces/api.rb
```

### Endpoints disponibles

- `GET /health` → estado del servicio.
- `POST /facturas` → crea una nueva factura validando monto, cliente y fecha (`cliente_id`, `monto`, `fecha_emision`).
- `GET /facturas/:id` → devuelve una factura previamente creada.
- `GET /facturas?fechaInicio=YYYY-MM-DD&fechaFin=YYYY-MM-DD` → lista facturas en el rango.

Ejemplo rápido:

```bash
curl -X POST http://localhost:5002/facturas \
  -H 'Content-Type: application/json' \
  -d '{"cliente_id":123,"monto":5000,"fecha_emision":"2025-10-30"}'
```

### Persistencia y auditoría

- La capa `Infrastructure::Config::Database` intenta conectarse a Oracle mediante `oracle_enhanced_adapter` cuando `USE_ORACLE=true`. Si el adaptador no está disponible, usa SQLite (`SQLITE_PATH`, por defecto `db/facturas.sqlite3`).
- `Infrastructure::Persistence::FacturaRepositoryImpl` utiliza ActiveRecord para mapear la tabla `facturas` y devuelve entidades de dominio.
- `Infrastructure::Services::AuditoriaGateway` envía eventos al microservicio `auditoria` (configurable con `AUDITORIA_URL`, por defecto `http://auditoria:5003`).

El repositorio mantiene las invariantes del dominio y, tras persistir, registra un evento `CREAR` en auditoría.
