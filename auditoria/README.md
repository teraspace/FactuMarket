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
