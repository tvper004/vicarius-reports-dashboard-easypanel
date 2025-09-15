#!/bin/bash

# Script para corregir el problema de autenticación de PostgreSQL
# Este script limpia los volúmenes de Docker y reinicia los servicios

echo "🔧 Corrigiendo problema de autenticación de PostgreSQL..."

# Detener todos los servicios
echo "⏹️  Deteniendo servicios..."
docker-compose -f docker-compose-easypanel.yml down

# Limpiar volúmenes de PostgreSQL para forzar reinicialización
echo "🗑️  Limpiando volúmenes de PostgreSQL..."
docker volume rm vicarius-reports-dashboard_postgres_data 2>/dev/null || true

# Limpiar volúmenes de Metabase para forzar reinicialización
echo "🗑️  Limpiando volúmenes de Metabase..."
docker volume rm vicarius-reports-dashboard_metabase_data 2>/dev/null || true

# Limpiar volúmenes de webapp
echo "🗑️  Limpiando volúmenes de webapp..."
docker volume rm vicarius-reports-dashboard_webapp_data 2>/dev/null || true

# Limpiar imágenes huérfanas
echo "🧹 Limpiando imágenes huérfanas..."
docker system prune -f

# Reconstruir y levantar los servicios
echo "🚀 Reconstruyendo y levantando servicios..."
docker-compose -f docker-compose-easypanel.yml up --build -d

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
sleep 30

# Verificar el estado de los servicios
echo "📊 Verificando estado de los servicios..."
docker-compose -f docker-compose-easypanel.yml ps

# Mostrar logs de PostgreSQL para verificar la inicialización
echo "📋 Mostrando logs de PostgreSQL..."
docker-compose -f docker-compose-easypanel.yml logs postgres | tail -20

echo "✅ Proceso completado. Verifica los logs para confirmar que la autenticación funciona correctamente."
