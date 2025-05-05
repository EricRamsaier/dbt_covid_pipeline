--Not used, but here to share conceptually a more programmatic approach

{#
  grant_env_privileges macro

  This macro automates schema creation and privilege grants in the production
  environment, using a single structured definition of roles, databases, and
  schema‐level permissions.

  How it works:
  1. Guard on the 'prod' target so grants only run in production.
  2. Define a 'grants' list where each entry specifies:
     - role: the Snowflake role to receive privileges
     - db:   the database name (e.g. 'dwh' or 'analytics')
     - db_privs: privileges applied at the database level (e.g. USAGE, CREATE SCHEMA)
     - schema_privs: a list of schema objects under that database with their own privileges
  3. Loop over each 'grants' entry:
     a) Create the first schema in each entry if it doesn’t exist.
     b) Apply the database‐level grants (if any).
     c) For each schema in 'schema_privs':
        • Grant the specified privileges on that schema.
        • If the role has SELECT rights, also grant SELECT on future tables in that schema
          so new tables automatically inherit the correct read permissions.

Vars needed in dbt_project.yml:
-vars:
-  dev_database:     dwh
-  mart_database:    analytics
-  etl_role:         etl_role
-  dev_role:         dev_role
-  analyst_role:     analyst_role
-  build_marts_in_dev: true

#}


{% macro grant_env_privileges() %}
  {% if target.name == 'prod' %}
    {% set grants = [
      { "role": var('etl_role'),
        "db":   var('dwh_database'),
        "schema_privs": [
          { "schema": "stg",          "privs": ["USAGE","CREATE TABLE"] },
          { "schema": "int",          "privs": ["USAGE","CREATE TABLE"] },
        ],
        "db_privs":     ["USAGE","CREATE SCHEMA"]
      },
      { "role": var('etl_role'),
        "db":   var('mart_database'),
        "schema_privs": [
          { "schema": "marts",        "privs": ["USAGE","CREATE TABLE"] },
        ],
        "db_privs":     ["USAGE","CREATE SCHEMA"]
      },
      { "role": var('dev_role'),
        "db":   var('dwh_database'),
        "schema_privs": [
          { "schema": "stg",          "privs": ["USAGE","SELECT"] },
          { "schema": "int",          "privs": ["USAGE","SELECT"] },
        ],
        "db_privs":     ["USAGE"]
      },
      { "role": var('dev_role'),
        "db":   var('mart_database'),
        "schema_privs": [
          { "schema": "marts",        "privs": ["USAGE","SELECT"] },
        ],
        "db_privs":     ["USAGE"]
      },
      { "role": var('analyst_role'),
        "db":   var('mart_database'),
        "schema_privs": [
          { "schema": "marts",        "privs": ["USAGE","SELECT"] },
        ],
        "db_privs":     []
      }
    ] %}

    {#  1) create schemas #}
    {% for entry in grants %}
      {% do run_query("CREATE SCHEMA IF NOT EXISTS " ~ entry.db ~ "." ~ entry.schema_privs[0].schema ~ ";") %}
      {# (repeat per schema if you wanted) #}
    {% endfor %}

    {#  2) apply grants #}
    {% for entry in grants %}
      {% if entry.db_privs %}
        {% do run_query("GRANT " ~ entry.db_privs | join(", ") ~ " ON DATABASE " ~ entry.db ~ " TO ROLE " ~ entry.role ~ ";") %}
      {% endif %}
      {% for s in entry.schema_privs %}
        {% do run_query("GRANT " ~ s.privs | join(", ") ~ " ON SCHEMA " ~ entry.db ~ "." ~ s.schema ~ " TO ROLE " ~ entry.role ~ ";") %}
        {% if "SELECT" in s.privs %}
          {% do run_query("GRANT SELECT ON FUTURE TABLES IN SCHEMA " ~ entry.db ~ "." ~ s.schema ~ " TO ROLE " ~ entry.role ~ ";") %}
        {% endif %}
      {% endfor %}
    {% endfor %}

  {% endif %}
{% endmacro %}
