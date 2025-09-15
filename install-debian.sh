#!/bin/bash

# Script de instalación para Debian con EasyPanel
# vAnalyzer - Vicarius Reports Dashboard

set -e

echo "=== Instalación de vAnalyzer para Debian con EasyPanel ==="

# Verificar que estamos en Debian
if ! grep -q "Debian" /etc/os-release; then
    echo "Advertencia: Este script está optimizado para Debian. Continúe bajo su propio riesgo."
fi

# Actualizar lista de paquetes
echo "Actualizando lista de paquetes..."
sudo apt-get update -y

# Instalar dependencias necesarias
echo "Instalando dependencias..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    wget \
    git \
    unzip

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

# Agregar usuario al grupo docker
echo "Configurando permisos de Docker..."
sudo usermod -aG docker $USER

# Crear directorios necesarios
echo "Creando directorios..."
mkdir -p app/reports
mkdir -p app/logs
mkdir -p app/scripts

# Configurar archivo .env si no existe
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
    exit 0
fi

echo ""
echo "=== Instalación completada ==="
echo ""
echo "Próximos pasos:"
echo "1. Edite el archivo .env con sus credenciales"
echo "2. Ejecute: ./deploy-easypanel.sh"
echo ""
echo "Para obtener sus credenciales de Vicarius:"
echo "- API_KEY: Dashboard > Settings > Integrations > API"
echo "- DASHBOARD_ID: La primera parte de su URL (ej: organization.vicarius.cloud -> organization)"
