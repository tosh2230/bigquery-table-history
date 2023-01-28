from __future__ import annotations

from typing import Any

from google.cloud import bigquery
from jinja2 import BaseLoader, Environment

bq_client = bigquery.Client()


def read_query(file: str) -> str:
    with open(file, "r") as f:
        return f.read()


def render_template(source: str, params: dict[str, Any]) -> str:
    jinja_template = Environment(loader=BaseLoader()).from_string(source=source)
    return jinja_template.render(params)
