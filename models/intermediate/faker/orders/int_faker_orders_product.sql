/*
Creator: Eric Ramsaier
Model: {{ this.identifier }}
Purpose: Dimension table for product categories
         - One row per category, with standardized category names
         - Includes pass-through from staging with audit tracking
Notes:
  - Data sourced from stg__faker__orders__dim_product
  - Uses standard_audit_columns() macro for traceability
*/

{{ config(
    tags = ['int', 'faker']
) }}

WITH base AS (
    -- Pulls data from the staging model for dim_product (category-related data)
    SELECT * FROM {{ ref('stg_faker_orders_product') }}
),

final AS (
    -- Enriches the data by standardizing the product category names
    SELECT
          product_id
        , product_name
        , product_category
        , CASE
            WHEN product_category IN ('Electronics', 'Clothing', 'Books') THEN product_category
            ELSE 'Other'
          END AS product_category_standardized  -- Standardizing product category
    FROM base
)

SELECT * FROM final
