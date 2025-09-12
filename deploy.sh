#!/bin/bash

if [ -f "./.env" ]; then
  export $(grep -v '^#' ./.env | xargs)
else
  echo "Ошибка: Файл .env не найден."
  exit 1
fi

if [ -z "${PROJECT_DIR}" ] || [ -z "${LETSENCRYPT_DOMAIN}" ]; then
  echo "Ошибка: Переменные PROJECT_DIR и/или LETSENCRYPT_DOMAIN не установлены в .env."
  exit 1
fi

CERTBOT_DIR="${PROJECT_DIR}/certbot/certs/live"
NGINX_CONF_DIR="${PROJECT_DIR}/nginx/conf.d"

if [ ! -d "${CERTBOT_DIR}/${LETSENCRYPT_DOMAIN}" ]; then
  echo "Сертификаты не найдены. Выполняется первоначальная настройка..."

  echo "Временно переключаем Nginx на 80 порт для получения сертификатов..."
  mv "${NGINX_CONF_DIR}/443.default.conf" "${NGINX_CONF_DIR}/temp.conf"
  mv "${NGINX_CONF_DIR}/80.default.conf" "${NGINX_CONF_DIR}/default.conf"

  echo "Запускаем Nginx и Certbot для получения сертификатов..."
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d --build --force-recreate nginx
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email "${LETSENCRYPT_EMAIL}" --agree-tos --non-interactive -d "${LETSENCRYPT_DOMAIN}" -d "www.${LETSENCRYPT_DOMAIN}"

  echo "Останавливаем временные контейнеры..."
  docker compose -f "${PROJECT_DIR}/docker-compose.yml" down

  echo "Переключаем Nginx на 443 порт..."
  mv "${NGINX_CONF_DIR}/default.conf" "${NGINX_CONF_DIR}/80.default.conf"
  mv "${NGINX_CONF_DIR}/temp.conf" "${NGINX_CONF_DIR}/default.conf"

  echo "Первоначальная настройка завершена. Сертификаты получены."
else
  echo "Сертификаты найдены. Выполняется стандартное обновление..."
fi

echo "Выполняем docker compose pull и up..."
docker compose -f "${PROJECT_DIR}/docker-compose.yml" pull
docker compose -f "${PROJECT_DIR}/docker-compose.yml" up -d --remove-orphans

echo "Развертывание завершено!"