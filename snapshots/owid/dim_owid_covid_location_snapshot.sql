-- Purpose:       Track changes to OWID covid location dimension over time
-- Notes:
--   - Uses a check strategy to detect updates to location or continent
--   - Records a history of any changes to descriptive attributes

{% snapshot dim_owid_covid_location_snapshot %}
{{
  config(
    unique_key =    'owid_iso_code',
    strategy =      'check',
    check_cols =    ['location', 'continent'],
    hard_deletes =  'new_record'
  )
}}

SELECT
    sk_owid_iso_code,
    owid_iso_code,
    location,
    continent
FROM {{ ref('dim_owid_covid_location') }}

{% endsnapshot %}
