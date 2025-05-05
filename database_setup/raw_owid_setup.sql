-- 1) Create the OWID landing schema if it doesn’t already exist
CREATE SCHEMA IF NOT EXISTS raw.owid;

-- 2) Grant ingestion service (RAW_INGEST_SVC) the ability to
--    • use the schema  
--    • create stages (for staged files)  
--    • create file formats  
--    • create tables  
--    • insert/update/delete/select on all current & future tables  
GRANT USAGE,
      CREATE STAGE,
      CREATE FILE FORMAT,
      CREATE TABLE
  ON SCHEMA raw.owid
  TO ROLE raw_ingest_svc;

GRANT INSERT,
      UPDATE,
      DELETE,
      SELECT
  ON ALL TABLES IN SCHEMA raw.owid
  TO ROLE raw_ingest_svc;

GRANT INSERT,
      UPDATE,
      DELETE,
      SELECT
  ON FUTURE TABLES IN SCHEMA raw.owid
  TO ROLE raw_ingest_svc;
