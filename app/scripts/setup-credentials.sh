#!/bin/bash

# Script para configurar las credenciales de Vicarius
echo "🔐 Configurando credenciales de Vicarius..."

# Crear directorio de secrets si no existe
mkdir -p /run/secrets

# Crear archivos de secrets si las variables de entorno están definidas
if [ ! -z "$API_KEY" ]; then
    echo "$API_KEY" > /run/secrets/api_key
    echo "✅ API_KEY configurada"
else
    echo "❌ API_KEY no está definida"
fi

if [ ! -z "$DASHBOARD_ID" ]; then
    echo "$DASHBOARD_ID" > /run/secrets/dashboard_id
    echo "✅ DASHBOARD_ID configurado"
else
    echo "❌ DASHBOARD_ID no está definido"
fi

if [ ! -z "$POSTGRES_USER" ]; then
    echo "$POSTGRES_USER" > /run/secrets/postgres_user
    echo "✅ POSTGRES_USER configurado"
else
    echo "❌ POSTGRES_USER no está definido"
fi

if [ ! -z "$POSTGRES_PASSWORD" ]; then
    echo "$POSTGRES_PASSWORD" > /run/secrets/postgres_password
    echo "✅ POSTGRES_PASSWORD configurado"
else
    echo "❌ POSTGRES_PASSWORD no está definido"
fi

if [ ! -z "$POSTGRES_DB" ]; then
    echo "$POSTGRES_DB" > /run/secrets/postgres_db
    echo "✅ POSTGRES_DB configurado"
else
    echo "❌ POSTGRES_DB no está definido"
fi

if [ ! -z "$OPTIONAL_TOOLS" ]; then
    echo "$OPTIONAL_TOOLS" > /run/secrets/optional_tools
    echo "✅ OPTIONAL_TOOLS configurado"
else
    echo "metabase" > /run/secrets/optional_tools
    echo "✅ OPTIONAL_TOOLS configurado con valor por defecto: metabase"
fi

echo "🔐 Configuración de credenciales completada"
