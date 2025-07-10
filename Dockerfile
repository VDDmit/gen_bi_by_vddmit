ARG IMAGE_VERSION
FROM clickhouse/clickhouse-server:${IMAGE_VERSION}

# Установка утилиты envsubst
RUN apt-get update && apt-get install -y gettext && apt-get clean

# Копируем SQL-шаблон и скрипты
COPY init/init.sql.template /init/init.sql.template
COPY data /docker-entrypoint-initdb.d/data
COPY entrypoint-custom.sh /entrypoint-custom.sh
COPY load_data.sh /load_data.sh

# Делаем скрипты исполняемыми
RUN chmod +x /entrypoint-custom.sh /load_data.sh

# Кастомный entrypoint
ENTRYPOINT ["/entrypoint-custom.sh"]