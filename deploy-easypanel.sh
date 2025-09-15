#!/bin/bash

# Script de despliegue para EasyPanel
# vAnalyzer - Vicarius Reports Dashboard

set -e

echo "=== Despliegue de vAnalyzer en EasyPanel ==="

# Verificar que existe el archivo .env
if [ ! -f .env ]; then
    echo "Error: Archivo .env no encontrado."
    echo "Ejecute primero: ./install-debian.sh"
    exit 1
fi

# Cargar variables de entorno
source .env

# Verificar variables requeridas
if [ -z "$API_KEY" ] || [ "$API_KEY" = "your_vicarius_api_key_here" ]; then
    echo "Error: API_KEY no configurada en .env"
    exit 1
fi

if [ -z "$DASHBOARD_ID" ] || [ "$DASHBOARD_ID" = "your_dashboard_id_here" ]; then
    echo "Error: DASHBOARD_ID no configurado en .env"
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "your_secure_password_here" ]; then
    echo "Error: POSTGRES_PASSWORD no configurada en .env"
    exit 1
fi

# Crear directorios necesarios
echo "Creando directorios..."
mkdir -p app/reports
mkdir -p app/logs
mkdir -p app/scripts

# Construir y desplegar servicios
echo "Construyendo y desplegando servicios..."

# Detener servicios existentes si están corriendo
docker-compose -f docker-compose-easypanel.yml down 2>/dev/null || true

# Construir imágenes
echo "Construyendo imágenes Docker..."
docker-compose -f docker-compose-easypanel.yml build

# Iniciar servicios
echo "Iniciando servicios..."
docker-compose -f docker-compose-easypanel.yml up -d

# Esperar a que los servicios estén listos
echo "Esperando a que los servicios estén listos..."
sleep 30

# Verificar estado de los servicios
echo "Verificando estado de los servicios..."
docker-compose -f docker-compose-easypanel.yml ps

echo ""
echo "=== Despliegue completado ==="
echo ""
echo "Servicios disponibles:"
echo "- Base de datos PostgreSQL: puerto 5432 (interno)"
echo "- Aplicación principal: puerto 8000 (interno)"
echo "- Dashboard web (Django): http://localhost:8001"
echo "- Metabase: http://localhost:3000"
echo ""
echo "Para ver los logs:"
echo "  docker-compose -f docker-compose-easypanel.yml logs -f"
echo ""
echo "Para detener los servicios:"
echo "  docker-compose -f docker-compose-easypanel.yml down"
echo ""
echo "Para reiniciar los servicios:"
echo "  docker-compose -f docker-compose-easypanel.yml restart"
