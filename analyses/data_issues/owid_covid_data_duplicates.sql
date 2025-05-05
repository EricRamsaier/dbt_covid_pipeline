-- Finds duplicated (date, location) rows in OWID COVID data

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