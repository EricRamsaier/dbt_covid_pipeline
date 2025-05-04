-- ============================================================================
--  Database & Role Bootstrap Macro
-- ============================================================================

-- Create databases if they don’t exist
CREATE DATABASE IF NOT EXISTS dwh;
CREATE DATABASE IF NOT EXISTS analytics;

-- Create roles (idempotent—fails if already exists)
CREATE ROLE IF NOT EXISTS etl_role;
CREATE ROLE IF NOT EXISTS dev_role;
CREATE ROLE IF NOT EXISTS analyst_role;

-- Create your schemas if they don’t exist
CREATE SCHEMA IF NOT EXISTS dwh.stg;
CREATE SCHEMA IF NOT EXISTS dwh.int;
CREATE SCHEMA IF NOT EXISTS analytics.marts;

-- ETL_ROLE needs full control over staging & marts
GRANT USAGE, CREATE SCHEMA            ON DATABASE dwh          TO ROLE etl_role;
GRANT USAGE, CREATE TABLE             ON SCHEMA   dwh.stg      TO ROLE etl_role;
GRANT USAGE, CREATE TABLE             ON SCHEMA   dwh.int      TO ROLE etl_role;

GRANT USAGE, CREATE SCHEMA            ON DATABASE analytics   TO ROLE etl_role;
GRANT USAGE, CREATE TABLE             ON SCHEMA   analytics.marts TO ROLE etl_role;

-- DEV_ROLE needs read‐only access to everything, including future tables
GRANT USAGE                          ON DATABASE dwh          TO ROLE dev_role;
GRANT USAGE                          ON SCHEMA   dwh.stg      TO ROLE dev_role;
GRANT USAGE                          ON SCHEMA   dwh.int      TO ROLE dev_role;
GRANT SELECT ON ALL TABLES           IN SCHEMA   dwh.stg      TO ROLE dev_role;
GRANT SELECT ON ALL TABLES           IN SCHEMA   dwh.int      TO ROLE dev_role;
GRANT SELECT ON FUTURE TABLES        IN SCHEMA   dwh.stg      TO ROLE dev_role;
GRANT SELECT ON FUTURE TABLES        IN SCHEMA   dwh.int      TO ROLE dev_role;

GRANT USAGE                          ON DATABASE analytics   TO ROLE dev_role;
GRANT USAGE                          ON SCHEMA   analytics.marts TO ROLE dev_role;
GRANT SELECT ON ALL TABLES           IN SCHEMA   analytics.marts TO ROLE dev_role;
GRANT SELECT ON FUTURE TABLES        IN SCHEMA   analytics.marts TO ROLE dev_role;

-- ANALYST_ROLE only needs USAGE + SELECT on the final marts
GRANT USAGE                          ON SCHEMA   analytics.marts TO ROLE analyst_role;
GRANT SELECT ON ALL TABLES           IN SCHEMA   analytics.marts TO ROLE analyst_role;
GRANT SELECT ON FUTURE TABLES        IN SCHEMA   analytics.marts TO ROLE analyst_role;

--[ Optional cleanup / undrop examples ]

-- To drop the schemas:
-- DROP SCHEMA IF EXISTS dwh.stg;
-- DROP SCHEMA IF EXISTS dwh.int;
-- DROP SCHEMA IF EXISTS analytics.marts;

-- To undrop (time‐travel restore):
-- UNDROP DATABASE dwh;
-- CREATE DATABASE dwh_recovery
--   CLONE dwh
--   BEFORE (TIMESTAMP => TO_TIMESTAMP_LTZ('2025-05-04 14:00:00'));
