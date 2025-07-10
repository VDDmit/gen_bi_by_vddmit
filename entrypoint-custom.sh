#!/bin/bash

# Подставим переменные из окружения в SQL-шаблон
envsubst < /init/init.sql.template > /docker-entrypoint-initdb.d/init.sql

# Запускаем стандартный entrypoint
exec /entrypoint.sh "$@"