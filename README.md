*This project documents a full pipeline—from ingestion to transformation—using dbt Cloud and Snowflake. It captures the entire arc of building a production-grade dbt project, including missteps, refactors, and iteration. This isn’t a sanitized tutorial; it reflects the real process of learning, troubleshooting, and iteratively applying best practices over time.

While the core modeling and transformation work aligned closely with analytics engineering best practices, the ingestion layer (AWS S3, Snowflake external tables, IAM permissions, versioning, and GitHub Actions) presented notable complexity. These are traditionally data engineering concerns. Managing and troubleshooting these layers — especially around CI workflows, docs hosting, and credential handling — added real-world friction that isn't visible in the models alone.

This project reflects both the strengths and challenges of solo-building a modern data stack end to end — and highlights where boundaries between AE and DE often blur in practice.
*

# End-to-End Automated Data Pipeline

**Motivation:** Demonstrate a fully automated, end-to-end data pipeline running on a weekly cadence. This project ingests the Our World in Data (OWID) COVID dataset, stages it in S3, reads it in Snowflake via an external table, and transforms it in dbt Cloud.

---

## Source Data: OWID COVID-19

* **URL:** [https://covid.ourworldindata.org/data/owid-covid-data.csv](https://covid.ourworldindata.org/data/owid-covid-data.csv)
* **Contents:** Global daily COVID-19 metrics (cases, deaths, tests, vaccinations) by country.
* **Refresh cadence:** Weekly, automated via GitHub Action to S3.

---

## Project Overview

- **Source**: 
  -  raw.owid.owid_covid_data
- **Staging**: 
  -  stg_owid_covid_data
- **Intermediate**: 
  -  int_owid_covid_data  
- **Dimension**:
  - dim_owid_covid_location  
- **Fact**: 
  - fct_owid_covid  
- **Aggregates**:  
  - agg_owid_covid_day  
  - agg_owid_covid_month  
  - agg_owid_covid_year  
- **Snapshots**:  
  - snap_dim_owid_iso_code  
- **Exposures**:  
  - covid_dashboard  
  - covid_yearly_dashboard  
- **Macros**: audit columns, dev filters, RLS grants, etc.

---

## Architecture Overview

```text
dbt_covid_pipeline/
├── .github/
│   └── workflows/                       # GitHub Action workflows
├── analyses/                            # Ad-hoc analyses and notebooks
├── data/                                # Local data folder (seeds, samples)
├── docs/                                # Documentation artifacts and reference files
├── external_application_setup/          # External application setup scripts/configs
├── macros/                              # dbt macros definitions
├── models/                              # dbt models (sources, staging, marts)
├── snapshots/                           # dbt snapshots definitions
├── tests/                               # Custom tests and test data
├── dbt_project.yml                      # Core dbt configuration
└── README.md                            # Project overview (this file)
```

*Note:* the `docs/` folder contains repeatable reference artifacts (e.g. `macros_schema.yml`) used for consistent documentation.

---

## Setup Instructions

This section outlines the basic steps to get the project running locally or in a new environment.

1. **Clone the repository**

   ```bash
   git clone <repo-url> && cd dbt_covid_pipeline
   ```
2. **Configure GitHub Actions secrets**

   * `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for `dbt-ingest-user` in your repository settings.
3. **Install prerequisites**

   * [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   * [dbt Core](https://docs.getdbt.com/docs/installation)
   * [SnowSQL](https://docs.snowflake.com/en/user-guide/snowsql.html) (optional for manual testing)
4. **Set up local profiles.yml** (if running locally)

   ```yaml
   your_profile:
     target: ci
     outputs:
       ci:
         type: snowflake
         account: <account_identifier>
         user: <user>
         role: <CI_role>
         database: <database>
         warehouse: <warehouse>
         schema: <schema>  # e.g. DBT_CLOUD_PR_<PR>_<RUN>
   ```
5. **Install Python dependencies** (if any custom macros require packages)

   ```bash
   pip install -r requirements.txt  # optional
   ```
6. **Verify CI workflow manually**

   * In GitHub, under **Actions**, run the **Refresh OWID CSV** workflow.

---

## AWS Setup

### S3 Bucket

* **Name:** `<bucket-name>`
* **Versioning:** Enabled to retain past weekly snapshots.
* **Prefixes:**

  * Live: `owid/owid-covid-data.csv`
  * Backups: `backups/owid/` (archived original files)

### IAM Identities & Policies

**IAM User: `dbt-ingest-user`**

* **Use:** GitHub Action runner
* **Policy (`dbt-ingest-s3-policy`):** grants `ListBucket`, `GetObject`, `PutObject`, `DeleteObject` on S3 bucket/prefix.

**IAM Role: `SnowflakeCovidDataReader`**

* **Use:** Snowflake Storage Integration
* **Trust:** Allows Snowflake principal (account ID + ExternalId) to assume.
* **Policy (`SnowflakeCovidDataReadPolicy`):** grants `ListBucket`, `GetObject` on bucket/prefix.

*All policies are customer-managed JSON for auditability.*

---

## Snowflake Setup

**File format & storage integration (in `landing_ext`):**

```sql
CREATE OR REPLACE FILE FORMAT landing_ext.s3.csv_generic_format ...;
CREATE OR REPLACE STORAGE INTEGRATION landing_ext.s3_owid_integration ...;
```

**Stage & external table:**

```sql
CREATE OR REPLACE STAGE landing_ext.s3.owid_stage ...;
CREATE OR REPLACE EXTERNAL TABLE landing_ext.reporting.owid_covid ...;
```

---

## Database Environments & Roles

**Databases:** `raw`, `dwh`, `reporting`, `landing_ext`
**Roles:** `raw_ingest_svc_role`, `transform_svc_role`, `developer_role`, `analyst_role`, `reporting_svc_role`

```sql
CREATE DATABASE IF NOT EXISTS raw; ...
CREATE ROLE IF NOT EXISTS raw_ingest_svc_role; ...
```

---

## dbt Cloud CI/CD Setup

* **Environments:** `CI` for PR builds, `Production` for merges to `main`.
* **PR Builds:** each PR runs in an isolated schema and is auto-dropped on close.
* **Prod Builds:** deploy to named schemas via `dbt_project.yml` overrides.

**Dynamic naming macros:** `generate_schema_name` & `generate_database_name` drive environment-specific schema/database resolution.

---

## Weekly S3 Update Workflow

**GitHub Action:** `.github/workflows/refresh-covid-csv-to-s3.yml`

```yaml
name: Refresh OWID CSV
on: schedule: '0 1 * * 0', workflow_dispatch: {}
jobs:
  refresh-csv:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: |
          mkdir -p data
          curl -sSL -o data/owid-covid-data.csv https://.../owid-covid-data.csv
      - run: |
          aws s3 cp data/owid-covid-data.csv s3://<bucket-name>/owid/owid-covid-data.csv --acl bucket-owner-full-control
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
```

*Uses `cp` for focused overwrite; versioning retains history.*

---

## dbt Models & Tests

**Sources & tests (in `schema.yml`):** not\_null, unique, freshness.
**Snapshots:** capture point-in-time state.
**Models:** `fct_covid_metrics`, `dim_date`, `dim_country`.

---

## CI/CD Pipeline Details

### GitHub Actions

* **Workflow:** `.github/workflows/refresh-covid-csv-to-s3.yml` runs every Sunday at 01:00 UTC (and can be triggered manually).
* **Secrets:** Uses `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY` for `dbt-ingest-user` to upload the OWID CSV via `aws s3 cp`.
* **Versioning:** S3 bucket versioning retains past payloads; workflow uses a single-file `cp` for targeted overwrites.

### dbt Cloud

* **CI Environment:** Triggered on every pull request, runs under an isolated schema (`DBT_CLOUD_PR_*`), and automatically drops it when the PR closes.
* **Prod Environment:** Triggered on merges to `main`, writes to production schemas as defined in `dbt_project.yml`.
* **Jobs:** Separate jobs configured for PR builds and production runs; both use the same repository and macros but different targets and schema/database naming conventions.
* **Notifications & Logging:** Build results and logs are visible in the dbt Cloud UI; failures can be configured to alert via Slack or email.
