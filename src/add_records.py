from __future__ import annotations

import os
from typing import Iterator

from src.util import bq_client, read_query, render_template


def get_target_dataset(region: str) -> Iterator[str]:
    source = read_query("src/sql/get_target_datasets.sql")
    params = {"region": region}
    query = render_template(source=source, params=params)
    query_job = bq_client.query(query=query)
    for row in query_job:
        yield row["SCHEMA_NAME"]


def add_records(history_dataset: str, region: str) -> None:
    source = read_query("src/sql/add_records.sql")
    for target_dataset in get_target_dataset(region=region):
        params = {
            "history_dataset": history_dataset,
            "target_dataset": target_dataset,
        }
        query = render_template(source=source, params=params)
        query_job = bq_client.query(query)
        if query_job.error_result:
            print(query_job.error_result)


if __name__ == "__main__":
    history_dataset = os.environ["HISTORY_DATASET"]
    region = os.environ["REGION"]
    if not history_dataset:
        exit("HISTORY_DATASET is not set.")
    if not region:
        exit("REGION is not set.")
    add_records(
        history_dataset=history_dataset,
        region=region,
    )
