#!/bin/bash
set -e

# 1. Подставим переменные из окружения в SQL-шаблон
envsubst < /init/init.sql.template > /docker-entrypoint-initdb.d/init.sql

# 2. Запускаем ClickHouse в фоне
clickhouse-server --config-file=/etc/clickhouse-server/config.xml &
CLICKHOUSE_PID=$!

# 3. Ждём пока ClickHouse поднимется
echo "Ожидание запуска ClickHouse..."
until clickhouse-client --query "SELECT 1" &>/dev/null; do
  sleep 1
done
echo "ClickHouse готов."

# 4. Применим init.sql
clickhouse-client --multiquery --queries-file=/docker-entrypoint-initdb.d/init.sql

# 5. Загрузим CSV через временного пользователя
/load_data.sh

# 6. Удалим временного пользователя
clickhouse-client --query "DROP USER IF EXISTS temp_loader"
echo "Пользователь temp_loader удалён."

# 7. Ждём завершения демона ClickHouse (если вдруг)
wait $CLICKHOUSE_PID

# 8. Запускаем стандартный entrypoint
exec /entrypoint.sh "$@"