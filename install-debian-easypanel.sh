#!/bin/bash

# Script de instalación específico para Debian con EasyPanel
# vAnalyzer - Vicarius Reports Dashboard

set -e

echo "=== Instalación de vAnalyzer para Debian con EasyPanel ==="

# Verificar que estamos en Debian
if ! grep -q "Debian" /etc/os-release; then
    echo "Advertencia: Este script está optimizado para Debian. Continúe bajo su propio riesgo."
    read -p "¿Desea continuar? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Verificar permisos de root
if [ "$EUID" -eq 0 ]; then
    echo "No ejecute este script como root. Use un usuario con permisos sudo."
    exit 1
fi

# Actualizar sistema
echo "Actualizando sistema..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Instalar dependencias del sistema
echo "Instalando dependencias del sistema..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    libpq-dev \
    postgresql-client \
    htop \
    nano \
    vim

# Instalar Docker si no está instalado
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    
    # Agregar clave GPG de Docker
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Agregar repositorio de Docker
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Actualizar e instalar Docker
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker ya está instalado."
fi

# Instalar Docker Compose si no está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Instalando Docker Compose..."
    sudo apt-get install -y docker-compose-plugin
fi

# Configurar Docker
echo "Configurando Docker..."
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

# Verificar instalación de Docker
echo "Verificando instalación de Docker..."
docker --version
docker-compose --version

# Crear directorios necesarios
echo "Creando directorios necesarios..."
mkdir -p app/reports
mkdir -p app/logs
mkdir -p app/scripts
mkdir -p webapp/mgntDash

# Configurar permisos
echo "Configurando permisos..."
chmod +x *.sh
chmod +x app/entrypoint.sh

# Crear archivo .env si no existe
if [ ! -f .env ]; then
    echo "Creando archivo de configuración .env..."
    cp env.example .env
    echo ""
    echo "IMPORTANTE: Debe editar el archivo .env con sus credenciales de Vicarius:"
    echo "  - API_KEY: Su clave API de vRx"
    echo "  - DASHBOARD_ID: Su ID de dashboard (ej: organization en https://organization.vicarius.cloud/)"
    echo "  - POSTGRES_PASSWORD: Una contraseña segura para la base de datos"
    echo ""
    echo "Archivo .env creado. Edítelo antes de continuar."
    echo ""
    echo "Para editar el archivo:"
    echo "  nano .env"
    echo ""
    echo "Después de editar, ejecute:"
    echo "  ./deploy-easypanel.sh"
    exit 0
fi

# Verificar configuración
echo "Verificando configuración..."
if [ -f .env ]; then
    source .env
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "your_vicarius_api_key_here" ]; then
        echo "Error: API_KEY no configurada en .env"
        echo "Edite el archivo .env y configure sus credenciales de Vicarius"
        exit 1
    fi
    
    if [ -z "$DASHBOARD_ID" ] || [ "$DASHBOARD_ID" = "your_dashboard_id_here" ]; then
        echo "Error: DASHBOARD_ID no configurado en .env"
        echo "Edite el archivo .env y configure su dashboard ID"
        exit 1
    fi
    
    if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "your_secure_password_here" ]; then
        echo "Error: POSTGRES_PASSWORD no configurada en .env"
        echo "Edite el archivo .env y configure una contraseña segura"
        exit 1
    fi
    
    echo "Configuración verificada correctamente."
fi

# Crear script de monitoreo del sistema
echo "Creando script de monitoreo..."
cat > monitor-system.sh << 'EOF'
#!/bin/bash
echo "=== Monitoreo del Sistema vAnalyzer ==="
echo "Fecha: $(date)"
echo ""

echo "=== Estado de los Servicios ==="
docker-compose -f docker-compose-easypanel.yml ps

echo ""
echo "=== Uso de Recursos ==="
docker stats --no-stream

echo ""
echo "=== Uso de Disco ==="
df -h

echo ""
echo "=== Logs Recientes ==="
echo "--- App Principal ---"
docker-compose -f docker-compose-easypanel.yml logs --tail=5 app

echo ""
echo "--- PostgreSQL ---"
docker-compose -f docker-compose-easypanel.yml logs --tail=5 postgres

echo ""
echo "=== Verificación de Salud ==="
if docker-compose -f docker-compose-easypanel.yml exec -T app python /usr/src/app/health_check.py 2>/dev/null; then
    echo "✅ Aplicación principal: OK"
else
    echo "❌ Aplicación principal: ERROR"
fi
EOF

chmod +x monitor-system.sh

# Crear script de backup
echo "Creando script de backup..."
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creando backup en $BACKUP_DIR..."

# Backup de la base de datos
echo "Backup de la base de datos..."
docker-compose -f docker-compose-easypanel.yml exec -T postgres pg_dump -U vrx_user vrx_reports > "$BACKUP_DIR/database.sql"

# Backup de archivos de configuración
echo "Backup de configuración..."
cp .env "$BACKUP_DIR/"
cp docker-compose-easypanel.yml "$BACKUP_DIR/"

# Backup de reportes
echo "Backup de reportes..."
if [ -d "app/reports" ]; then
    cp -r app/reports "$BACKUP_DIR/"
fi

# Backup de logs
echo "Backup de logs..."
if [ -d "app/logs" ]; then
    cp -r app/logs "$BACKUP_DIR/"
fi

echo "Backup completado en $BACKUP_DIR"
EOF

chmod +x backup.sh

echo ""
echo "=== Instalación completada exitosamente ==="
echo ""
echo "Servicios disponibles:"
echo "- Base de datos PostgreSQL: puerto 5432 (interno)"
echo "- Aplicación principal: puerto 8000 (interno)"
echo "- Dashboard web (Django): http://localhost:8001"
echo "- Metabase: http://localhost:3000"
echo ""
echo "Comandos útiles:"
echo "- Ver estado: ./monitor-system.sh"
echo "- Crear backup: ./backup.sh"
echo "- Ver logs: docker-compose -f docker-compose-easypanel.yml logs -f"
echo "- Reiniciar: docker-compose -f docker-compose-easypanel.yml restart"
echo ""
echo "Para obtener sus credenciales de Vicarius:"
echo "- API_KEY: Dashboard > Settings > Integrations > API"
echo "- DASHBOARD_ID: La primera parte de su URL (ej: organization.vicarius.cloud -> organization)"
echo ""
echo "Próximo paso: Ejecute ./deploy-easypanel.sh para desplegar los servicios"
