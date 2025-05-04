/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Dimension table for customers
         - One row per customer with associated email and country information
         - Includes email validity and domain extraction
         - Pass-through from stg with audit tracking
Notes:
  - Data sourced from stg__faker__orders__dim_customer
  - Uses standard_audit_columns() macro for traceability
*/

{{ config(
    tags = ['int', 'faker']
) }}

WITH base AS (
    -- Pulls data from the staging model for dim_customer
    SELECT * 
    FROM {{ ref('stg_faker_orders_customer') }}
),

final AS (
    -- Enriches the data with email validation and domain extraction
    SELECT
          customer_id
        , customer_name
        , customer_email
        , customer_country
        , CASE
            WHEN POSITION('@' IN customer_email) > 0 THEN TRUE
            ELSE FALSE
          END AS is_valid_email
        , CASE
            WHEN is_valid_email THEN SUBSTRING(customer_email, POSITION('@' IN customer_email) + 1)
          END AS email_domain
    FROM base
)

SELECT * FROM final
