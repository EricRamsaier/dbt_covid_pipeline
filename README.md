# dbt COVID Pipeline

A dbt-based ELT pipeline that models and documents COVID-19 metrics from Our World in Data (OWID).  
Built on Snowflake, this project provides a clean, tested, and documented set of staging, intermediate, fact, dimension, and aggregate models, plus automated snapshots and exposures.

---

## 🚀 Project Overview

- **Source**: `raw.owid.owid_covid_data` (CSV from OWID public GitHub)  
- **Staging**: `models/staging/owid/stg_owid_covid_data`  
- **Intermediate**: `models/intermediate/owid/int_owid_covid_data`  
- **Dimension**:
  - `dim_owid_covid_location` (with `location` & `continent`)  
- **Fact**: 
  - `fct_owid_covid`  
- **Aggregates**:  
  - `agg_owid_covid_day`  
  - `agg_owid_covid_month`  
  - `agg_owid_covid_year`  
- **Snapshots**:  
  - `snap_dim_owid_iso_code`  
- **Exposures**:  
  - `covid_dashboard`  
  - `covid_yearly_dashboard`  
- **Macros**: audit columns, dev filters, RLS grants, etc.

---

## ⚛️ Data Ingestion Pipeline (Snowflake S3)

This project uses a controlled ingestion pattern from a public OWID CSV file into Snowflake:

- **Landing layer**: External stage defined at `landing_ext.s3.owid_stage`
- **Raw table**: `raw.owid.owid_covid_data` defined with all columns as VARCHAR for flexible parsing
- **Ingestion method**: manual `COPY INTO` from stage, using a fixed file pattern and casted timestamp for `loaded_ts`
- **File format**: generic CSV with header row, null handling, and space trimming

The ingestion logic is defined in `snowflake_landing_ext_setup.sql`, and roles are managed via `snowflake_bootstrap.sql`.

Future automation via GitHub Actions can refresh the OWID CSV and re-trigger the pipeline.

---

## 📋 Prerequisites

- **dbt Cloud** (preferred) or **dbt Core** ≥ 1.4 (tested on 2025.5.7)  
- **Snowflake** account & role with permissions to `CREATE`/`SELECT` in your target schemas  
- (Optional for Core) **Python**, **SQLFluff** for style/linting  

---

## 🛠️ Setup

1. **Clone the repo**  
   ```bash
   git clone git@github.com:yourorg/dbt_covid_pipeline.git
   cd dbt_covid_pipeline
   ```

2. **Install dependencies** *(dbt Core only)*  
   ```bash
   pip install dbt-core dbt-snowflake
   ```

3. **Configure profile** *(dbt Core only)*  
   Edit `~/.dbt/profiles.yml` to define the `dbt_covid_pipeline` profile.

4. **Install packages and initialize**  
   ```bash
   dbt deps
   dbt seed  # if applicable
   ```

---

## ⚡ Usage

- **Compile & Build**  
  ```bash
  dbt clean
  dbt build
  ```

- **Test only**  
  ```bash
  dbt test
  ```

- **Parse & Compile**  
  ```bash
  dbt parse
  dbt compile
  ```

- **Source Freshness**  
  ```bash
  dbt source freshness
  ```

- **Docs Generation**  
  ```bash
  dbt docs generate
  dbt docs serve
  ```
  Visit: http://localhost:8080

---

## 🌲 Folder Structure

```
├── analysis/                   ← ad-hoc analyses (not deployed)
├── macros/                     ← reusable macro functions
├── models/
│   ├── staging/owid/           ← raw-to-staging transformations
│   ├── intermediate/owid/      ← cleaning, deduplication
│   ├── marts/owid/             ← dims, facts, aggregates
│   └── metrics/                ← (optional) semantic metrics YAMLs
├── snapshots/owid/             ← snapshot definitions
├── tests/                      ← custom schema or data tests
├── docs/                       ← supplemental Markdown docs
├── dbt_project.yml             ← project configuration
└── README.md                   ← this file
```

---

## 🔒 Governance & Best Practices

- **Contracts**: all marts models use `on_schema_change='fail'` and `contract: {enforced: true}`  
- **Tags**: consistent use of `tags: ['stg','int','dim','fct','agg','owid']`  
- **YAML Tests**: `not_null`, `unique`, and `relationships` tests defined  
- **Header Commenting**: `-- Created` / `-- Last Modified` per model  
- **CI/CD**: recommended using dbt Cloud or GitHub Actions  

---

## 📊 CI/CD & Deployment

1. **On Pull Request**  
   - `dbt deps && dbt parse && dbt compile && dbt test`
   - SQLFluff lint (optional)

2. **On Merge to `main`**  
   - `dbt build`
   - `dbt docs generate` → deploy docs site

3. **Alerts**  
   - Slack/email hooks for test/freshness failures (via dbt Cloud or GitHub Actions)

---

## 🤝 Contributing

1. Create a new branch from `main`
2. Open a PR after changes
3. Verify tests, docs, and builds pass

---

## 📞 Support

- **Owner**: eramsaier@gmail.com  
- **Team**: analytics_engineering@yourcompany.com  

---

_Last updated: 2025-05-12_
