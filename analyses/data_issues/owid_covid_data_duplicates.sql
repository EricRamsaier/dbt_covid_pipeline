-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Purpose:
--   - Identifies duplicate records in the OWID COVID dataset based on (date, location).
--   - Helps assess upstream data integrity and detect load anomalies.
--
-- Notes:
--   - Combines date and location into a composite key for duplicate detection.
--   - Filters only rows that appear more than once with the same (date, location) pair.
--   - Results are ordered for readability and debugging.

SELECT
    *
FROM raw.owid.owid_covid_data
WHERE (date || '~' || location) IN (
    SELECT pk
    FROM (
        SELECT
            date || '~' || location AS pk,
            COUNT(*) AS record_count
        FROM raw.owid.owid_covid_data
        GROUP BY 1
        HAVING COUNT(*) > 1
    )
)
ORDER BY 1, 2, 3, 4;


SELECT
    *
FROM raw.owid.owid_covid_data
WHERE (date || '~' || location) IN (
    SELECT pk
    FROM (
        SELECT
            DISTINCT date || '~' || location AS pk,
            COUNT(*) AS record_count
        FROM raw.owid.owid_covid_data
        GROUP BY 1
        HAVING COUNT(*) > 1
    )
)
ORDER BY 1, 2, 3, 4;