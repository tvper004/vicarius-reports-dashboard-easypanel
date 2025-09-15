-- Script de inicialización para PostgreSQL
-- Configura el usuario y la base de datos correctamente

-- Configurar el método de encriptación de contraseñas
ALTER SYSTEM SET password_encryption = 'scram-sha-256';
SELECT pg_reload_conf();

-- Crear el usuario si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vrx_user') THEN
        CREATE USER vrx_user WITH PASSWORD 'K67lkk7580*98095102*';
    ELSE
        -- Actualizar la contraseña del usuario existente
        ALTER USER vrx_user WITH PASSWORD 'K67lkk7580*98095102*';
    END IF;
END
$$;

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
SELECT 'Usuario vrx_user configurado correctamente' as status;
