-- NOTE: This template contains placeholders and is intended for safe public sharing.
-- Be sure to replace all <REDACTED> fields before use.
-- ---------------------------------------------------------------------------------------------------
-- Snowflake S3 Ingestion Setup (Private Version with Full Configuration)
-- ---------------------------------------------------------------------------------------------------

-- 1. Create a generic CSV file format
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

-- 2. Create the S3 storage integration (do not recreate if already done)
CREATE STORAGE INTEGRATION S3_OWID_INTEGRATION
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = '<REDACTED>'        -- [REPLACE] with your AWS IAM role ARN (must allow Snowflake access)
  STORAGE_ALLOWED_LOCATIONS = ('<REDACTED>') -- [REPLACE] with your bucket path (must match integration allowed location)
  STORAGE_AWS_EXTERNAL_ID = '<REDACTED>'     -- [REPLACE] with Snowflake-generated external ID (from DESCRIBE STORAGE INTEGRATION)
  COMMENT = 'S3 stage integration for OWID CSVs'

  
-- 3. Get Snowflake-generated external ID
DESCRIBE STORAGE INTEGRATION S3_OWID_INTEGRATION; --get the external id and feed back in above

-- 4. Create the S3 stage
CREATE OR REPLACE STAGE LANDING_EXT.S3.OWID_STAGE
  URL = 's3://zzz/owid/'
  STORAGE_INTEGRATION = S3_OWID_INTEGRATION
  FILE_FORMAT = (FORMAT_NAME = 'LANDING_EXT.S3.CSV_GENERIC_FORMAT')
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage pointing at OWID CSVs in S3';

-- 5. Grant access to the ingestion role
GRANT USAGE ON DATABASE LANDING_EXT TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON SCHEMA LANDING_EXT.S3 TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON INTEGRATION S3_OWID_INTEGRATION TO ROLE RAW_INGEST_SVC_ROLE;
GRANT USAGE ON STAGE LANDING_EXT.S3.OWID_STAGE TO ROLE RAW_INGEST_SVC_ROLE;

