# dbt_covid_pipeline

A production-style dbt project built on top of the [Our World in Data (OWID) COVID-19 dataset](https://github.com/owid/covid-19-data). This pipeline demonstrates best practices in analytics engineering using dbt, covering source ingestion, transformations, testing, documentation, and modeling.

---

## 📌 Purpose

To showcase end-to-end analytics engineering skills using a real-world dataset, in a structure and style ready for production. Built to be reviewed by hiring managers and technical stakeholders.

---

## 🏗️ Project Structure

```
dbt_covid_pipeline/
├── analyses/             # Exploratory queries and anomaly investigations
├── database_setup/       # DDLs for external stages and tables
├── docs/                 # Markdown docs for BI/data team use
├── macros/               # Reusable logic for testing, naming, utilities
├── models/
│   ├── intermediate/     # Logic-heavy prep before marts
│   ├── marts/            # Business-facing tables (facts, dims)
│   ├── seeds/            # Metadata and lookup tables
│   ├── snapshots/        # Slowly changing dimension tracking
│   ├── sources/          # Raw external table definitions
│   └── staging/          # Lightweight cleansed layers per source
├── seeds/                # CSV files for metadata
├── snapshots/            # Snapshot logic for SCD tracking
└── tests/                # Custom SQL tests, test macros, or placeholders to structure QA logic
```

---

## 📦 Key Features

- **External Table Setup**: Ingests OWID CSV via Snowflake external stage.
- **Staging Layer**: Performs casting, renaming, and field selection.
- **Intermediate Layer**: Consolidates and prepares wide tables.
- **Marts Layer**: Builds fact tables with audit columns and contracts.
- **Testing**:
  - dbt generic tests (e.g. `not_null`, `unique`)
  - Custom macro tests (e.g. `expression_is_true`)
- **Documentation**: Centralized markdown and dbt docs.
- **Metadata**:
  - Surrogate keys
  - Standardized audit columns
- **Project Conventions**:
  - One schema file per mart
  - Naming: `fct_`, `dim_`, `int_`, `stg_`, `src_`
  - Folders split by source domain (e.g. `owid/`, `shared/`)
  - Contracts enabled on marts

---

## 🧪 How to Run

1. Load `owid-covid-data.csv` into your Snowflake external stage.
2. Run `dbt build` from dbt Cloud or CLI.
3. Run `dbt docs generate && dbt docs serve` to explore documentation.

---

## 🔧 Future Work

- Aggregated marts (e.g. by continent/week)
- Tableau/Power BI dashboard example
- Daily orchestration (dbt Cloud or Airflow)
- dbt exposures and freshness tests

---

## 👤 Author

Eric Ramseyer  
GitHub: [EricRamsaier](https://github.com/EricRamsaier)

---

## 📄 License

MIT
