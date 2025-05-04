/*
Creator: Eric Ramsaier
Snapshot: snapshot_faker_orders_customer
Purpose:
  - Capture changes to customer data over time from Faker source.
Strategy:
  - Check strategy on customer_name, email, and country.
*/

{% snapshot snapshot_faker_orders_customer %}
{{
    config(
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_name', 'email', 'country']
    )
}}

SELECT *
FROM {{ source('faker__orders', 'faker_orders_customer') }}

{% endsnapshot %}
