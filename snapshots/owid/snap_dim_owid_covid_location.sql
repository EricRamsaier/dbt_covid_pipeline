-- Created:       2024-05-10
-- Last Modified: 2025-05-10
-- Creator:       Eric Ramsaier
-- Snapshot:      snap_dim_owid_covid_location
-- Purpose:       Track changes to OWID covid location dimension over time
-- Notes:
--   - Uses a check strategy to detect updates to location or continent
--   - Records a history of any changes to descriptive attributes

{% snapshot snap_dim_owid_covid_location %}
{{
  config(
    unique_key='owid_iso_code',
    strategy='check',
    check_cols=['location', 'continent'],
    tags=['snapshot', 'dim', 'owid']
  )
}}

SELECT
    sk_owid_iso_code,
    owid_iso_code,
    location,
    continent,
    {{ to_timestamp("CURRENT_TIMESTAMP()") }} AS dbt_snapshot_ts
FROM {{ ref('dim_owid_covid_location') }}

{% endsnapshot %}
