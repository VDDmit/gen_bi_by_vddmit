ARG IMAGE_VERSION
FROM clickhouse/clickhouse-server:${IMAGE_VERSION}

# Install envsubst utility
RUN apt-get update && apt-get install -y gettext && apt-get clean

# Copy the SQL template and scripts
COPY init/init.sql.template /init/init.sql.template
COPY data /docker-entrypoint-initdb.d/data
COPY entrypoint-custom.sh /entrypoint-custom.sh
COPY load_data.sh /load_data.sh

# Make scripts executable
RUN chmod +x /entrypoint-custom.sh /load_data.sh

# Custom entrypoint
ENTRYPOINT ["/entrypoint-custom.sh"]