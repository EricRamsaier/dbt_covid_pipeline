{% macro grant_privileges() %}

-- schema_setup.sql  (run once or on infra pipeline)
CREATE SCHEMA IF NOT EXISTS dwh.stg;
CREATE SCHEMA IF NOT EXISTS dwh.int;
CREATE SCHEMA IF NOT EXISTS analytics.marts;

-- ETL_ROLE: full control over every schema in dwh, plus analytics.marts
GRANT USAGE, CREATE SCHEMA    ON DATABASE dwh                     TO ROLE ETL_ROLE;
GRANT ALL PRIVILEGES          ON ALL SCHEMAS IN DATABASE dwh       TO ROLE ETL_ROLE;
GRANT ALL PRIVILEGES          ON FUTURE TABLES IN DATABASE dwh     TO ROLE ETL_ROLE;
GRANT USAGE, CREATE SCHEMA    ON DATABASE analytics               TO ROLE ETL_ROLE;
GRANT ALL PRIVILEGES          ON SCHEMA analytics.marts           TO ROLE ETL_ROLE;
GRANT ALL PRIVILEGES          ON FUTURE TABLES IN SCHEMA analytics.marts TO ROLE ETL_ROLE;

-- DEV_ROLE: read-only access to everything in dwh
GRANT USAGE                   ON DATABASE dwh                     TO ROLE DEV_ROLE;
GRANT USAGE                   ON ALL SCHEMAS IN DATABASE dwh       TO ROLE DEV_ROLE;
GRANT SELECT                  ON ALL TABLES IN DATABASE dwh       TO ROLE DEV_ROLE;
GRANT SELECT                  ON FUTURE TABLES IN DATABASE dwh     TO ROLE DEV_ROLE;

-- DEV_ROLE: read-only on analytics.marts
GRANT USAGE                   ON DATABASE analytics               TO ROLE DEV_ROLE;
GRANT USAGE                   ON SCHEMA analytics.marts            TO ROLE DEV_ROLE;
GRANT SELECT                  ON ALL TABLES IN SCHEMA analytics.marts   TO ROLE DEV_ROLE;
GRANT SELECT                  ON FUTURE TABLES IN SCHEMA analytics.marts TO ROLE DEV_ROLE;

-- ANALYST_ROLE: USAGE + SELECT on analytics.marts only
GRANT USAGE                   ON SCHEMA analytics.marts            TO ROLE ANALYST_ROLE;
GRANT SELECT                  ON ALL TABLES IN SCHEMA analytics.marts   TO ROLE ANALYST_ROLE;
GRANT SELECT                  ON FUTURE TABLES IN SCHEMA analytics.marts TO ROLE ANALYST_ROLE;

{% endmacro %}
