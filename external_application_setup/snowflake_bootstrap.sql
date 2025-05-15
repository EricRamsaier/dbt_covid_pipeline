-- ============================================================================
--  Snowflake Setup: 4 Databases & 5 Roles
-- ============================================================================

-- 1) Create databases if they don’t exist
CREATE DATABASE IF NOT EXISTS raw;
CREATE DATABASE IF NOT EXISTS dwh;
CREATE DATABASE IF NOT EXISTS reporting;
CREATE DATABASE IF NOT EXISTS landing_ext;

-- 2) Create service and human roles
CREATE ROLE IF NOT EXISTS raw_ingest_svc_role;
CREATE ROLE IF NOT EXISTS transform_svc_role;
CREATE ROLE IF NOT EXISTS developer_role;
CREATE ROLE IF NOT EXISTS analyst_role;
CREATE ROLE IF NOT EXISTS reporting_svc_role;

-- 3) Create schemas if they don’t exist
CREATE SCHEMA IF NOT EXISTS landing_ext.s3;
CREATE SCHEMA IF NOT EXISTS dwh.stg;
CREATE SCHEMA IF NOT EXISTS dwh.int;
CREATE SCHEMA IF NOT EXISTS reporting.marts;

-- 4) RAW_INGEST_SVC_ROLE: least‐privilege grants for raw ingestion
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE landing_ext          TO ROLE raw_ingest_svc_role;
GRANT USAGE, CREATE STAGE, CREATE FILE FORMAT               ON SCHEMA landing_ext.s3         TO ROLE raw_ingest_svc_role;

GRANT USAGE, CREATE SCHEMA                                  ON DATABASE raw                  TO ROLE raw_ingest_svc_role;
GRANT USAGE, CREATE TABLE                                   ON ALL SCHEMAS IN DATABASE raw   TO ROLE raw_ingest_svc_role;
GRANT INSERT, UPDATE, DELETE, SELECT                        ON ALL TABLES IN DATABASE raw    TO ROLE raw_ingest_svc_role;
GRANT INSERT, UPDATE, DELETE, SELECT                        ON FUTURE TABLES IN DATABASE raw TO ROLE raw_ingest_svc_role;

-- 5) TRANSFORM_SVC_ROLE: builds staging, intermediate, and marts
-- 5a) Read access on raw
GRANT USAGE                                                 ON DATABASE raw                  TO ROLE transform_svc_role;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE raw   TO ROLE transform_svc_role;
GRANT SELECT                                                ON ALL TABLES IN DATABASE raw    TO ROLE transform_svc_role;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE raw TO ROLE transform_svc_role;
-- 5b) Build access in dwh
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE dwh                  TO ROLE transform_svc_role;
GRANT USAGE, CREATE TABLE                                   ON ALL SCHEMAS IN DATABASE dwh   TO ROLE transform_svc_role;
-- 5c) Build access in reporting
GRANT USAGE, CREATE SCHEMA                                  ON DATABASE reporting            TO ROLE transform_svc_role;
GRANT USAGE, CREATE TABLE                                   ON SCHEMA reporting.marts        TO ROLE transform_svc_role;

-- 6) DEVELOPER_ROLE: read-only on raw, dwh & reporting
-- 6a) Read access on raw
GRANT USAGE                                                 ON DATABASE raw                  TO ROLE developer_role;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE raw   TO ROLE developer_role;
GRANT SELECT                                                ON ALL TABLES IN DATABASE raw    TO ROLE developer_role;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE raw TO ROLE developer_role;
-- 6b) Read access in dwh
GRANT USAGE                                                 ON DATABASE dwh                  TO ROLE developer_role;
GRANT USAGE                                                 ON ALL SCHEMAS IN DATABASE dwh   TO ROLE developer_role;
GRANT SELECT                                                ON ALL TABLES IN DATABASE dwh    TO ROLE developer_role;
GRANT SELECT                                                ON FUTURE TABLES IN DATABASE dwh TO ROLE developer_role;
-- 6c) Read access in reporting
GRANT USAGE                                                 ON DATABASE reporting                      TO ROLE developer_role;
GRANT USAGE                                                 ON SCHEMA reporting.marts                  TO ROLE developer_role;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE developer_role;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE developer_role;

-- 7) ANALYST_ROLE: read-only on final marts only
GRANT USAGE                                                 ON SCHEMA reporting.marts                  TO ROLE analyst_role;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE analyst_role;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE analyst_role;

-- 8) REPORTING_SVC_ROLE: read-only on final marts only
GRANT USAGE                                                 ON SCHEMA reporting.marts                  TO ROLE reporting_svc_role;
GRANT SELECT                                                ON ALL TABLES IN SCHEMA reporting.marts    TO ROLE reporting_svc_role;
GRANT SELECT                                                ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE reporting_svc_role;

-- ============================================================================
-- Monitoring & Operations Privileges
-- ============================================================================

-- Allow roles to see running and historical queries, warehouse usage, etc.
GRANT MONITOR ON ACCOUNT TO ROLE transform_svc_role;
GRANT MONITOR ON ACCOUNT TO ROLE developer_role;
GRANT MONITOR ON ACCOUNT TO ROLE reporting_svc_role;

-- For Tasks or Streams, gives TRANSFORM_SVC_ROLE the right to operate them:
GRANT OPERATE ON ALL TASKS IN SCHEMA dwh.int      TO ROLE transform_svc_role;
GRANT OPERATE ON FUTURE TASKS IN SCHEMA dwh.int   TO ROLE transform_svc_role;

-- Allow transform_svc_role to create and read from any existing and future streams
GRANT CREATE STREAM                     ON SCHEMA dwh.stg                        TO ROLE transform_svc_role;
GRANT USAGE                             ON SCHEMA dwh.stg                        TO ROLE transform_svc_role;
GRANT SELECT                            ON ALL STREAMS IN SCHEMA dwh.stg         TO ROLE transform_svc_role;
GRANT SELECT                            ON FUTURE STREAMS IN SCHEMA dwh.stg      TO ROLE transform_svc_role;


-- ============================================================================
--  Audit Table Setup
--  This table tracks dbt model executions, including row counts and metadata.
--  Used for auditing, monitoring anomalies, and debugging production pipelines.
--
--  Columns:
--    • model_name        – dbt model name (e.g. fct_owid_covid_data)
--    • run_ts            – timestamp when the dbt run started
--    • dbt_invocation_id – unique identifier for the dbt run
--    • row_count         – number of records produced by the model
--    • database_name     – database where the model was built
--    • schema_name       – schema where the model was built
--    • table_name        – full table name of the materialized model
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS dwh.audit;

CREATE OR REPLACE TABLE IF NOT EXISTS dwh.audit.model_run_log (
    model_name TEXT,
    run_ts TIMESTAMP_TZ,
    dbt_invocation_id TEXT,
    row_count INTEGER,
    database_name TEXT,
    schema_name TEXT,
    table_name TEXT
);
