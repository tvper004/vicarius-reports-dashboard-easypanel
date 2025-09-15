#!/bin/bash

# Script de prueba para verificar el despliegue en EasyPanel
# vAnalyzer - Vicarius Reports Dashboard

set -e

echo "=== Prueba de Despliegue vAnalyzer ==="

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose-easypanel.yml" ]; then
    echo "Error: Ejecute este script desde el directorio raíz del proyecto"
    exit 1
fi

# Verificar que existe el archivo .env
if [ ! -f .env ]; then
    echo "Error: Archivo .env no encontrado."
    echo "Ejecute primero: ./install-debian-easypanel.sh"
    exit 1
fi

# Cargar variables de entorno
source .env

echo "Verificando configuración..."

# Verificar variables requeridas
if [ -z "$API_KEY" ] || [ "$API_KEY" = "your_vicarius_api_key_here" ]; then
    echo "❌ Error: API_KEY no configurada en .env"
    exit 1
fi

if [ -z "$DASHBOARD_ID" ] || [ "$DASHBOARD_ID" = "your_dashboard_id_here" ]; then
    echo "❌ Error: DASHBOARD_ID no configurado en .env"
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "your_secure_password_here" ]; then
    echo "❌ Error: POSTGRES_PASSWORD no configurada en .env"
    exit 1
fi

echo "✅ Configuración verificada"

# Verificar Docker
echo "Verificando Docker..."
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Error: Docker Compose no está instalado"
    exit 1
fi

echo "✅ Docker y Docker Compose disponibles"

# Verificar que Docker esté corriendo
if ! docker info &> /dev/null; then
    echo "❌ Error: Docker no está corriendo"
    echo "Inicie Docker con: sudo systemctl start docker"
    exit 1
fi

echo "✅ Docker está corriendo"

# Construir imágenes
echo "Construyendo imágenes Docker..."
if ! docker-compose -f docker-compose-easypanel.yml build; then
    echo "❌ Error: Falló la construcción de imágenes"
    exit 1
fi

echo "✅ Imágenes construidas correctamente"

# Iniciar servicios
echo "Iniciando servicios..."
if ! docker-compose -f docker-compose-easypanel.yml up -d; then
    echo "❌ Error: Falló el inicio de servicios"
    exit 1
fi

echo "✅ Servicios iniciados"

# Esperar a que los servicios estén listos
echo "Esperando a que los servicios estén listos..."
sleep 30

# Verificar estado de los servicios
echo "Verificando estado de los servicios..."
docker-compose -f docker-compose-easypanel.yml ps

# Verificar salud de la base de datos
echo "Verificando base de datos..."
if docker-compose -f docker-compose-easypanel.yml exec -T postgres pg_isready -U vrx_user -d vrx_reports; then
    echo "✅ Base de datos PostgreSQL: OK"
else
    echo "❌ Base de datos PostgreSQL: ERROR"
fi

# Verificar salud de la aplicación
echo "Verificando aplicación principal..."
if docker-compose -f docker-compose-easypanel.yml exec -T app python /usr/src/app/health_check.py; then
    echo "✅ Aplicación principal: OK"
else
    echo "❌ Aplicación principal: ERROR"
fi

# Verificar servicios web
echo "Verificando servicios web..."

# Verificar Dashboard Web (Django)
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8001 | grep -q "200\|302"; then
    echo "✅ Dashboard Web (Django): OK"
else
    echo "⚠️  Dashboard Web (Django): No disponible (puede estar iniciando)"
fi

# Verificar Metabase
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 | grep -q "200\|302"; then
    echo "✅ Metabase: OK"
else
    echo "⚠️  Metabase: No disponible (puede estar iniciando)"
fi

# Mostrar logs recientes
echo ""
echo "=== Logs Recientes ==="
echo "--- Aplicación Principal ---"
docker-compose -f docker-compose-easypanel.yml logs --tail=10 app

echo ""
echo "--- PostgreSQL ---"
docker-compose -f docker-compose-easypanel.yml logs --tail=5 postgres

# Mostrar información de acceso
echo ""
echo "=== Información de Acceso ==="
echo "Dashboard Web (Django): http://localhost:8001"
echo "Metabase: http://localhost:3000"
echo ""
echo "Credenciales por defecto de Metabase:"
echo "Usuario: vrxadmin@vrxadmin.com"
echo "Contraseña: Vicarius123!@#"
echo ""
echo "=== Prueba Completada ==="
echo ""
echo "Para monitorear en tiempo real:"
echo "  docker-compose -f docker-compose-easypanel.yml logs -f"
echo ""
echo "Para detener los servicios:"
echo "  docker-compose -f docker-compose-easypanel.yml down"
echo ""
echo "Para reiniciar los servicios:"
echo "  docker-compose -f docker-compose-easypanel.yml restart"
