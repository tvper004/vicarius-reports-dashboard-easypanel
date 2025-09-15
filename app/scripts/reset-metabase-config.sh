#!/bin/bash

# Script para resetear la configuración de Metabase
echo "🔄 Reseteando configuración de Metabase..."

# Detener Metabase si está corriendo
echo "⏹️ Deteniendo Metabase..."
docker stop metabase 2>/dev/null || true

# Limpiar volúmenes de Metabase
echo "🗑️ Limpiando datos de Metabase..."
docker volume rm vicarius-reports-dashboard_metabase_data 2>/dev/null || true

# Crear nuevo volumen
echo "📁 Creando nuevo volumen de Metabase..."
docker volume create vicarius-reports-dashboard_metabase_data

echo "✅ Configuración de Metabase reseteada"
echo "💡 Metabase se reiniciará con la configuración correcta"
