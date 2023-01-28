INSERT INTO
    {{ history_dataset }}.information_schema_partitions_history
SELECT
    CURRENT_TIMESTAMP() as recorded_at,
    table_catalog,
    table_schema,
    table_name,
    partition_id,
    total_rows,
    total_logical_bytes,
    total_billable_bytes,
    last_modified_time,
    storage_tier
FROM
    {{ target_dataset }}.INFORMATION_SCHEMA.PARTITIONS
