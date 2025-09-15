#!/bin/sh
# Run your script

# Ejecutar diagnóstico completo
echo "🔍 Ejecutando diagnóstico completo..."
/usr/src/app/scripts/diagnose.sh

# Verificar y corregir permisos de scripts
echo "🔍 Verificando permisos de scripts..."
chmod +x /usr/src/app/scripts/*.sh

# Ejecutar script de inicialización
echo "🚀 Ejecutando inicialización..."
/usr/src/app/scripts/init-app.sh

# Configurar credenciales
echo "🔐 Configurando credenciales..."
/usr/src/app/scripts/setup-credentials.sh

# Source and destination file paths
SRC_FILE="/usr/src/app/scripts/state.json"
DEST_FILE="/usr/src/app/reports/state.json"

mkdir -p /usr/src/app/reports
mkdir -p /var/log

# Check if the destination file does not exist
if [ ! -f "$DEST_FILE" ]; then
    # If it does not exist, copy the source file to the destination
    cp "$SRC_FILE" "$DEST_FILE"
    echo "📄 state.json copiado a reports/"
fi

# Verificar que las credenciales estén configuradas
if [ -z "$API_KEY" ] || [ -z "$DASHBOARD_ID" ]; then
    echo "❌ ERROR: Las credenciales de la API no están configuradas"
    echo "📝 Configura las siguientes variables de entorno:"
    echo "   - API_KEY: Tu clave de API de Vicarius"
    echo "   - DASHBOARD_ID: Tu ID de dashboard de Vicarius"
    echo ""
    echo "💡 Ejemplo de configuración en docker-compose:"
    echo "   environment:"
    echo "     - API_KEY=tu_api_key_aqui"
    echo "     - DASHBOARD_ID=tu_dashboard_id_aqui"
    echo ""
    echo "⏳ Esperando 60 segundos antes de continuar..."
    sleep 60
fi

sleep 20

#/usr/local/bin/python /usr/src/app/scripts/VickyTopiaReportCLI.py --allreports  >> /var/log/crontab.log 2>&1
#Initial Pull 
echo "Initial Pull: Starting" 
date
/usr/local/bin/python /usr/src/app/scripts/VickyTopiaReportCLI.py --allreports >> /var/log/initialsync.log 2>&1
#nohup /usr/local/bin/python /usr/src/app/scripts/launcher.py &
echo "Initial Pull: Completed" 
date

# Start cron in foreground
#cron -f
echo "Starting Scheduler"
date
/usr/local/bin/python /usr/src/app/scripts/launcher.py
