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
  *,
  ROW_NUMBER() OVER (
    PARTITION BY date, location
    ORDER BY coalesce(total_cases, -1) DESC
  ) AS row_num
FROM raw.owid.owid_covid_data
QUALIFY row_num = 1;
