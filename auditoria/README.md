# AuditoriaService - FactuMarket

Microservicio **AuditoriaService** construido con Ruby 3.3 + Sinatra para registrar eventos de auditoría en MongoDB.

## Estructura

- `domain/`: Entidades de auditoría (Evento).
- `application/use_cases/`: Casos de uso `RegistrarEvento` y `ListarEventos`.
- `infrastructure/`: Repositorio Mongo y controlador HTTP.
- `interfaces/api.rb`: API Sinatra exponiendo endpoints REST.

## Dependencias

```bash
bundle install
```

## Ejecución

```bash
ruby interfaces/api.rb
```

Endpoints disponibles:
- `GET /health`
- `POST /events`
- `GET /auditoria/:entidad_id`

Ejemplo de consumo:

```bash
curl -X POST http://localhost:5003/events \
  -H 'Content-Type: application/json' \
  -d '{"servicio":"facturas","entidad_id":1,"accion":"CREAR","mensaje":"Factura creada"}'

curl http://localhost:5003/auditoria/1
```

## Docker

```bash
docker build -t auditoriaservice .
docker run -p 5003:5003 auditoriaservice
```

### Pruebas de integración Auditoría

```bash
bundle install
RACK_ENV=test rspec spec/integration
```

### 🔒 Seguridad y Autenticación

El microservicio **Auditoría** también utiliza autenticación **Bearer Token** para proteger sus endpoints, salvo `/health`. El token se configura con la variable `API_TOKEN` y es validado por `AuthenticationMiddleware`. Las peticiones sin token o con token incorrecto reciben HTTP 401.

```bash
export API_TOKEN="supersecreto123"
curl -H "Authorization: Bearer $API_TOKEN" http://localhost:5003/auditoria/1
```

Este mecanismo puede integrarse con AWS API Gateway + Cognito, proxies inversos o gestores de secretos como AWS Secrets Manager sin modificar el dominio.
