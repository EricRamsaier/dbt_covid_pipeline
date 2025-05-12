-- landing_ingestion.sql
-- Snowflake external stage setup for OWID COVID-19 data ingestion

-- -----------------------------------------------------------------------------------
-- 1. Create a reusable CSV file format
-- -----------------------------------------------------------------------------------
CREATE OR REPLACE FILE FORMAT LANDING_EXT.S3.CSV_GENERIC_FORMAT
  TYPE                            = CSV
  FIELD_DELIMITER                 = ','
  SKIP_HEADER                     = 1
  NULL_IF                         = ('', 'NULL')
  EMPTY_FIELD_AS_NULL             = TRUE
  TRIM_SPACE                      = TRUE
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

COMMENT ON FILE FORMAT LANDING_EXT.S3.CSV_GENERIC_FORMAT IS
  'Generic CSV format: header row, comma-delimited, NULL handling, trimming enabled.';

-- -----------------------------------------------------------------------------------
-- 2. Create a storage integration (manually done once per account)
--    🔒 REDACTED: do NOT share actual values for role ARN or allowed locations
-- -----------------------------------------------------------------------------------
-- Replace <REPLACE_ME> placeholders with your actual values.
-- Follow Snowflake docs: https://docs.snowflake.com/en/user-guide/data-load-s3-config-storage-integration
--
-- CREATE STORAGE INTEGRATION S3_OWID_INTEGRATION
--   TYPE = EXTERNAL_STAGE
--   STORAGE_PROVIDER = S3
--   ENABLED = TRUE
--   STORAGE_AWS_ROLE_ARN = '<REDACTED-ARN>'
--   STORAGE_ALLOWED_LOCATIONS = ('s3://<your-bucket-name>/owid/')
--   STORAGE_AWS_EXTERNAL_ID = ''
--   COMMENT = 'S3 integration for OWID COVID-19 data';

-- After creation:
-- > DESCRIBE STORAGE INTEGRATION S3_OWID_INTEGRATION;
-- Copy the generated `STORAGE_AWS_EXTERNAL_ID`
-- Paste that value into your AWS IAM role trust policy for Snowflake

-- -----------------------------------------------------------------------------------
-- 3. Create an external stage pointing to the S3 bucket/folder
-- -----------------------------------------------------------------------------------
CREATE OR REPLACE STAGE LANDING_EXT.S3.OWID_STAGE
  URL = 's3://<your-bucket-name>/owid/'                     -- change to your S3 path
  STORAGE_INTEGRATION = S3_OWID_INTEGRATION                 -- must match integration name
  FILE_FORMAT = (FORMAT_NAME = 'LANDING_EXT.S3.CSV_GENERIC_FORMAT')
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage pointing at OWID CSVs in S3';

-- Test it (optional):
-- LIST @LANDING_EXT.S3.OWID_STAGE;

-- -----------------------------------------------------------------------------------
-- 4. Grant access to the raw ingestion role (adjust as needed)
-- -----------------------------------------------------------------------------------
GRANT USAGE ON DATABASE LANDING_EXT TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON SCHEMA LANDING_EXT.S3 TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON STAGE LANDING_EXT.S3.OWID_STAGE TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON INTEGRATION S3_OWID_INTEGRATION TO ROLE RAW_INGEST_SVC_ROLE;

-- -----------------------------------------------------------------------------------
-- ✅ You are now ready to ingest data using COPY INTO
-- -----------------------------------------------------------------------------------
-- You can load the file using a staging table with VARCHAR fields
-- and then cast + clean later in your DBT models.
