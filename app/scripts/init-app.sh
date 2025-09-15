#!/bin/bash

# Script de inicialización para la aplicación Vicarius Reports
echo "🚀 Inicializando aplicación Vicarius Reports..."

# Crear directorios necesarios
mkdir -p /usr/src/app/reports
mkdir -p /usr/src/app/logs
mkdir -p /var/log

# Copiar state.json si no existe
if [ ! -f "/usr/src/app/reports/state.json" ]; then
    echo "📄 Copiando state.json a reports..."
    cp /usr/src/app/scripts/state.json /usr/src/app/reports/state.json
fi

# Crear archivos de log vacíos
touch /var/log/refreshTables.log
touch /var/log/difTables.log
touch /var/log/crontab.log
touch /var/log/scheduler_log.log

# Establecer permisos
chmod 666 /var/log/*.log
chmod 644 /usr/src/app/reports/state.json

echo "✅ Inicialización completada"
echo "📝 Archivos creados:"
echo "   - /usr/src/app/reports/state.json"
echo "   - /var/log/refreshTables.log"
echo "   - /var/log/difTables.log"
echo "   - /var/log/crontab.log"
echo "   - /var/log/scheduler_log.log"
