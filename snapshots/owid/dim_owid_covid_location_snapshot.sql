-- Purpose:       Track changes to OWID covid location dimension over time
-- Notes:
--   - Uses a check strategy to detect updates to location or continent
--   - Records a history of any changes to descriptive attributes

{% snapshot dim_owid_covid_location_snapshot %}

SELECT
    sk_owid_iso_code,
    owid_iso_code,
    location,
    continent
FROM {{ ref('dim_owid_covid_location') }}

{% endsnapshot %}
