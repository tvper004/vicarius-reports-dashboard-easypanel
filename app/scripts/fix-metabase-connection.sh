#!/bin/bash

# Script para corregir la conexión de Metabase
echo "🔧 Corrigiendo conexión de Metabase a PostgreSQL..."

# Verificar variables de entorno de Metabase
echo "📋 Variables de entorno de Metabase:"
echo "   MB_DB_TYPE: ${MB_DB_TYPE:-postgres}"
echo "   MB_DB_HOST: ${MB_DB_HOST:-postgres}"
echo "   MB_DB_PORT: ${MB_DB_PORT:-5432}"
echo "   MB_DB_DBNAME: ${MB_DB_DBNAME:-vrx_reports}"
echo "   MB_DB_USER: ${MB_DB_USER:-vrx_user}"
echo "   MB_DB_PASS: ${MB_DB_PASS:-K67lkk7580*98095102*}"

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
sleep 5

# Verificar que el usuario vrx_user existe y puede conectarse
echo "🔍 Verificando usuario vrx_user en PostgreSQL..."
PGPASSWORD="K67lkk7580*98095102*" psql -h postgres -U vrx_user -d vrx_reports -c "SELECT 'Usuario vrx_user verificado' as status;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Usuario vrx_user verificado correctamente"
else
    echo "❌ Error con usuario vrx_user"
    echo "🔧 Intentando crear/corregir usuario..."
    
    # Crear el usuario si no existe
    PGPASSWORD="K67lkk7580*98095102*" psql -h postgres -U vrx_user -d vrx_reports -c "
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vrx_user') THEN
            CREATE USER vrx_user WITH PASSWORD 'K67lkk7580*98095102*';
            GRANT ALL PRIVILEGES ON DATABASE vrx_reports TO vrx_user;
            ALTER USER vrx_user CREATEDB;
        ELSE
            ALTER USER vrx_user WITH PASSWORD 'K67lkk7580*98095102*';
        END IF;
    END
    \$\$;" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Usuario vrx_user creado/actualizado"
    else
        echo "❌ Error al crear/actualizar usuario vrx_user"
    fi
fi

# Verificar que la base de datos existe
echo "🔍 Verificando base de datos vrx_reports..."
PGPASSWORD="K67lkk7580*98095102*" psql -h postgres -U vrx_user -d vrx_reports -c "SELECT 'Base de datos vrx_reports verificada' as status;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Base de datos vrx_reports verificada"
else
    echo "❌ Error con base de datos vrx_reports"
fi

echo "✅ Verificación de conexión de Metabase completada"
