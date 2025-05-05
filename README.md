# dbt COVID Pipeline Template

This repository is a production-grade starter for a Snowflake + dbt ELT pipeline, demonstrating industry best practices in naming, folder structure, permissions, and testing.

---

## Table of Contents

1. [Project Structure](#project-structure)  
2. [Snowflake Infra Setup](#snowflake-infra-setup)  
   - Databases & Schemas  
   - Roles & Least-Privilege Grants  
3. [dbt Project Configuration](#dbt-project-configuration)  
4. [Models & Folder Layout](#models--folder-layout)  
5. [Source Definitions (`models/src/sources.yml`)](#source-definitions-modelssrcsourcesyml)  
6. [Staging Models & Tests](#staging-models--tests)  
7. [Intermediate Models & Targeted Tests](#intermediate-models--targeted-tests)  
8. [Marts Models & Final Testing](#marts-models--final-testing)  
9. [Key Conventions & Tips](#key-conventions--tips)  

---

## Project Structure

```
├── infra/
│   └── snowflake_setup.sql       ← one-time DB/role/grant script
├── models/
│   ├── src/
│   │   └── sources.yml           ← `source:` declarations & freshness
│   ├── staging/
│   │   ├── *.sql                 ← `stg__` views
│   │   └── schema.yml.template   ← example staging docs/tests
│   ├── intermediate/
│   │   ├── *.sql                 ← `int__` models
│   │   └── schema.yml.template   ← example targeted tests on joins
│   └── marts/
│       ├── *.sql                 ← final tables (`fct_`/`dim_`)
│       └── schema.yml            ← docs & tests for marts
├── seeds/
│   └── *.csv.template            ← seed CSV templates
├── macros/
│   └── *.sql.template            ← custom macro examples
├── tests/
│   └── *.sql.template            ← standalone SQL tests
├── snapshots/
│   └── *.sql                     ← snapshot definitions
├── analyses/
│   └── *.sql                     ← ad-hoc analyses
├── docs/
│   └── *.md                      ← documentation & how-to guides
├── dbt_project.yml               ← core dbt config (see below)
└── profiles.yml                  ← local connection profile
```

---

## Snowflake Infra Setup

**File:** `infra/snowflake_setup.sql`  
Run **once** (as ACCOUNTADMIN) to provision databases, schemas, roles, and grants under least-privilege principles.

```sql
-- 1) Create databases
CREATE DATABASE IF NOT EXISTS raw;
CREATE DATABASE IF NOT EXISTS dwh;
CREATE DATABASE IF NOT EXISTS reporting;

-- 2) Create roles
CREATE ROLE IF NOT EXISTS raw_ingest_svc;
CREATE ROLE IF NOT EXISTS transform_svc;
CREATE ROLE IF NOT EXISTS developer;
CREATE ROLE IF NOT EXISTS analyst;

-- 3) Create schemas
CREATE SCHEMA IF NOT EXISTS raw.landing;
CREATE SCHEMA IF NOT EXISTS dwh.stg;
CREATE SCHEMA IF NOT EXISTS dwh.int;
CREATE SCHEMA IF NOT EXISTS reporting.marts;

-- 4) Grants for raw_ingest_svc (landing zone)
GRANT USAGE, CREATE SCHEMA, CREATE STAGE, CREATE FILE FORMAT ON DATABASE raw              TO ROLE raw_ingest_svc;
GRANT USAGE, CREATE TABLE                                  ON ALL SCHEMAS IN DATABASE raw TO ROLE raw_ingest_svc;
GRANT INSERT, UPDATE, DELETE, SELECT                       ON ALL TABLES IN DATABASE raw  TO ROLE raw_ingest_svc;
GRANT INSERT, UPDATE, DELETE, SELECT                       ON FUTURE TABLES IN DATABASE raw TO ROLE raw_ingest_svc;

-- 5) Grants for transform_svc (reads raw; builds DWH & marts)

-- 5a) Read-only on raw
GRANT USAGE ON DATABASE raw                  TO ROLE transform_svc;
GRANT USAGE ON ALL SCHEMAS IN DATABASE raw   TO ROLE transform_svc;
GRANT SELECT ON ALL TABLES IN DATABASE raw   TO ROLE transform_svc;
GRANT SELECT ON FUTURE TABLES IN DATABASE raw TO ROLE transform_svc;

-- 5b) Build in dwh
GRANT USAGE, CREATE SCHEMA                    ON DATABASE dwh         TO ROLE transform_svc;
GRANT USAGE, CREATE TABLE                     ON ALL SCHEMAS IN DATABASE dwh TO ROLE transform_svc;

-- 5c) Build in reporting.marts
GRANT USAGE, CREATE SCHEMA                    ON DATABASE reporting   TO ROLE transform_svc;
GRANT USAGE, CREATE TABLE                     ON SCHEMA reporting.marts TO ROLE transform_svc;

-- 6) Grants for developer (human) — read-only across all layers
GRANT USAGE                                     ON DATABASE raw        TO ROLE developer;
GRANT USAGE                                     ON ALL SCHEMAS IN DATABASE raw TO ROLE developer;
GRANT SELECT                                    ON ALL TABLES IN DATABASE raw TO ROLE developer;
GRANT SELECT                                    ON FUTURE TABLES IN DATABASE raw TO ROLE developer;
GRANT USAGE                                     ON DATABASE dwh        TO ROLE developer;
GRANT USAGE                                     ON ALL SCHEMAS IN DATABASE dwh TO ROLE developer;
GRANT SELECT                                    ON ALL TABLES IN DATABASE dwh TO ROLE developer;
GRANT SELECT                                    ON FUTURE TABLES IN DATABASE dwh TO ROLE developer;
GRANT USAGE                                     ON DATABASE reporting  TO ROLE developer;
GRANT USAGE                                     ON SCHEMA reporting.marts TO ROLE developer;
GRANT SELECT                                    ON ALL TABLES IN SCHEMA reporting.marts TO ROLE developer;
GRANT SELECT                                    ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE developer;

-- 7) Grants for analyst — read-only on final marts only
GRANT USAGE                                     ON SCHEMA reporting.marts TO ROLE analyst;
GRANT SELECT                                    ON ALL TABLES IN SCHEMA reporting.marts TO ROLE analyst;
GRANT SELECT                                    ON FUTURE TABLES IN SCHEMA reporting.marts TO ROLE analyst;
```