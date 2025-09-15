# vAnalyzer - Vicarius Reports Dashboard para EasyPanel

Este proyecto ha sido adaptado para funcionar en **Debian con EasyPanel**, eliminando la dependencia de Docker Swarm y simplificando el despliegue.

## 🚀 Instalación Rápida

### 1. Preparación del Sistema

```bash
# Clonar o descargar el proyecto
git clone <tu-repositorio>
cd vicarius-Reports-Dashboard

# Hacer ejecutables los scripts
chmod +x *.sh
```

### 2. Configuración Inicial

```bash
# Ejecutar script de configuración
./setup-easypanel.sh
```

### 3. Configurar Credenciales

Edite el archivo `.env` con sus credenciales de Vicarius:

```bash
nano .env
```

**Variables requeridas:**
- `API_KEY`: Su clave API de vRx (obtener desde Dashboard > Settings > Integrations > API)
- `DASHBOARD_ID`: Su ID de dashboard (ej: "organization" en https://organization.vicarius.cloud/)
- `POSTGRES_PASSWORD`: Contraseña segura para la base de datos

### 4. Desplegar Servicios

```bash
# Desplegar todos los servicios
./deploy-easypanel.sh
```

## 📋 Servicios Incluidos

| Servicio | Puerto | Descripción | Acceso |
|----------|--------|-------------|---------|
| PostgreSQL | 5432 | Base de datos principal | Interno |
| App Principal | 8000 | Scripts de sincronización | Interno |
| Dashboard Web | 8001 | Interfaz Django | http://localhost:8001 |
| Metabase | 3000 | BI Dashboard | http://localhost:3000 |

## 🔧 Configuración Avanzada

### Variables de Entorno

```bash
# Base de datos
POSTGRES_DB=vrx_reports
POSTGRES_USER=vrx_user
POSTGRES_PASSWORD=tu_contraseña_segura

# API de Vicarius
API_KEY=tu_api_key_aqui
DASHBOARD_ID=tu_dashboard_id

# Herramientas opcionales
OPTIONAL_TOOLS=metabase,webapp

# Metabase
MB_ENCRYPTION_SECRET_KEY=tu_clave_secreta_metabase
```

### Personalización de Servicios

Puede habilitar/deshabilitar servicios editando el archivo `docker-compose-easypanel.yml`:

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

## 🛠️ Comandos Útiles

```bash
# Ver estado de los servicios
docker-compose -f docker-compose-easypanel.yml ps

# Ver logs en tiempo real
docker-compose -f docker-compose-easypanel.yml logs -f

# Reiniciar un servicio específico
docker-compose -f docker-compose-easypanel.yml restart app

# Detener todos los servicios
docker-compose -f docker-compose-easypanel.yml down

# Actualizar y reconstruir
docker-compose -f docker-compose-easypanel.yml up -d --build
```

## 🔍 Solución de Problemas

### Verificar Estado de los Servicios

```bash
# Verificar que todos los contenedores estén corriendo
docker-compose -f docker-compose-easypanel.yml ps

# Verificar logs de errores
docker-compose -f docker-compose-easypanel.yml logs --tail=50
```

### Problemas Comunes

1. **Error de conexión a la base de datos**
   - Verificar que PostgreSQL esté corriendo: `docker-compose -f docker-compose-easypanel.yml ps postgres`
   - Revisar logs: `docker-compose -f docker-compose-easypanel.yml logs postgres`

2. **API de Vicarius no responde**
   - Verificar que `API_KEY` y `DASHBOARD_ID` estén correctos
   - Revisar logs de la aplicación: `docker-compose -f docker-compose-easypanel.yml logs app`

3. **Metabase no carga**
   - Esperar 2-3 minutos para la inicialización completa
   - Verificar logs: `docker-compose -f docker-compose-easypanel.yml logs metabase`

### Logs Importantes

```bash
# Logs de sincronización inicial
tail -f app/logs/initialsync.log

# Logs del scheduler
tail -f app/logs/scheduler_log.log

# Logs de la aplicación principal
docker-compose -f docker-compose-easypanel.yml logs app
```

## 📊 Monitoreo

### Health Checks

La aplicación incluye health checks automáticos:

```bash
# Verificar salud de la aplicación
docker-compose -f docker-compose-easypanel.yml exec app python /usr/src/app/health_check.py
```

### Métricas de Recursos

```bash
# Ver uso de recursos
docker stats

# Ver uso de disco
docker system df
```

## 🔄 Actualizaciones

### Actualizar la Aplicación

```bash
# Detener servicios
docker-compose -f docker-compose-easypanel.yml down

# Actualizar código
git pull

# Reconstruir y desplegar
docker-compose -f docker-compose-easypanel.yml up -d --build
```

### Backup de Datos

```bash
# Backup de la base de datos
docker-compose -f docker-compose-easypanel.yml exec postgres pg_dump -U vrx_user vrx_reports > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup de volúmenes
docker run --rm -v vicarius-reports-dashboard_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .
```

## 🆘 Soporte

Si encuentra problemas:

1. Verifique los logs: `docker-compose -f docker-compose-easypanel.yml logs -f`
2. Revise la configuración en `.env`
3. Verifique que las credenciales de Vicarius sean correctas
4. Asegúrese de que el sistema tenga suficientes recursos (mínimo 2GB RAM, 2 CPU cores)

## 📝 Notas de Migración desde Ubuntu

Los principales cambios realizados para la adaptación a EasyPanel:

- ✅ Eliminada dependencia de Docker Swarm
- ✅ Reemplazado por Docker Compose estándar
- ✅ Simplificada la gestión de secretos (usando variables de entorno)
- ✅ Agregados health checks para mejor monitoreo
- ✅ Creados scripts de instalación específicos para Debian
- ✅ Documentación actualizada para EasyPanel

## 🎯 Próximos Pasos

Después de la instalación exitosa:

1. Configure Metabase con la base de datos `vrx_reports`
2. Personalice los dashboards según sus necesidades
3. Configure alertas y notificaciones
4. Establezca un plan de backup regular
5. Monitoree el rendimiento y ajuste recursos según sea necesario
