# vAnalyzer - Vicarius Reports Dashboard

Sistema de reportes de vulnerabilidades de Vicarius adaptado para **Debian con EasyPanel**.

## 🚀 Características

- **Sincronización automática** de datos de vRx
- **Dashboard web** con Django
- **Metabase** para análisis de Business Intelligence
- **PostgreSQL** como base de datos principal
- **Docker Compose** para fácil despliegue
- **Health checks** automáticos
- **Scripts de monitoreo** y backup

## 📋 Requisitos del Sistema

- **OS**: Debian (recomendado) o Ubuntu
- **RAM**: Mínimo 2GB, recomendado 4GB
- **CPU**: Mínimo 2 cores, recomendado 4 cores
- **Disco**: Mínimo 20GB, recomendado 50GB
- **Docker**: Versión 20.10+
- **Docker Compose**: Versión 2.0+

## 🛠️ Instalación Rápida

### Opción 1: Menú Interactivo (Recomendado)
```bash
git clone <tu-repositorio>
cd vicarius-Reports-Dashboard
./quick-start.sh
```

### Opción 2: Instalación Manual
```bash
# 1. Clonar repositorio
git clone <tu-repositorio>
cd vicarius-Reports-Dashboard

# 2. Instalación completa
./install-debian-easypanel.sh

# 3. Configurar credenciales
nano .env

# 4. Desplegar servicios
./deploy-easypanel.sh
```

## ⚙️ Configuración

### Variables de Entorno Requeridas

Edite el archivo `.env` con sus credenciales:

```bash
# Base de datos
POSTGRES_DB=vrx_reports
POSTGRES_USER=vrx_user
POSTGRES_PASSWORD=tu_contraseña_segura

# API de Vicarius
API_KEY=tu_api_key_de_vicarius
DASHBOARD_ID=tu_dashboard_id

# Herramientas opcionales
OPTIONAL_TOOLS=metabase,webapp

# Metabase
MB_ENCRYPTION_SECRET_KEY=tu_clave_secreta_metabase
```

### Obtener Credenciales de Vicarius

1. **API_KEY**: Dashboard > Settings > Integrations > API
2. **DASHBOARD_ID**: Primera parte de su URL (ej: `organization` en `https://organization.vicarius.cloud/`)

## 🐳 Servicios Incluidos

| Servicio | Puerto | Descripción | Acceso |
|----------|--------|-------------|---------|
| PostgreSQL | 5432 | Base de datos principal | Interno |
| App Principal | 8000 | Scripts de sincronización | Interno |
| Dashboard Web | 8001 | Interfaz Django | http://localhost:8001 |
| Metabase | 3000 | BI Dashboard | http://localhost:3000 |

## 📊 Uso

### Comandos Principales

```bash
# Ver estado de servicios
docker-compose -f docker-compose-easypanel.yml ps

# Ver logs en tiempo real
docker-compose -f docker-compose-easypanel.yml logs -f

# Reiniciar servicios
docker-compose -f docker-compose-easypanel.yml restart

# Detener servicios
docker-compose -f docker-compose-easypanel.yml down

# Actualizar y reconstruir
docker-compose -f docker-compose-easypanel.yml up -d --build
```

### Scripts de Utilidad

```bash
# Monitoreo del sistema
./monitor-system.sh

# Crear backup
./backup.sh

# Probar despliegue
./test-deployment.sh
```

## 🔧 Configuración Avanzada

### Personalizar Servicios

Edite `docker-compose-easypanel.yml` para habilitar/deshabilitar servicios:

```yaml
# Para deshabilitar Metabase, comente estas líneas:
# metabase:
#   image: metabase/metabase:latest
#   ...

# Para deshabilitar el Dashboard Web, comente estas líneas:
# webapp:
#   build:
#     context: ./webapp/mgntDash
#   ...
```

### Configuración de Metabase

1. Acceda a http://localhost:3000
2. Use las credenciales por defecto:
   - Usuario: `vrxadmin@vrxadmin.com`
   - Contraseña: `Vicarius123!@#`
3. Configure la base de datos `vrx_reports`

## 🔍 Solución de Problemas

### Verificar Estado
```bash
# Estado de servicios
docker-compose -f docker-compose-easypanel.yml ps

# Logs de errores
docker-compose -f docker-compose-easypanel.yml logs --tail=50

# Health check
docker-compose -f docker-compose-easypanel.yml exec app python /usr/src/app/health_check.py
```

### Problemas Comunes

1. **Error de conexión a BD**: Verificar que PostgreSQL esté corriendo
2. **API no responde**: Verificar API_KEY y DASHBOARD_ID
3. **Metabase no carga**: Esperar 2-3 minutos para inicialización

## 📁 Estructura del Proyecto

```
vicarius-Reports-Dashboard/
├── app/                          # Aplicación principal
│   ├── scripts/                  # Scripts Python
│   ├── reports/                  # Reportes generados
│   ├── logs/                     # Logs de la aplicación
│   └── Dockerfile               # Imagen de la app
├── webapp/                       # Dashboard web Django
│   └── mgntDash/                # Aplicación Django
├── docker-compose-easypanel.yml  # Configuración Docker Compose
├── env.example                   # Plantilla de variables
├── install-debian-easypanel.sh   # Script de instalación
├── deploy-easypanel.sh          # Script de despliegue
├── quick-start.sh               # Menú interactivo
└── README-EasyPanel.md          # Documentación detallada
```

## 🔄 Actualizaciones

```bash
# Actualizar código
git pull

# Reconstruir y desplegar
docker-compose -f docker-compose-easypanel.yml up -d --build
```

## 📝 Notas de Migración

Este proyecto ha sido adaptado desde la versión original de Ubuntu con Docker Swarm:

- ✅ Eliminada dependencia de Docker Swarm
- ✅ Reemplazado por Docker Compose estándar
- ✅ Simplificada la gestión de secretos
- ✅ Agregados health checks
- ✅ Scripts específicos para Debian
- ✅ Documentación actualizada

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Cree una rama para su feature
3. Commit sus cambios
4. Push a la rama
5. Abra un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia del proyecto original de Vicarius.

## 🆘 Soporte

Para soporte técnico:

1. Revise la documentación en `README-EasyPanel.md`
2. Verifique los logs del sistema
3. Consulte los issues del repositorio
4. Contacte al equipo de desarrollo

---

**Desarrollado para Debian con EasyPanel** 🐧