#!/bin/bash

# Script completo para resetear Metabase y corregir la conexión
echo "🔄 Reseteo completo de Metabase para corregir conexión a PostgreSQL..."

# Detener todos los servicios
echo "⏹️ Deteniendo todos los servicios..."
docker compose -f docker-compose-easypanel-noports.yml down

# Eliminar contenedores relacionados
echo "🗑️ Eliminando contenedores existentes..."
docker container prune -f

# Eliminar volúmenes específicos de Metabase
echo "🗑️ Eliminando volúmenes de Metabase..."
docker volume rm vicarius-reports-dashboard_metabase_data 2>/dev/null || true

# Limpiar volúmenes huérfanos
echo "🧹 Limpiando volúmenes huérfanos..."
docker volume prune -f

# Reconstruir y levantar los servicios
echo "🚀 Reconstruyendo y levantando servicios..."
docker compose -f docker-compose-easypanel-noports.yml up --build -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 30

# Verificar el estado de los servicios
echo "📊 Verificando estado de los servicios..."
docker compose -f docker-compose-easypanel-noports.yml ps

# Mostrar logs de Metabase para verificar la conexión
echo "📋 Mostrando logs de Metabase (últimas 20 líneas)..."
docker compose -f docker-compose-easypanel-noports.yml logs metabase | tail -20

echo "✅ Reseteo de Metabase completado"
echo "💡 Metabase debería conectarse correctamente con vrx_user"