-- 6) Create a Snowpipe-backed table
CREATE OR REPLACE TABLE RAW.OWID.OWID_COVID_DATA (
    ISO_CODE                                 VARCHAR,         -- 1
    CONTINENT                                VARCHAR,         -- 2
    LOCATION                                 VARCHAR,         -- 3
    DATE                                     VARCHAR,         -- 4
    TOTAL_CASES                              VARCHAR,         -- 5
    NEW_CASES                                VARCHAR,         -- 6
    NEW_CASES_SMOOTHED                       VARCHAR,         -- 7
    TOTAL_DEATHS                             VARCHAR,         -- 8
    NEW_DEATHS                               VARCHAR,         -- 9
    NEW_DEATHS_SMOOTHED                      VARCHAR,         -- 10
    TOTAL_CASES_PER_MILLION                  VARCHAR,         -- 11
    NEW_CASES_PER_MILLION                    VARCHAR,         -- 12
    NEW_CASES_SMOOTHED_PER_MILLION           VARCHAR,         -- 13
    TOTAL_DEATHS_PER_MILLION                 VARCHAR,         -- 14
    NEW_DEATHS_PER_MILLION                   VARCHAR,         -- 15
    NEW_DEATHS_SMOOTHED_PER_MILLION          VARCHAR,         -- 16
    REPRODUCTION_RATE                        VARCHAR,         -- 17
    ICU_PATIENTS                             VARCHAR,         -- 18
    ICU_PATIENTS_PER_MILLION                 VARCHAR,         -- 19
    HOSP_PATIENTS                            VARCHAR,         -- 20
    HOSP_PATIENTS_PER_MILLION                VARCHAR,         -- 21
    WEEKLY_ICU_ADMISSIONS                    VARCHAR,         -- 22
    WEEKLY_ICU_ADMISSIONS_PER_MILLION        VARCHAR,         -- 23
    WEEKLY_HOSP_ADMISSIONS                   VARCHAR,         -- 24
    WEEKLY_HOSP_ADMISSIONS_PER_MILLION       VARCHAR,         -- 25
    TOTAL_TESTS                              VARCHAR,         -- 26
    NEW_TESTS                                VARCHAR,         -- 27
    TOTAL_TESTS_PER_THOUSAND                 VARCHAR,         -- 28
    NEW_TESTS_PER_THOUSAND                   VARCHAR,         -- 29
    NEW_TESTS_SMOOTHED                       VARCHAR,         -- 30
    NEW_TESTS_SMOOTHED_PER_THOUSAND          VARCHAR,         -- 31
    POSITIVE_RATE                            VARCHAR,         -- 32
    TESTS_PER_CASE                           VARCHAR,         -- 33
    TESTS_UNITS                              VARCHAR,         -- 34
    TOTAL_VACCINATIONS                       VARCHAR,         -- 35
    PEOPLE_VACCINATED                        VARCHAR,         -- 36
    PEOPLE_FULLY_VACCINATED                  VARCHAR,         -- 37
    TOTAL_BOOSTERS                           VARCHAR,         -- 38
    NEW_VACCINATIONS                         VARCHAR,         -- 39
    NEW_VACCINATIONS_SMOOTHED                VARCHAR,         -- 40
    TOTAL_VACCINATIONS_PER_HUNDRED           VARCHAR,         -- 41
    PEOPLE_VACCINATED_PER_HUNDRED            VARCHAR,         -- 42
    PEOPLE_FULLY_VACCINATED_PER_HUNDRED      VARCHAR,         -- 43
    TOTAL_BOOSTERS_PER_HUNDRED               VARCHAR,         -- 44
    NEW_VACCINATIONS_SMOOTHED_PER_MILLION    VARCHAR,         -- 45
    NEW_PEOPLE_VACCINATED_SMOOTHED           VARCHAR,         -- 46
    NEW_PEOPLE_VACCINATED_SMOOTHED_PER_HUNDRED VARCHAR,       -- 47
    STRINGENCY_INDEX                         VARCHAR,         -- 48
    POPULATION_DENSITY                       VARCHAR,         -- 49
    MEDIAN_AGE                               VARCHAR,         -- 50
    AGED_65_OLDER                            VARCHAR,         -- 51
    AGED_70_OLDER                            VARCHAR,         -- 52
    GDP_PER_CAPITA                           VARCHAR,         -- 53
    EXTREME_POVERTY                          VARCHAR,         -- 54
    CARDIOVASC_DEATH_RATE                    VARCHAR,         -- 55
    DIABETES_PREVALENCE                      VARCHAR,         -- 56
    FEMALE_SMOKERS                           VARCHAR,         -- 57
    MALE_SMOKERS                             VARCHAR,         -- 58
    HANDWASHING_FACILITIES                   VARCHAR,         -- 59
    HOSPITAL_BEDS_PER_THOUSAND               VARCHAR,         -- 60
    LIFE_EXPECTANCY                          VARCHAR,         -- 61
    HUMAN_DEVELOPMENT_INDEX                  VARCHAR,         -- 62
    POPULATION                               VARCHAR,         -- 63
    EXCESS_MORTALITY_CUMULATIVE_ABSOLUTE     VARCHAR,         -- 64
    EXCESS_MORTALITY_CUMULATIVE              VARCHAR,         -- 65
    EXCESS_MORTALITY                         VARCHAR,         -- 66
    EXCESS_MORTALITY_CUMULATIVE_PER_MILLION  VARCHAR,         -- 67
    LOADED_TS                                TIMESTAMP_TZ     -- 68
);

