#!/bin/bash
set -e

# 1. Substitute environment variables into the SQL template
envsubst < /init/init.sql.template > /docker-entrypoint-initdb.d/init.sql

# 2. Start ClickHouse in the background
clickhouse-server --config-file=/etc/clickhouse-server/config.xml &
CLICKHOUSE_PID=$!

# 3. Wait for ClickHouse to become available
echo "Waiting for ClickHouse to start..."
until clickhouse-client --query "SELECT 1" &>/dev/null; do
  sleep 1
done
echo "ClickHouse is ready."

# 4. Apply init.sql
clickhouse-client --multiquery --queries-file=/docker-entrypoint-initdb.d/init.sql

# 5. Load CSV using a temporary user
/load_data.sh

# 6. Remove the temporary user
clickhouse-client --query "DROP USER IF EXISTS temp_loader"
echo "Temporary user temp_loader has been removed."

# 7. Wait for ClickHouse daemon to exit (just in case)
wait $CLICKHOUSE_PID

# 8. Run the default entrypoint
exec /entrypoint.sh "$@"