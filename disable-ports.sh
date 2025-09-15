#!/bin/bash

# Script para deshabilitar puertos en docker-compose-easypanel.yml
# Esto resuelve los conflictos de puertos en EasyPanel

echo "🔧 Deshabilitando puertos para evitar conflictos en EasyPanel..."

# Crear backup del archivo original
cp docker-compose-easypanel.yml docker-compose-easypanel.yml.backup

# Comentar las secciones de puertos
sed -i.tmp 's/^    ports:/    # ports:/g' docker-compose-easypanel.yml
sed -i.tmp 's/^      - "\([0-9]*:[0-9]*\)"/      # - "\1"/g' docker-compose-easypanel.yml

# Limpiar archivo temporal
rm docker-compose-easypanel.yml.tmp

echo "✅ Puertos deshabilitados en docker-compose-easypanel.yml"
echo "📝 Backup creado como docker-compose-easypanel.yml.backup"
echo ""
echo "Para habilitar los puertos nuevamente, ejecuta:"
echo "  cp docker-compose-easypanel.yml.backup docker-compose-easypanel.yml"
