#!/bin/bash

# Script de inicio rápido para vAnalyzer en EasyPanel
# vAnalyzer - Vicarius Reports Dashboard

set -e

echo "🚀 vAnalyzer - Inicio Rápido para EasyPanel"
echo "=========================================="
echo ""

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose-easypanel.yml" ]; then
    echo "❌ Error: Ejecute este script desde el directorio raíz del proyecto"
    exit 1
fi

# Función para mostrar menú
show_menu() {
    echo ""
    echo "Seleccione una opción:"
    echo "1) Instalación completa (recomendado para primera vez)"
    echo "2) Solo configuración (si ya tiene Docker instalado)"
    echo "3) Desplegar servicios (si ya está configurado)"
    echo "4) Probar despliegue"
    echo "5) Ver estado de servicios"
    echo "6) Ver logs"
    echo "7) Detener servicios"
    echo "8) Reiniciar servicios"
    echo "9) Salir"
    echo ""
    read -p "Ingrese su opción (1-9): " choice
}

# Función para verificar configuración
check_config() {
    if [ ! -f .env ]; then
        echo "❌ Archivo .env no encontrado"
        return 1
    fi
    
    source .env
    
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "your_vicarius_api_key_here" ]; then
        echo "❌ API_KEY no configurada"
        return 1
    fi
    
    if [ -z "$DASHBOARD_ID" ] || [ "$DASHBOARD_ID" = "your_dashboard_id_here" ]; then
        echo "❌ DASHBOARD_ID no configurado"
        return 1
    fi
    
    if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "your_secure_password_here" ]; then
        echo "❌ POSTGRES_PASSWORD no configurada"
        return 1
    fi
    
    return 0
}

# Función para mostrar información de credenciales
show_credentials_info() {
    echo ""
    echo "📋 Información de Credenciales de Vicarius:"
    echo "=========================================="
    echo ""
    echo "Para obtener sus credenciales:"
    echo ""
    echo "1. API_KEY:"
    echo "   - Vaya a su dashboard de Vicarius"
    echo "   - Settings > Integrations > Installed Integrations > API"
    echo "   - Copie la API Key"
    echo ""
    echo "2. DASHBOARD_ID:"
    echo "   - Es la primera parte de su URL"
    echo "   - Ejemplo: https://organization.vicarius.cloud/ → organization"
    echo ""
    echo "3. POSTGRES_PASSWORD:"
    echo "   - Cree una contraseña segura para la base de datos"
    echo "   - Mínimo 8 caracteres, con números y símbolos"
    echo ""
}

# Función para configurar .env
configure_env() {
    if [ ! -f .env ]; then
        cp env.example .env
    fi
    
    echo "Configurando archivo .env..."
    echo ""
    
    # API_KEY
    read -p "Ingrese su API_KEY de Vicarius: " api_key
    sed -i "s/API_KEY=.*/API_KEY=$api_key/" .env
    
    # DASHBOARD_ID
    read -p "Ingrese su DASHBOARD_ID: " dashboard_id
    sed -i "s/DASHBOARD_ID=.*/DASHBOARD_ID=$dashboard_id/" .env
    
    # POSTGRES_PASSWORD
    read -sp "Ingrese una contraseña segura para PostgreSQL: " postgres_password
    echo ""
    sed -i "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$postgres_password/" .env
    
    # OPTIONAL_TOOLS
    read -p "Herramientas opcionales (metabase,webapp) [metabase,webapp]: " optional_tools
    optional_tools=${optional_tools:-metabase,webapp}
    sed -i "s/OPTIONAL_TOOLS=.*/OPTIONAL_TOOLS=$optional_tools/" .env
    
    echo ""
    echo "✅ Configuración guardada en .env"
}

# Función para mostrar estado
show_status() {
    echo ""
    echo "📊 Estado de los Servicios:"
    echo "=========================="
    docker-compose -f docker-compose-easypanel.yml ps
    echo ""
    echo "💾 Uso de Recursos:"
    echo "==================="
    docker stats --no-stream
}

# Función para mostrar logs
show_logs() {
    echo ""
    echo "📋 Logs de los Servicios:"
    echo "========================"
    echo "Presione Ctrl+C para salir de los logs"
    echo ""
    docker-compose -f docker-compose-easypanel.yml logs -f
}

# Bucle principal
while true; do
    show_menu
    
    case $choice in
        1)
            echo ""
            echo "🔧 Instalación Completa"
            echo "======================"
            show_credentials_info
            read -p "¿Desea continuar con la instalación? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ./install-debian-easypanel.sh
                configure_env
                ./deploy-easypanel.sh
            fi
            ;;
        2)
            echo ""
            echo "⚙️  Configuración"
            echo "================"
            show_credentials_info
            configure_env
            ;;
        3)
            echo ""
            echo "🚀 Desplegando Servicios"
            echo "======================="
            if check_config; then
                ./deploy-easypanel.sh
            else
                echo "❌ Configuración incompleta. Ejecute la opción 2 primero."
            fi
            ;;
        4)
            echo ""
            echo "🧪 Probando Despliegue"
            echo "====================="
            if check_config; then
                ./test-deployment.sh
            else
                echo "❌ Configuración incompleta. Ejecute la opción 2 primero."
            fi
            ;;
        5)
            show_status
            ;;
        6)
            show_logs
            ;;
        7)
            echo ""
            echo "🛑 Deteniendo Servicios"
            echo "====================="
            docker-compose -f docker-compose-easypanel.yml down
            echo "✅ Servicios detenidos"
            ;;
        8)
            echo ""
            echo "🔄 Reiniciando Servicios"
            echo "======================="
            docker-compose -f docker-compose-easypanel.yml restart
            echo "✅ Servicios reiniciados"
            ;;
        9)
            echo ""
            echo "👋 ¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "❌ Opción inválida. Intente nuevamente."
            ;;
    esac
done
