# dbt_core_pipeline

**Last updated:** April 26, 2025

This project is a dbt (Data Build Tool) pipeline designed to model and transform data from a faker-generated e-commerce source, focusing on clean naming conventions, clear structure, and a modular pipeline that reflects realistic data warehousing patterns. It incorporates automated testing and CI workflows.

## Project Goals

This project demonstrates production-level dbt practices:
- Clear layering and separation of logic
- Source-to-mart lineage
- Timestamp consistency (`TIMESTAMP_LTZ`)
- Clean schema & testing standards (unit tests, macro tests)
- Readable, modular SQL with leading commas
- Clustered fact models for long-term scale
- Automated documentation and pipeline checks via CI

---

## Active Data Stream

This project uses a single **faker** data stream, which generates realistic e-commerce order data for development and demonstration purposes.

---

## Directory Structure

```text
<project root>/
├── .github/
│   └── workflows/
├── analyses/
├── ci_profiles/
├── macros/
│   └── tests/
├── models/
│   ├── staging/
│   │   └── faker/
│   │       └── orders/
│   ├── intermediate/
│   │   └── faker/
│   │       └── orders/
│   └── marts/
│       ├── shared/
│       └── faker/
│           └── orders/
├── seeds/
│   └── faker/
│       └── orders/
├── snapshots/
└── tests/
```

---

## Naming Conventions

- **Layer prefixes:**
  - `stg_`: staging (light cleansing & typing)
  - `int_`: intermediate (derived fields)
  - `dim_` / `fct_`: marts (business entities & facts)
- **Separators:** Single underscores in file and model names.
- **Field suffixes:**
  - `_dt` for DATE
  - `_ts` for TIMESTAMP_LTZ
  - `_id` for identifiers
  - `_cnt` for count metrics

---

## Timestamp Standards

- All timestamp fields are cast to `TIMESTAMP_LTZ` at the `stg_` layer.
- Ensures UTC storage, session-local display, DST safety, and consistent analytics.

---

## Clustering Strategy

- Applied on high-cardinality keys in `fct_` models for partition pruning.
- Typical: `CLUSTER BY (created_dt, customer_id)`.
- Derived fields (`created_dt`, `updated_dt`) come from the `int_` layer.

---

## Seeds

- Stored in `seeds/`, organized by source/topic (`faker/orders`).
- File names determine seed identifiers (e.g., `faker_orders_currency` → `ref('faker_orders_currency')`).
- Column types, tags, and enabled states configured via per-folder `schema.yml`.

---

## Sources & Models Documentation

- **Seeds:** `schema.yml` beside each CSV in `seeds/…`.
- **Staging & Marts:** One `schema.yml` per folder under `models/…`.
- Defines `sources:`, `models:`, descriptions, tests, and tags.

---

## Testing Strategy

- **dbt tests:** Defined in `schema.yml` for uniqueness, null checks, and relationships.
- **Macro tests:** Located under `macros/tests/` to validate custom logic.

---

## CI & Deployment

1. **GitHub Actions:** Located in `.github/workflows/` to lint, build, test, and deploy docs.
2. **CI Profiles:** Configured in `ci_profiles/` to run dbt in isolated environments.

---

## Build & Docs

1. **Install dbt with Snowflake adapter**
   ```bash
   pipx install dbt-snowflake
   ```
2. **Configure your profile** in `~/.dbt/profiles.yml` or use `ci_profiles/` for CI.
3. **Build & Test**
   ```bash
   dbt build
   dbt test
   ```
4. **Generate docs & Serve**
   ```bash
   dbt docs generate && dbt docs serve
   ```
5. **Deploy docs** via GitHub Pages (automated by CI or manual commit of `docs/`).

---

## VS Code Setup (Power User)

Configure the `Power User for dbt` extension by pointing to your dbt Python interpreter. Reload the window after any environment changes.

---

## Git & Branching

- Create feature branches from `main`.
- Merge via pull requests.
- `docs/` folder committed for GitHub Pages deployment.
- GitHub Actions can automate `dbt docs generate` on push to `main`.

---
