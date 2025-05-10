# dbt COVID Pipeline

A dbt-based ELT pipeline that models and documents COVID-19 metrics from Our World in Data (OWID).  
Built on Snowflake, this project provides a clean, tested, and documented set of staging, intermediate, fact, dimension, and aggregate models, plus automated snapshots and exposures.

---

## 🚀 Project Overview

- **Source**: `raw.owid.owid_covid_data` (CSV from OWID public GitHub)  
- **Staging**: `models/staging/owid/stg_owid_covid_data`  
- **Intermediate**: `models/intermediate/owid/int_owid_covid_data`  
- **Dimensions**:  
  - `dim_owid_continent`  
  - `dim_owid_iso_code` (with `location` & `continent`)  
- **Fact**: `fct_owid_covid`  
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

## 📋 Prerequisites

- **dbt** ≥ 1.4 (tested on 2025.5.7)  
- **Snowflake** account & role with permissions to `CREATE`/`SELECT` in your target schemas  
- **Python** (for any pre-commit linting or custom scripts)  
- (Optional) **SQLFluff** for style checks  

---

## 🛠️ Setup

1. **Clone the repo**  
   ```bash
   git clone git@github.com:yourorg/dbt_covid_pipeline.git
   cd dbt_covid_pipeline
   ```

2. **Install dependencies**  
   ```bash
   pip install dbt-core dbt-snowflake
   # (or run your project’s `requirements.txt` if you have one)
   ```

3. **Configure profiles**  
   Edit `~/.dbt/profiles.yml` to add a `dbt_covid_pipeline` profile that points at your Snowflake account.

4. **Initialize the project**  
   ```bash
   dbt deps
   dbt seed    # if you have any seeds
   ```

---

## ⚡ Usage

- **Compile & Build**  
  ```bash
  dbt clean
  dbt build
  ```
  This will run all models, snapshots, tests, and then package your documentation.

- **Run Tests Only**  
  ```bash
  dbt test
  ```

- **Parse & Compile Only**  
  ```bash
  dbt parse
  dbt compile
  ```

- **Source Freshness**  
  ```bash
  dbt source freshness
  ```

- **Docs Generation & Preview**  
  ```bash
  dbt docs generate
  dbt docs serve
  ```
  Browse to `http://localhost:8080` and look under **Models**, **Snapshots**, **Exposures** (and **Metrics**, if/when enabled).

---

## 🌲 Folder Structure

```
├── analysis/                   ← ad-hoc analyses (not deployed)
├── macros/                     ← reusable macro functions
├── models/
│   ├── staging/owid/           ← raw-to-staging transformations
│   ├── intermediate/owid/      ← cleaning, deduplication
│   ├── marts/owid/             ← dims, facts, aggregates
│   └── metrics/                 ← (optional) semantic metrics YAMLs
├── snapshots/owid/             ← snapshot definitions
├── tests/                      ← custom schema or data tests
├── docs/                       ← supplemental Markdown docs
├── dbt_project.yml             ← project configuration
└── README.md                   ← this file
```

---

## 🔒 Governance & Best Practices

- **Contracts**: all marts models use `on_schema_change='fail'` and `contract={'enforced':true}`  
- **Tags**: consistent use of `tags: ['stg','int','dim','fct','agg','owid']` for grouping  
- **YAML Tests**: `not_null`, `unique`, and `relationships` tests defined in `schema.yml` files  
- **Commenting**: `-- Created` / `-- Last Modified` headers in SQL files, plus clear purpose/notes blocks  
- **CI/CD**: recommended via GitHub Actions or similar to run `dbt build` on PRs and auto-publish docs  

---

## 📈 CI/CD & Deployment

1. **On Pull Request**  
   - `dbt deps && dbt parse && dbt compile && dbt test`  
   - Lint with SQLFluff (optional)  
2. **On Merge to `main`**  
   - `dbt build`  
   - `dbt docs generate` → publish to S3 or GitHub Pages  
3. **Alerts**  
   - Configure Slack/email notifications on test or freshness failures.

---

## 🤝 Contributing

1. Branch off of `main` for each feature/fix.  
2. Submit PR against `main` with changes to models, tests, docs, or readme.  
3. Ensure all checks pass (build, tests, lint).  

---

## 📞 Support

- **Owner**: eramsaier@gmail.com  
- **Team**: analytics_engineering@yourcompany.com  

---

_Last updated: 2025-05-10_
