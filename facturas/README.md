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

### ✉️ Envío de factura al cliente (Notificaciones)

El microservicio **Facturas** incluye un gateway de notificaciones (`EmailGateway` / `EmailClient`) que simula el envío de la factura electrónica validada al correo del cliente. En un entorno real, este adaptador se integraría con servicios como AWS SES, SendGrid o un SMTP corporativo. Cada envío genera un evento "NOTIFICAR" registrado en el servicio **Auditoría**.

```ruby
@correo.enviar_factura(cliente.email, factura.to_pdf)
```

Esto mantiene el dominio desacoplado mientras se prepara la arquitectura para notificaciones reales.

### 🧪 Pruebas de Integración End-to-End

Estas pruebas validan el flujo completo de Facturación Electrónica: emisión de factura, envío a la DIAN, notificación al cliente y registro de evento en Auditoría. Se ejecutan con:

```bash
RACK_ENV=test rspec spec/integration
```

### 🔒 Seguridad y Autenticación

FactuMarket implementa autenticación basada en **Bearer Token** para proteger los endpoints críticos del microservicio **Facturas**. El token se define en la variable de entorno `API_TOKEN` y cada petición debe enviar el encabezado `Authorization: Bearer <token>`. El middleware `AuthenticationMiddleware` intercepta todas las solicitudes excepto `/health`; si el token es inválido o está ausente, responde HTTP 401 con `{ "error": "Unauthorized" }`.

Este enfoque deja la arquitectura preparada para integrarse con AWS API Gateway + Cognito, proxies inversos (Nginx/Traefik) o servicios de gestión de secretos como AWS Secrets Manager.

```bash
export API_TOKEN="supersecreto123"
curl -H "Authorization: Bearer $API_TOKEN" http://localhost:5002/facturas
```

### 🧮 Consistencia y Patrón Outbox (ACID Distribuido)

Para garantizar atomicidad local y consistencia eventual, **Facturas** usa el patrón Outbox:

- La factura y el evento externo se guardan en la misma transacción usando la tabla `outbox_events` (UUID).
- Un worker (`RelayOutboxWorker`) reenvía los eventos pendientes hacia Auditoría y Notificaciones, marcando `processed` o `failed` para reintentos.
- El script `bin/relay_runner.rb` ejecuta el relay (ideal como sidecar o cron). Todos los identificadores usan UUIDv7, facilitando trazabilidad global entre servicios.

```text
Factura creada (UUIDv7)
 ├── Guardada en DB (atomicidad local)
 ├── Evento Outbox registrado
 ├── Relay envía a Auditoría/Correo
 └── Auditoría confirma → sistema consistente
```

### 🕒 Relay Runner (Procesamiento en Segundo Plano)

El componente `Relay Runner` mantiene el outbox procesado en segundo plano mediante **rufus-scheduler**. Ejecuta `RelayOutboxWorker` cada 30 segundos, registra logs de ejecución y reintenta eventos en estado `failed`, asegurando consistencia eventual.

- Puede correrse como sidecar (`docker compose up relay-worker`), servicio background local o tarea programada en AWS ECS.
- Requiere la variable `AUDITORIA_URL` y acceso a la base de datos.

```bash
docker compose up relay-worker
```

### 🧾 Validación y Respuesta de la DIAN

Cada factura se valida contra el gateway de la DIAN (mock). La respuesta se almacena dentro del mismo registro de la factura, garantizando trazabilidad tributaria.

| Campo | Descripción |
|-------|-------------|
| `dian_status` | Estado retornado por la DIAN (`ACEPTADO`, `RECHAZADO`, etc.) |
| `dian_uuid` | Identificador único asignado por la DIAN |
| `dian_response` | Respuesta completa serializada en JSON |
| `fecha_validacion_dian` | Fecha/hora en que se validó la factura |

Los datos se guardan en la misma transacción ACID que la factura y se reenvían mediante el patrón Outbox.
