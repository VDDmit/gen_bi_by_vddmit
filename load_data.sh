#!/bin/bash
set -e

CLICKHOUSE_HOST="localhost"
CLICKHOUSE_PORT="8123"
CSV_FILE="/docker-entrypoint-initdb.d/data/transaction_changes_data.csv"

echo "Loading CSV into ClickHouse..."
clickhouse-client \
  --host $CLICKHOUSE_HOST \
  --user temp_loader \
  --password loader_pass \
  --query "INSERT INTO ${CLICKHOUSE_DB}.transaction_changes FORMAT CSV" < "$CSV_FILE"

echo "Data successfully loaded."