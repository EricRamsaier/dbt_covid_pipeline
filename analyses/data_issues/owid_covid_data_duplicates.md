# OWID COVID Data: Duplicate Date/Location Rows

**Description:**  
We’re seeing multiple records for the same (date, location).  
This likely happens when OWID splits metrics across two partial uploads.

**Impact:**  
—  Data from these rows may be double-counted in aggregates  
—  Tests on primary keys will always fail  

**Workaround:**  
Until OWID corrects upstream, we’ll dedupe by keeping the *latest* non-NULL row per (date, location) in our staging model:

```sql
SELECT
    stg_data.*,
    ROW_NUMBER() OVER (
        PARTITION BY iso_code, observation_dt
        ORDER BY (
            --sum of non-null numerics as proxy for most complete row
            coalesce(total_cases, 0)
        + coalesce(new_cases, 0)
        + coalesce(new_deaths, 0)
        ) DESC
    ) AS rn
FROM
    stg_data
QUALIFY rn = 1
