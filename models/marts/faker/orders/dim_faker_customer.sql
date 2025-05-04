/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Dimension table for customers
         - One row per customer with associated email and country information
         - Contains email validity and domain information
         - Includes audit tracking with standard_audit_columns()
Notes:
  - Data sourced from int__faker__orders__dim_customer
  - Uses standard_audit_columns() macro for traceability
*/

{{ config(
    tags = ['marts', 'faker', 'dim']
) }}

WITH base AS (
    -- Pulls data from the int model for dim_customer
    SELECT * 
    FROM {{ ref('int_faker_orders_customer') }}
),

final AS (
    -- Enrich the data and ensure all fields are ready for reporting
    SELECT
          {{ generate_surrogate_key(['customer_id']) }} AS customer_sk
        , customer_id
        , customer_name
        , customer_email
        , customer_country
        , is_valid_email
        , email_domain
        , {{ standard_audit_columns() }}
    FROM base
)

SELECT * FROM final
