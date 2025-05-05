-- ============================================================================
--  Snowflake Setup: 3 Databases & 4 Roles
-- ============================================================================

-- Create databases if they don’t exist
CREATE DATABASE IF NOT EXISTS raw;
CREATE DATABASE IF NOT EXISTS dwh;
CREATE DATABASE IF NOT EXISTS reporting;

-- Create service and human roles
CREATE ROLE IF NOT EXISTS raw_ingest_svc;
CREATE ROLE IF NOT EXISTS transform_svc;
CREATE ROLE IF NOT EXISTS developer;
CREATE ROLE IF NOT EXISTS analyst;

-- 1) Create schemas if they don’t exist
CREATE SCHEMA IF NOT EXISTS raw.landing;
CREATE SCHEMA IF NOT EXISTS dwh.stg;
CREATE SCHEMA IF NOT EXISTS dwh.int;
CREATE SCHEMA IF NOT EXISTS reporting.marts;

-- 2) RAW_INGEST_SVC: least‐privilege grants for raw ingestion
GRANT USAGE, CREATE SCHEMA                             ON DATABASE raw                  TO ROLE raw_ingest_svc;
GRANT USAGE, CREATE STAGE, CREATE FILE FORMAT          ON SCHEMA raw.landing            TO ROLE raw_ingest_svc;
GRANT USAGE, CREATE TABLE                              ON ALL SCHEMAS IN DATABASE raw   TO ROLE raw_ingest_svc;
GRANT INSERT, UPDATE, DELETE, SELECT                   ON ALL TABLES IN DATABASE raw    TO ROLE raw_ingest_svc;
GRANT INSERT, UPDATE, DELETE, SELECT                   ON FUTURE TABLES IN DATABASE raw TO ROLE raw_ingest_svc;

-- 3) TRANSFORM_SVC: builds staging, intermediate, and marts
-- 3a) Read access on raw
GRANT USAGE                                                 ON DATABASE raw                  TO ROLE transform_svc;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE raw   TO ROLE transform_svc;
GRANT SELECT                                                ON ALL TABLES IN DATABASE raw    TO ROLE transform_svc;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE raw TO ROLE transform_svc;
-- 3b) Build access in dwh
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE dwh                  TO ROLE transform_svc;
GRANT USAGE, CREATE TABLE                                   ON ALL SCHEMAS IN DATABASE dwh   TO ROLE transform_svc;
-- 3c) Build access in reporting
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE reporting            TO ROLE transform_svc;
GRANT USAGE, CREATE TABLE                                   ON SCHEMA reporting.marts        TO ROLE transform_svc;

-- 4) DEVELOPER: read-only on raw, dwh & reporting
-- 4a) Read access on raw
GRANT USAGE                                                 ON DATABASE raw                  TO ROLE developer;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE raw   TO ROLE developer;
GRANT SELECT                                                ON ALL TABLES IN DATABASE raw    TO ROLE developer;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE raw TO ROLE developer;
-- 4b) Read access in dwh
GRANT USAGE                                                 ON DATABASE dwh                  TO ROLE developer;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE dwh   TO ROLE developer;
GRANT SELECT                                                ON ALL TABLES IN DATABASE dwh    TO ROLE developer;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE dwh TO ROLE developer;
-- 4c) Read access in reporting
GRANT USAGE                                                 ON DATABASE reporting            TO ROLE developer;
GRANT USAGE                                                 ON SCHEMA reporting.marts        TO ROLE developer;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE developer;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE developer;

-- 5) ANALYST: read-only on final marts only
GRANT USAGE                                                 ON SCHEMA reporting.marts                  TO ROLE analyst;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE analyst;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE analyst;
