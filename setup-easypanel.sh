#!/bin/bash

# Script de configuración para EasyPanel
# vAnalyzer - Vicarius Reports Dashboard

set -e

echo "=== Configuración de vAnalyzer para EasyPanel ==="

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose-easypanel.yml" ]; then
    echo "Error: Ejecute este script desde el directorio raíz del proyecto"
    exit 1
fi

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "Creando archivo .env desde plantilla..."
    cp env.example .env
    echo "Archivo .env creado. Debe editarlo con sus credenciales."
fi

# Crear directorios necesarios
echo "Creando directorios necesarios..."
mkdir -p app/reports
mkdir -p app/logs
mkdir -p app/scripts
mkdir -p webapp/mgntDash/db.sqlite3

# Configurar permisos
echo "Configurando permisos..."
chmod +x install-debian.sh
chmod +x deploy-easypanel.sh
chmod +x app/entrypoint.sh

# Crear script de health check para la aplicación
echo "Creando script de health check..."
cat > app/health_check.py << 'EOF'
#!/usr/bin/env python3
import os
import sys
import requests
import psycopg2
from datetime import datetime

def check_database():
    """Verificar conexión a la base de datos"""
    try:
        conn = psycopg2.connect(
            host=os.getenv('POSTGRES_HOST', 'postgres'),
            port=os.getenv('POSTGRES_PORT', '5432'),
            database=os.getenv('POSTGRES_DB', 'vrx_reports'),
            user=os.getenv('POSTGRES_USER', 'vrx_user'),
            password=os.getenv('POSTGRES_PASSWORD', 'vrx_password')
        )
        conn.close()
        return True
    except Exception as e:
        print(f"Database check failed: {e}")
        return False

def check_api():
    """Verificar que la API de Vicarius esté configurada"""
    api_key = os.getenv('API_KEY')
    dashboard_id = os.getenv('DASHBOARD_ID')
    
    if not api_key or not dashboard_id:
        print("API credentials not configured")
        return False
    
    return True

def main():
    """Health check principal"""
    print(f"Health check at {datetime.now()}")
    
    db_ok = check_database()
    api_ok = check_api()
    
    if db_ok and api_ok:
        print("Health check: OK")
        sys.exit(0)
    else:
        print("Health check: FAILED")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

chmod +x app/health_check.py

# Crear script de inicialización mejorado
echo "Creando script de inicialización..."
cat > app/init_app.py << 'EOF'
#!/usr/bin/env python3
import os
import sys
import time
import psycopg2
from datetime import datetime

def wait_for_database():
    """Esperar a que la base de datos esté disponible"""
    max_retries = 30
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            conn = psycopg2.connect(
                host=os.getenv('POSTGRES_HOST', 'postgres'),
                port=os.getenv('POSTGRES_PORT', '5432'),
                database=os.getenv('POSTGRES_DB', 'vrx_reports'),
                user=os.getenv('POSTGRES_USER', 'vrx_user'),
                password=os.getenv('POSTGRES_PASSWORD', 'vrx_password')
            )
            conn.close()
            print("Database connection successful")
            return True
        except Exception as e:
            print(f"Database connection failed (attempt {retry_count + 1}/{max_retries}): {e}")
            retry_count += 1
            time.sleep(10)
    
    print("Failed to connect to database after maximum retries")
    return False

def main():
    print(f"Initializing application at {datetime.now()}")
    
    if not wait_for_database():
        sys.exit(1)
    
    print("Application initialization completed successfully")

if __name__ == "__main__":
    main()
EOF

chmod +x app/init_app.py

echo ""
echo "=== Configuración completada ==="
echo ""
echo "Próximos pasos:"
echo "1. Edite el archivo .env con sus credenciales de Vicarius"
echo "2. Ejecute: ./deploy-easypanel.sh"
echo ""
echo "Para obtener sus credenciales:"
echo "- API_KEY: Dashboard > Settings > Integrations > API"
echo "- DASHBOARD_ID: La primera parte de su URL (ej: organization.vicarius.cloud -> organization)"