--truncate table RAW.OWID.OWID_COVID_DATA
-- 7) Load from your S3 stage into that table, mapping each file column and adding loaded_ts
COPY INTO RAW.OWID.OWID_COVID_DATA (
    ISO_CODE                                 -- 1
  , CONTINENT                                -- 2
  , LOCATION                                 -- 3
  , DATE                                     -- 4
  , TOTAL_CASES                              -- 5
  , NEW_CASES                                -- 6
  , NEW_CASES_SMOOTHED                       -- 7
  , TOTAL_DEATHS                             -- 8
  , NEW_DEATHS                               -- 9
  , NEW_DEATHS_SMOOTHED                      -- 10
  , TOTAL_CASES_PER_MILLION                  -- 11
  , NEW_CASES_PER_MILLION                    -- 12
  , NEW_CASES_SMOOTHED_PER_MILLION           -- 13
  , TOTAL_DEATHS_PER_MILLION                 -- 14
  , NEW_DEATHS_PER_MILLION                   -- 15
  , NEW_DEATHS_SMOOTHED_PER_MILLION          -- 16
  , REPRODUCTION_RATE                        -- 17
  , ICU_PATIENTS                             -- 18
  , ICU_PATIENTS_PER_MILLION                 -- 19
  , HOSP_PATIENTS                            -- 20
  , HOSP_PATIENTS_PER_MILLION                -- 21
  , WEEKLY_ICU_ADMISSIONS                    -- 22
  , WEEKLY_ICU_ADMISSIONS_PER_MILLION        -- 23
  , WEEKLY_HOSP_ADMISSIONS                   -- 24
  , WEEKLY_HOSP_ADMISSIONS_PER_MILLION       -- 25
  , TOTAL_TESTS                              -- 26
  , NEW_TESTS                                -- 27
  , TOTAL_TESTS_PER_THOUSAND                 -- 28
  , NEW_TESTS_PER_THOUSAND                   -- 29
  , NEW_TESTS_SMOOTHED                       -- 30
  , NEW_TESTS_SMOOTHED_PER_THOUSAND          -- 31
  , POSITIVE_RATE                            -- 32
  , TESTS_PER_CASE                           -- 33
  , TESTS_UNITS                              -- 34
  , TOTAL_VACCINATIONS                       -- 35
  , PEOPLE_VACCINATED                        -- 36
  , PEOPLE_FULLY_VACCINATED                  -- 37
  , TOTAL_BOOSTERS                           -- 38
  , NEW_VACCINATIONS                         -- 39
  , NEW_VACCINATIONS_SMOOTHED                -- 40
  , TOTAL_VACCINATIONS_PER_HUNDRED           -- 41
  , PEOPLE_VACCINATED_PER_HUNDRED            -- 42
  , PEOPLE_FULLY_VACCINATED_PER_HUNDRED      -- 43
  , TOTAL_BOOSTERS_PER_HUNDRED               -- 44
  , NEW_VACCINATIONS_SMOOTHED_PER_MILLION    -- 45
  , NEW_PEOPLE_VACCINATED_SMOOTHED           -- 46
  , NEW_PEOPLE_VACCINATED_SMOOTHED_PER_HUNDRED -- 47
  , STRINGENCY_INDEX                         -- 48
  , POPULATION_DENSITY                       -- 49
  , MEDIAN_AGE                               -- 50
  , AGED_65_OLDER                            -- 51
  , AGED_70_OLDER                            -- 52
  , GDP_PER_CAPITA                           -- 53
  , EXTREME_POVERTY                          -- 54
  , CARDIOVASC_DEATH_RATE                    -- 55
  , DIABETES_PREVALENCE                      -- 56
  , FEMALE_SMOKERS                           -- 57
  , MALE_SMOKERS                             -- 58
  , HANDWASHING_FACILITIES                   -- 59
  , HOSPITAL_BEDS_PER_THOUSAND               -- 60
  , LIFE_EXPECTANCY                          -- 61
  , HUMAN_DEVELOPMENT_INDEX                  -- 62
  , POPULATION                               -- 63
  , EXCESS_MORTALITY_CUMULATIVE_ABSOLUTE     -- 64
  , EXCESS_MORTALITY_CUMULATIVE              -- 65
  , EXCESS_MORTALITY                         -- 66
  , EXCESS_MORTALITY_CUMULATIVE_PER_MILLION  -- 67
  , LOADED_TS                                -- 68
)

FROM (
  SELECT
      $1  -- 1
    , $2  -- 2
    , $3  -- 3
    , $4  -- 4
    , $5  -- 5
    , $6  -- 6
    , $7  -- 7
    , $8  -- 8
    , $9  -- 9
    , $10 -- 10
    , $11 -- 11
    , $12 -- 12
    , $13 -- 13
    , $14 -- 14
    , $15 -- 15
    , $16 -- 16
    , $17 -- 17
    , $18 -- 18
    , $19 -- 19
    , $20 -- 20
    , $21 -- 21
    , $22 -- 22
    , $23 -- 23
    , $24 -- 24
    , $25 -- 25
    , $26 -- 26
    , $27 -- 27
    , $28 -- 28
    , $29 -- 29
    , $30 -- 30
    , $31 -- 31
    , $32 -- 32
    , $33 -- 33
    , $34 -- 34
    , $35 -- 35
    , $36 -- 36
    , $37 -- 37
    , $38 -- 38
    , $39 -- 39
    , $40 -- 40
    , $41 -- 41
    , $42 -- 42
    , $43 -- 43
    , $44 -- 44
    , $45 -- 45
    , $46 -- 46
    , $47 -- 47
    , $48 -- 48
    , $49 -- 49
    , $50 -- 50
    , $51 -- 51
    , $52 -- 52
    , $53 -- 53
    , $54 -- 54
    , $55 -- 55
    , $56 -- 56
    , $57 -- 57
    , $58 -- 58
    , $59 -- 59
    , $60 -- 60
    , $61 -- 61
    , $62 -- 62
    , $63 -- 63
    , $64 -- 64
    , $65 -- 65
    , $66 -- 66
    , $67 -- 67
    , CAST(CURRENT_TIMESTAMP() AS TIMESTAMP_TZ)  -- 68 LOADED_TS
  FROM @LANDING_EXT.S3.OWID_STAGE
  ( FILE_FORMAT => 'LANDING_EXT.S3.CSV_GENERIC_FORMAT' )
)
FILE_FORMAT = (FORMAT_NAME = 'LANDING_EXT.S3.CSV_GENERIC_FORMAT')
PATTERN = '^owid-covid-data\.csv$'
ON_ERROR = 'CONTINUE';

