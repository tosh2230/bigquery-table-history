.PHONY: create-table add diff lint format

create-table:
	bq mk \
		--table $(HISTORY_DATASET).information_schema_partitions_history \
		--schema schemas/information_schema_partitions_history.json \
		--project_id=$(PROJECT_ID)

add:
	@HISTORY_DATASET=$(HISTORY_DATASET) REGION=$(REGION) poetry run python -m src.add_records

diff:
	@BASE_DATE=$(BASE_DATE) poetry run python -m src.diff_records

lint:
	poetry run flake8 src tests
	poetry run isort --check --diff src tests
	poetry run black --check src tests
	poetry run mypy src tests

format:
	poetry run isort src tests
	poetry run black src tests
