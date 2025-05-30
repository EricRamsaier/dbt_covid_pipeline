{# 
  Documentation for standard dbt audit fields.
  These fields are automatically populated to track metadata about each model run.
  Useful for debugging, data lineage, and auditability.
#}

{% docs dbt_model_name %}
The name of the dbt model that generated this record.  
Typically populated by referencing the model name during execution.  
Helps identify the source model in audit trails and downstream debugging.
{% enddocs %}

{% docs dbt_invocation_id %}
A unique identifier for the specific dbt run that produced this record.  
Useful for tracing records to a specific execution instance in your dbt job history.
{% enddocs %}

{% docs dbt_run_ts %}
The timestamp when the dbt model was executed.  
Recorded in UTC using the `current_timestamp` function.  
Valuable for tracking freshness and verifying data load timing.
{% enddocs %}

{% docs dbt_record_loaded_ts %}
The timestamp when the record was inserted into the target table.  
Typically populated with the `current_timestamp` function.  
Useful for audit and troubleshooting unexpected load delays or lags.
{% enddocs %}

{% docs loaded_ts %}
Timestamp when the record was **ingested into the warehouse**.  
Usually set via `current_timestamp()` at load time into the raw or external table.  
Used for freshness checks, data latency monitoring, and ingestion auditing.
{% enddocs %}

{% docs updated_ts %}
Timestamp when the record was **last updated** in the warehouse.  
This field is optional and typically only present in tables that receive updates.  
Useful for debugging late-arriving data or slowly changing dimensions (SCDs).
{% enddocs %}

{% docs dbt_snapshot_ts %}
Timestamp when the snapshot was **last updated** in the warehouse.
{% enddocs %}

{% docs dbt_valid_from %}
Timestamp when the record became valid.
{% enddocs %}

{% docs dbt_valid_to %}
Timestamp when the record stopped being valid.
{% enddocs %}

{% docs dbt_is_deleted %}
Indicates whether the record was deleted.
{% enddocs %}
