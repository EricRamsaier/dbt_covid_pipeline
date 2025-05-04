/*
Test: Valid order_status values in fct_faker_orders
Purpose: Ensures all order_status values are valid.
*/

SELECT 
    order_status
FROM {{ ref('fct_faker_orders') }}
WHERE order_status NOT IN ('recent', 'old', 'very_old')
