#!/bin/bash

# Script completo para resetear la base de datos PostgreSQL
# Este script elimina completamente los volúmenes y reinicia todo

echo "🔄 Reseteo completo de la base de datos PostgreSQL..."

# Detener todos los servicios
echo "⏹️  Deteniendo todos los servicios..."
docker compose -f docker-compose-easypanel.yml down

# Eliminar contenedores relacionados
echo "🗑️  Eliminando contenedores existentes..."
docker container prune -f

# Eliminar volúmenes específicos del proyecto
echo "🗑️  Eliminando volúmenes de datos..."
docker volume rm vicarius-reports-dashboard_postgres_data 2>/dev/null || true
docker volume rm vicarius-reports-dashboard_metabase_data 2>/dev/null || true
docker volume rm vicarius-reports-dashboard_webapp_data 2>/dev/null || true

# Eliminar volúmenes huérfanos
echo "🧹 Limpiando volúmenes huérfanos..."
docker volume prune -f

# Eliminar imágenes huérfanas
echo "🧹 Limpiando imágenes huérfanos..."
docker image prune -f

# Limpiar sistema Docker
echo "🧹 Limpieza general del sistema Docker..."
docker system prune -f

# Crear directorio de datos limpio
echo "📁 Preparando directorio de datos limpio..."
mkdir -p ./postgres-data-clean
rm -rf ./postgres-data-clean/*

# Reconstruir y levantar los servicios
echo "🚀 Reconstruyendo y levantando servicios..."
docker compose -f docker-compose-easypanel.yml up --build -d

# Esperar a que PostgreSQL esté completamente listo
echo "⏳ Esperando a que PostgreSQL esté completamente listo..."
sleep 45

# Verificar el estado de los servicios
echo "📊 Verificando estado de los servicios..."
docker compose -f docker-compose-easypanel.yml ps

# Mostrar logs de PostgreSQL para verificar la inicialización
echo "📋 Mostrando logs de PostgreSQL (últimas 30 líneas)..."
docker compose -f docker-compose-easypanel.yml logs postgres | tail -30

# Verificar conexión a la base de datos
echo "🔍 Verificando conexión a la base de datos..."
docker compose -f docker-compose-easypanel.yml exec postgres psql -U vrx_user -d vrx_reports -c "SELECT 'Conexión exitosa' as status;" 2>/dev/null || echo "❌ Error en la conexión"

echo "✅ Proceso de reseteo completado."
echo "📝 Si persisten los errores, ejecuta:"
echo "   docker compose -f docker-compose-easypanel.yml logs postgres"
