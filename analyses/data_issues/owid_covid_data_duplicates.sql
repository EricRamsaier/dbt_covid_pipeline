-- Created:       2024-04-30
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Purpose:
--   - Identifies duplicate records in the OWID COVID dataset based on (date, iso_code).
--   - Helps assess upstream data integrity and detect load anomalies.
--
-- Notes:
--   - Combines date and location into a composite key for duplicate detection.
--   - Filters only rows that appear more than once with the same (date, iso_code) pair.
--   - Results are ordered for readability and debugging.

SELECT
    *
FROM raw.owid.owid_covid_data
WHERE (date || '~' || iso_code) IN (
    SELECT pk
    FROM (
        SELECT
            date || '~' || iso_code AS pk,
            COUNT(*) AS record_count
        FROM raw.owid.owid_covid_data
        GROUP BY 1
        HAVING COUNT(*) > 1
    )
)
ORDER BY 1, 2, 3, 4