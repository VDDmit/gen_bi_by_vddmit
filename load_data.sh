#!/bin/bash
set -e

CLICKHOUSE_HOST="localhost"
CLICKHOUSE_PORT="8123"
CSV_FILE="/docker-entrypoint-initdb.d/data/audit_transactions_sample.csv"

echo "Загрузка CSV в ClickHouse..."
clickhouse-client \
  --host $CLICKHOUSE_HOST \
  --user temp_loader \
  --password loader_pass \
  --query "INSERT INTO ${CLICKHOUSE_DB}.audit_transactions FORMAT CSV" < "$CSV_FILE"

echo "Данные успешно загружены."