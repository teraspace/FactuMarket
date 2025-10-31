# 🚀 Puesta en marcha rápida

```bash
# 1. Clonar el repositorio
git clone <repo> factumarket
cd factumarket

# 2. Levantar todos los servicios
docker compose up --build

# 3. Ejecutar pruebas de integración
cd facturas && bundle exec rspec spec/integration
cd ../ClientesService && dotnet test ClientesService.Tests/ClientesService.Tests.csproj

# 4. Smoke tests (requiere curl y API_TOKEN configurado en los contenedores)
./smoke_test.sh --clientes http://localhost:5001/health \
                --facturas http://localhost:5002/health \
                --auditoria http://localhost:5003/health
