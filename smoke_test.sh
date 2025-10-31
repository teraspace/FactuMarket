#!/usr/bin/env bash
set -euo pipefail

echo "🚀 FactuMarket Smoke Tests — $(date)"

# URLs por defecto de los endpoints de salud. Conceptual para test local cambiar a localhost con sus puertos respectivos.
CLIENTES_URL="https://api.factumarket.com/clientes/health"
FACTURAS_URL="https://api.factumarket.com/facturas/health"
AUDITORIA_URL="https://api.factumarket.com/auditoria/health"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --clientes)
      CLIENTES_URL="$2"
      shift 2
      ;;
    --facturas)
      FACTURAS_URL="$2"
      shift 2
      ;;
    --auditoria)
      AUDITORIA_URL="$2"
      shift 2
      ;;
    *)
      echo "⚠️  Argumento desconocido: $1"
      exit 1
      ;;
  esac
done

check() {
  local name="$1"
  local url="$2"
  echo "🔎 Probing $name..."
  if response=$(curl -fsS -m 10 "$url"); then
    if echo "$response" | grep -q '"status"\s*:\s*"ok"'; then
      echo "✅ $name OK ($url)"
    else
      echo "❌ $name FAILED (respuesta inesperada)"
      echo "   → $response"
      FAIL=1
    fi
  else
    echo "❌ $name FAILED (sin respuesta) ($url)"
    FAIL=1
  fi
}

FAIL=0
check "Clientes" "$CLIENTES_URL"
check "Facturas" "$FACTURAS_URL"
check "Auditoría" "$AUDITORIA_URL"

if [ $FAIL -eq 0 ]; then
  echo "🎉 Todos los servicios están operativos."
else
  echo "🚨 Uno o más servicios fallaron el smoke test."
  exit 1
fi
