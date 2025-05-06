-- ============================================================================
--  Snowflake Setup: 3 Databases & 5 Roles
-- ============================================================================

-- 1) Create databases if they don’t exist
CREATE DATABASE IF NOT EXISTS raw;
CREATE DATABASE IF NOT EXISTS dwh;
CREATE DATABASE IF NOT EXISTS reporting;

-- 2) Create service and human roles
CREATE ROLE IF NOT EXISTS raw_ingest_svc;
CREATE ROLE IF NOT EXISTS transform_svc;
CREATE ROLE IF NOT EXISTS developer;
CREATE ROLE IF NOT EXISTS analyst;
CREATE ROLE IF NOT EXISTS reporting_svc;

-- 3) Create schemas if they don’t exist
CREATE SCHEMA IF NOT EXISTS raw.landing;
CREATE SCHEMA IF NOT EXISTS dwh.stg;
CREATE SCHEMA IF NOT EXISTS dwh.int;
CREATE SCHEMA IF NOT EXISTS reporting.marts;

-- 4) RAW_INGEST_SVC: least‐privilege grants for raw ingestion
GRANT USAGE, CREATE SCHEMA                             ON DATABASE raw                  TO ROLE raw_ingest_svc;
GRANT USAGE, CREATE STAGE, CREATE FILE FORMAT          ON SCHEMA raw.landing            TO ROLE raw_ingest_svc;
GRANT USAGE, CREATE TABLE                              ON ALL SCHEMAS IN DATABASE raw   TO ROLE raw_ingest_svc;
GRANT INSERT, UPDATE, DELETE, SELECT                   ON ALL TABLES IN DATABASE raw    TO ROLE raw_ingest_svc;
GRANT INSERT, UPDATE, DELETE, SELECT                   ON FUTURE TABLES IN DATABASE raw TO ROLE raw_ingest_svc;

-- 5) TRANSFORM_SVC: builds staging, intermediate, and marts
-- 5a) Read access on raw
GRANT USAGE                                                 ON DATABASE raw                  TO ROLE transform_svc;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE raw   TO ROLE transform_svc;
GRANT SELECT                                                ON ALL TABLES IN DATABASE raw    TO ROLE transform_svc;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE raw TO ROLE transform_svc;
-- 5b) Build access in dwh
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE dwh                  TO ROLE transform_svc;
GRANT USAGE, CREATE TABLE                                   ON ALL SCHEMAS IN DATABASE dwh   TO ROLE transform_svc;
-- 5c) Build access in reporting
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE reporting            TO ROLE transform_svc;
GRANT USAGE, CREATE TABLE                                   ON SCHEMA reporting.marts        TO ROLE transform_svc;

-- 6) DEVELOPER: read-only on raw, dwh & reporting
-- 6a) Read access on raw
GRANT USAGE                                                 ON DATABASE raw                  TO ROLE developer;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE raw   TO ROLE developer;
GRANT SELECT                                                ON ALL TABLES IN DATABASE raw    TO ROLE developer;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE raw TO ROLE developer;
-- 6b) Read access in dwh
GRANT USAGE                                                 ON DATABASE dwh                  TO ROLE developer;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE dwh   TO ROLE developer;
GRANT SELECT                                                ON ALL TABLES IN DATABASE dwh    TO ROLE developer;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE dwh TO ROLE developer;
-- 6c) Read access in reporting
GRANT USAGE                                                 ON DATABASE reporting            TO ROLE developer;
GRANT USAGE                                                 ON SCHEMA reporting.marts        TO ROLE developer;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE developer;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE developer;

-- 7) ANALYST: read-only on final marts only
GRANT USAGE                                                 ON SCHEMA reporting.marts                  TO ROLE analyst;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE analyst;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE analyst;

-- 8) REPORTING_SVC: read-only on final marts only
GRANT USAGE                                                 ON SCHEMA reporting.marts                  TO ROLE reporting_svc;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE reporting_svc;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE reporting_svc;

-- ============================================================================
-- Monitoring & Operations Privileges
-- ============================================================================

-- Allow roles to see running and historical queries, warehouse usage, etc.
GRANT MONITOR ON ACCOUNT                TO ROLE transform_svc;
GRANT MONITOR ON ACCOUNT                TO ROLE developer;
GRANT MONITOR ON ACCOUNT                TO ROLE reporting_svc;

-- For Tasks or Streams, gives TRANSFORM_SVC the right to operate them:
GRANT OPERATE ON ALL TASKS IN SCHEMA dwh.int      TO ROLE transform_svc;
GRANT OPERATE ON FUTURE TASKS IN SCHEMA dwh.int   TO ROLE transform_svc;

-- Allow transform_svc to create and read from any existing and future streams
GRANT CREATE STREAM                ON SCHEMA dwh.stg        TO ROLE transform_svc;
GRANT USAGE                        ON SCHEMA dwh.stg        TO ROLE transform_svc;
GRANT SELECT                       ON ALL STREAMS IN SCHEMA dwh.stg       TO ROLE transform_svc;
GRANT SELECT                       ON FUTURE STREAMS IN SCHEMA dwh.stg    TO ROLE transform_svc;
