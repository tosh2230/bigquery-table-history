WITH today AS (
    SELECT
        latest.*
    FROM (
        SELECT
            table_catalog,
            table_schema,
            table_name,
            partition_id,
            ARRAY_AGG(history ORDER BY history.recorded_at DESC LIMIT 1)[OFFSET(0)] AS latest
        FROM
            {{ history_dataset }}.information_schema_partitions_history AS history
        WHERE
            recorded_at >= TIMESTAMP("{{ base_date }}", "Asia/Tokyo")
            AND recorded_at < TIMESTAMP_ADD(TIMESTAMP("{{ base_date }}", "Asia/Tokyo"), INTERVAL 1 DAY)
            AND table_schema != "{{ history_dataset }}"
            AND table_name != "information_schema_partitions_history"
        GROUP BY
            table_catalog,
            table_schema,
            table_name,
            partition_id
    )
),
yesterday AS (
    SELECT
        latest.*
    FROM (
        SELECT
            table_catalog,
            table_schema,
            table_name,
            partition_id,
            ARRAY_AGG(history ORDER BY history.recorded_at DESC LIMIT 1)[OFFSET(0)] AS latest
        FROM
            {{ history_dataset }}.information_schema_partitions_history AS history
        WHERE
            recorded_at >= TIMESTAMP_SUB(TIMESTAMP("{{ base_date }}", "Asia/Tokyo"), INTERVAL 1 DAY)
            AND recorded_at < TIMESTAMP("{{ base_date }}", "Asia/Tokyo")
            AND table_schema != "{{ history_dataset }}"
            AND table_name != "information_schema_partitions_history"
        GROUP BY
            table_catalog,
            table_schema,
            table_name,
            partition_id
    )
)

SELECT
    FORMAT_TIMESTAMP("%F %T", today.recorded_at, "Asia/Tokyo") AS recorded_at_jst,
    diff.*
FROM (
    SELECT * EXCEPT(recorded_at) FROM today
    EXCEPT DISTINCT
    SELECT * EXCEPT(recorded_at) FROM yesterday
) AS diff
    LEFT OUTER JOIN today ON
        diff.table_catalog = today.table_catalog
        AND diff.table_schema = today.table_schema
        AND diff.table_name = today.table_name
UNION ALL
SELECT
    FORMAT_TIMESTAMP("%F %T", yesterday.recorded_at, "Asia/Tokyo") AS recorded_at_jst,
    diff.*
FROM (
    SELECT * EXCEPT(recorded_at) FROM yesterday
    EXCEPT DISTINCT
    SELECT * EXCEPT(recorded_at) FROM today
) AS diff
    LEFT OUTER JOIN yesterday ON
        diff.table_catalog = yesterday.table_catalog
        AND diff.table_schema = yesterday.table_schema
        AND diff.table_name = yesterday.table_name
ORDER BY
    table_catalog,
    table_schema,
    table_name,
    partition_id,
    recorded_at_jst
