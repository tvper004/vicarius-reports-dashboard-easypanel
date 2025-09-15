#!/bin/bash

# Script de diagnóstico completo para Vicarius Reports
echo "🔍 DIAGNÓSTICO COMPLETO DE VICARIUS REPORTS"
echo "=========================================="

echo ""
echo "📁 Verificando estructura de directorios:"
echo "   /usr/src/app/scripts/ - $(ls -la /usr/src/app/scripts/ | wc -l) archivos"
echo "   /usr/src/app/reports/ - $(ls -la /usr/src/app/reports/ 2>/dev/null | wc -l) archivos"
echo "   /var/log/ - $(ls -la /var/log/ 2>/dev/null | wc -l) archivos"

echo ""
echo "🔐 Verificando permisos de scripts:"
for script in /usr/src/app/scripts/*.sh; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "   ✅ $(basename $script) - Ejecutable"
        else
            echo "   ❌ $(basename $script) - NO ejecutable"
            chmod +x "$script"
            echo "   🔧 Permisos aplicados a $(basename $script)"
        fi
    fi
done

echo ""
echo "📄 Verificando archivos de configuración:"
if [ -f "/usr/src/app/scripts/state.json" ]; then
    echo "   ✅ state.json existe en scripts/"
else
    echo "   ❌ state.json NO existe en scripts/"
fi

if [ -f "/usr/src/app/reports/state.json" ]; then
    echo "   ✅ state.json existe en reports/"
else
    echo "   ❌ state.json NO existe en reports/"
    if [ -f "/usr/src/app/scripts/state.json" ]; then
        cp /usr/src/app/scripts/state.json /usr/src/app/reports/state.json
        echo "   🔧 state.json copiado a reports/"
    fi
fi

echo ""
echo "🔑 Verificando credenciales:"
if [ -f "/run/secrets/api_key" ]; then
    echo "   ✅ API_KEY configurada"
else
    echo "   ❌ API_KEY NO configurada"
fi

if [ -f "/run/secrets/dashboard_id" ]; then
    echo "   ✅ DASHBOARD_ID configurado"
else
    echo "   ❌ DASHBOARD_ID NO configurado"
fi

if [ -f "/run/secrets/postgres_user" ]; then
    echo "   ✅ POSTGRES_USER configurado"
else
    echo "   ❌ POSTGRES_USER NO configurado"
fi

if [ -f "/run/secrets/postgres_password" ]; then
    echo "   ✅ POSTGRES_PASSWORD configurado"
else
    echo "   ❌ POSTGRES_PASSWORD NO configurado"
fi

echo ""
echo "🌐 Verificando conectividad:"
if command -v python3 >/dev/null 2>&1; then
    echo "   ✅ Python3 disponible"
else
    echo "   ❌ Python3 NO disponible"
fi

if command -v psql >/dev/null 2>&1; then
    echo "   ✅ PostgreSQL client disponible"
else
    echo "   ❌ PostgreSQL client NO disponible"
fi

echo ""
echo "📊 Verificando variables de entorno:"
echo "   API_KEY: ${API_KEY:-NO CONFIGURADA}"
echo "   DASHBOARD_ID: ${DASHBOARD_ID:-NO CONFIGURADA}"
echo "   POSTGRES_HOST: ${POSTGRES_HOST:-NO CONFIGURADA}"
echo "   POSTGRES_DB: ${POSTGRES_DB:-NO CONFIGURADA}"

echo ""
echo "✅ Diagnóstico completado"
echo "=========================================="
