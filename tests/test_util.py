from src.util import read_query, render_template


def test_read_query():
    file = "tests/sql/test.sql"
    expected = "SELECT 1 AS num\nUNION ALL\nSELECT 2 AS num\n"
    actual = read_query(file=file)
    assert actual == expected


def test_render_template():
    source = "test {{ param }}"
    params = {"param": "strings"}
    actual = render_template(source=source, params=params)
    assert actual == "test strings"
