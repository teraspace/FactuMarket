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

## Cómo ejecutar las pruebas

Instala las dependencias de desarrollo y ejecuta la suite de integración end-to-end:

```bash
cd facturas
bundle install
RACK_ENV=test bundle exec rspec
```

Las pruebas usan SQLite en memoria, Rack::Test y WebMock para simular el servicio de auditoría. El resultado esperado es:

```
5 examples, 0 failures
```

### 🧾 Integración futura con la DIAN (Entidad Tributaria)

Este servicio incluye una interfaz de gateway (`DianGateway`) que representa la conexión con la DIAN. Actualmente utiliza un cliente simulado (`DianHttpClient`) que emula el envío de facturas electrónicas. En un entorno real, se podrá reemplazar por una integración REST/XML con la DIAN sin alterar el dominio.

```ruby
@dian.enviar_factura(factura.to_h)
```

Esto demuestra cómo la arquitectura está preparada para cumplir con los requerimientos normativos sin comprometer la independencia del dominio.
