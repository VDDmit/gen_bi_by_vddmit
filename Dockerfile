ARG IMAGE_VERSION
FROM clickhouse/clickhouse-server:${IMAGE_VERSION}

# Установка утилиты envsubst
RUN apt-get update && apt-get install -y gettext && apt-get clean

COPY init/init.sql.template /init/init.sql.template
COPY entrypoint-custom.sh /entrypoint-custom.sh
RUN chmod +x /entrypoint-custom.sh

ENTRYPOINT ["/entrypoint-custom.sh"]