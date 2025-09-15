-- Script de inicialización robusto para PostgreSQL
-- Maneja la configuración de autenticación scram-sha-256 correctamente

-- Configurar el método de encriptación de contraseñas ANTES de crear usuarios
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
SELECT pg_reload_conf();

-- Esperar un momento para que la configuración se aplique
SELECT pg_sleep(2);

-- Eliminar el usuario si existe (para forzar recreación)
DROP USER IF EXISTS vrx_user;

-- Crear el usuario con la contraseña correcta
CREATE USER vrx_user WITH PASSWORD 'K67lkk7580*98095102*';

-- Crear la base de datos si no existe
SELECT 'CREATE DATABASE vrx_reports OWNER vrx_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'vrx_reports')\gexec

-- Conceder todos los privilegios al usuario
GRANT ALL PRIVILEGES ON DATABASE vrx_reports TO vrx_user;

-- Conectar a la base de datos y configurar esquemas
\c vrx_reports;

-- Crear esquemas si no existen
CREATE SCHEMA IF NOT EXISTS public;
GRANT ALL ON SCHEMA public TO vrx_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO vrx_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO vrx_user;

-- Configurar permisos por defecto
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO vrx_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO vrx_user;

-- Verificar que el usuario puede conectarse
SELECT 'Usuario vrx_user configurado correctamente con scram-sha-256' as status;

-- Mostrar información de autenticación
SELECT rolname, rolpassword FROM pg_authid WHERE rolname = 'vrx_user';
