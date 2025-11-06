-- ===========================================
-- This script runs automatically on first DB initialization
-- Purpose: create dedicated Keycloak DB + user with least privileges
-- ===========================================

DROP DATABASE bangalore_db_instance;

-- Create database for Keycloak Bangalore instance
CREATE DATABASE bangalore_db_instance;
-- Create a dedicated user for Keycloak Bangalore
CREATE USER superuser WITH ENCRYPTED PASSWORD 'keycloak@123';
-- Grant full access on the new DB to this user
GRANT ALL PRIVILEGES ON DATABASE bangalore_db_instance TO superuser;
-- Switch to the new DB context to grant schema-level permissions
\connect bangalore_db_instance;
-- Create schema (optional; Keycloak will usually do this automatically)
CREATE SCHEMA IF NOT EXISTS keycloak AUTHORIZATION superuser;
-- Grant privileges on schema and objects
GRANT ALL ON SCHEMA keycloak TO superuser;
ALTER DATABASE bangalore_db_instance OWNER TO superuser;
