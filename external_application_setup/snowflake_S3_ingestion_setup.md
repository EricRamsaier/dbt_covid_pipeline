# Snowflake S3 Ingestion Setup (Private Version)

> **Note**: Replace all `<REDACTED>` placeholders before running.

---

## 1. Create a generic CSV file format

```sql
CREATE OR REPLACE FILE FORMAT LANDING_EXT.S3.CSV_GENERIC_FORMAT
  TYPE                            = CSV
  FIELD_DELIMITER                 = ','
  SKIP_HEADER                     = 1
  NULL_IF                         = ('', 'NULL')
  EMPTY_FIELD_AS_NULL             = TRUE
  TRIM_SPACE                      = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH  = FALSE;

COMMENT ON FILE FORMAT LANDING_EXT.S3.CSV_GENERIC_FORMAT IS
  'Reusable generic CSV format: header-row, comma-delimited, blanks as NULL';
```

---

## 2. Create the S3 storage integration

```sql
CREATE STORAGE INTEGRATION S3_OWID_INTEGRATION
  TYPE                   = EXTERNAL_STAGE
  STORAGE_PROVIDER       = S3
  ENABLED                = TRUE
  STORAGE_AWS_ROLE_ARN   = '<REDACTED>'        -- AWS IAM role ARN
  STORAGE_ALLOWED_LOCATIONS = ('<REDACTED>')   -- S3 bucket path
  STORAGE_AWS_EXTERNAL_ID = '<REDACTED>'       -- from DESCRIBE STORAGE INTEGRATION
  COMMENT = 'S3 stage integration for OWID CSVs';

-- Retrieve AWS external ID:
DESCRIBE STORAGE INTEGRATION S3_OWID_INTEGRATION;
```

---

## 3. Create the S3 stage

```sql
CREATE OR REPLACE STAGE LANDING_EXT.S3.OWID_STAGE
  URL                  = 's3://zzz/owid/'
  STORAGE_INTEGRATION  = S3_OWID_INTEGRATION
  FILE_FORMAT          = (FORMAT_NAME = 'LANDING_EXT.S3.CSV_GENERIC_FORMAT')
  DIRECTORY            = (ENABLE = TRUE)
  COMMENT              = 'Stage pointing at OWID CSVs in S3';
```

---

## 4. Grant access to the ingestion role

```sql
GRANT USAGE ON DATABASE LANDING_EXT                TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON SCHEMA LANDING_EXT.S3               TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON INTEGRATION S3_OWID_INTEGRATION     TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON STAGE LANDING_EXT.S3.OWID_STAGE     TO ROLE RAW_INGEST_SVC_ROLE;
```

---

## 5. Create the target table and load via Snowpipe

```sql
CREATE OR REPLACE TABLE RAW.OWID.OWID_COVID_DATA (
  ISO_CODE                                 VARCHAR,
  CONTINENT                                VARCHAR,
  LOCATION                                 VARCHAR,
  ...  -- [columns 4–67 omitted for brevity]
  EXCESS_MORTALITY_CUMULATIVE_PER_MILLION  VARCHAR,
  LOADED_TS                                TIMESTAMP_TZ
);

COPY INTO RAW.OWID.OWID_COVID_DATA (
    ISO_CODE, CONTINENT, LOCATION, /* ... */, LOADED_TS
)
FROM (
  SELECT
    $1, $2, $3, /* ... */, CAST(CURRENT_TIMESTAMP() AS TIMESTAMP_TZ)
  FROM @LANDING_EXT.S3.OWID_STAGE
  ( FILE_FORMAT => 'LANDING_EXT.S3.CSV_GENERIC_FORMAT' )
)
FILE_FORMAT = (FORMAT_NAME = 'LANDING_EXT.S3.CSV_GENERIC_FORMAT')
PATTERN     = '^owid-covid-data\.csv$'
ON_ERROR    = 'CONTINUE';
```
