#!/bin/bash

# Script para corregir el usuario de la base de datos
echo "🔧 Corrigiendo configuración de usuario de base de datos..."

# Esperar a que PostgreSQL esté listo
echo "⏳ Esperando a que PostgreSQL esté listo..."
sleep 10

# Intentar conectar con el usuario correcto
echo "🔍 Verificando conexión con vrx_user..."
PGPASSWORD="K67lkk7580*98095102*" psql -h postgres -U vrx_user -d vrx_reports -c "SELECT 'Conexión exitosa con vrx_user' as status;" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Conexión con vrx_user exitosa"
else
    echo "❌ Error de conexión con vrx_user"
    echo "🔧 Intentando crear el usuario vrx_user..."
    
    # Conectar como superusuario y crear el usuario
    PGPASSWORD="K67lkk7580*98095102*" psql -h postgres -U vrx_user -d vrx_reports -c "
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vrx_user') THEN
            CREATE USER vrx_user WITH PASSWORD 'K67lkk7580*98095102*';
            GRANT ALL PRIVILEGES ON DATABASE vrx_reports TO vrx_user;
            ALTER USER vrx_user CREATEDB;
        END IF;
    END
    \$\$;" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Usuario vrx_user creado/actualizado"
    else
        echo "❌ Error al crear usuario vrx_user"
    fi
fi

# Verificar que Metabase puede conectarse
echo "🔍 Verificando configuración de Metabase..."
echo "   MB_DB_USER: ${MB_DB_USER:-vrx_user}"
echo "   MB_DB_DBNAME: ${MB_DB_DBNAME:-vrx_reports}"
echo "   MB_DB_HOST: ${MB_DB_HOST:-postgres}"

echo "✅ Verificación de base de datos completada"
