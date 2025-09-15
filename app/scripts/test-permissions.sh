#!/bin/bash

# Script de prueba para verificar permisos
echo "🔍 Verificando permisos de scripts..."

# Verificar que los scripts existen
echo "📁 Verificando existencia de scripts:"
ls -la /usr/src/app/scripts/*.sh

echo ""
echo "🔐 Verificando permisos de ejecución:"
for script in /usr/src/app/scripts/*.sh; do
    if [ -x "$script" ]; then
        echo "✅ $script - Ejecutable"
    else
        echo "❌ $script - NO ejecutable"
        echo "   Aplicando permisos..."
        chmod +x "$script"
    fi
done

echo ""
echo "📋 Verificando directorios:"
ls -la /usr/src/app/reports/
ls -la /var/log/

echo ""
echo "✅ Verificación completada"
