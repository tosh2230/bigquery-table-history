from __future__ import annotations

import os

from src.util import bq_client, read_query, render_template


def diff_records(history_dataset: str, base_date: str) -> None:
    source = read_query("src/sql/diff_records.sql")
    params = {
        "history_dataset": history_dataset,
        "base_date": base_date,
    }
    query = render_template(source=source, params=params)
    query_job = bq_client.query(query=query)
    for row in query_job:
        print(row)


if __name__ == "__main__":
    base_date = os.environ["BASE_DATE"]
    diff_records(history_dataset="admin", base_date=base_date)
