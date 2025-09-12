### CI/CD стенд – FastAPI + Nginx + Docker + Let's Encrypt

Этот проект демонстрирует простой пайплайн CI/CD с использованием:
- **FastAPI** (бэкенд приложение)
- **Docker & Docker Compose** (контейнеризация)
- **Nginx** (реверс‑прокси)
- **GitHub Actions** (CI/CD)
- **Let's Encrypt** (SSL-сертификаты)
---

### Возможности

* **Автоматическая сборка:** Сборка и отправка Docker-образа в Docker Hub при коммитах в `main`.
* **Автоматический деплой:** Развертывание на продакшн-сервер через GitHub Actions + SSH.
* **HTTPS:** Защита трафика с помощью Nginx и Let's Encrypt.
* **Простота масштабирования:** Лёгкое масштабирование с помощью `docker-compose`.
---

### Структура проекта
```
.
├── app
│   ├── main.py                   ### Основной файл приложения FastAPI
│   ├── static
│   │   ├── favicon.svg           ### Иконка сайта
│   │   └── style.css             ### CSS стиль для фронтенда
│   └── templates
│       ├── 404.html              ### Шаблон страницы ошибки 404
│       └── index.html            ### Главная страница приложения
├── .github/
│   └── workflows/
│       └── cicd.yml              ### Пайплайн GitHub Actions (CI/CD)
├── nginx/
│   └── conf.d/
│       ├── 80.default.conf       ### Конфигурация Nginx для выпуска сертификатов
│       └── 443.default.conf      ### Финальная конфигурация Nginx HTTPS
├── Dockerfile                    ### Инструкции для сборки Docker-образа приложения
├── docker-compose.yml            ### Описание и оркестрация Docker-сервисов
├── deploy.sh                     ### Скрипт для автоматического выпуска сертификата Let's Encrypt
├── example.env                   ### Пример файла с переменными окружения
├── README.md                     ### Документация проекта
└── requirements.txt              ### Зависимости для работы приложения на FastAPI

```

### GitHub Actions

В репозитории GitHub добавьте в **Settings -> Secrets and variables -> Actions** следующие секреты:
-   `DOCKERHUB_USERNAME` – логин Docker Hub
-   `DOCKERHUB_TOKEN` – токен Docker Hub
-   `SSH_HOST` – IP сервера
-   `SSH_USER` – пользователь для SSH
-   `SSH_PRIVATE_KEY` – приватный SSH-ключ для доступа


### Руководство по развертыванию на VPS

Данное руководство описывает шаги, которые необходимо выполнить **только один раз** на вашем сервере для выпуска SSL сертификата Let's Encrypt.

1.  **Подготовка сервера:**
    * Убедитесь, что на вашем VPS установлены **Docker** и **Docker Compose**.
    * Создайте пользователя для CI/CD-пайплайна (например, `ciсcd_user`) и настройте для него SSH-доступ используя приватный ключ SSH.
2.  **Клонирование репозитория:**
    * Подключитесь к серверу по SSH и клонируйте репозиторий в домашнюю директорию пользователя:
        `git clone https://github.com/evgd3v/cicd/ /home/ciсcd_user/evgd3v_cicd`
3.  **Настройка переменных:**
    * Переименуйте файл `example.env` в `.env`:
        ```bash
        mv example.env .env
        ```
    * Отредактируйте файл `.env`, заполнив поля `PROJECT_DIR`, `LETSENCRYPT_EMAIL` и `LETSENCRYPT_DOMAIN` в соотвествии с вашими данными проекта.
4.  **Запуск скрипта развертывания:**
    * Перейдите в директорию проекта: `cd /home/ciсcd_user/evgd3v_cicd`.
    * Сделайте скрипт deploy.sh выполняемым, для этого выполните `chmod +x deploy.sh`
    * Запустите скрипт, который автоматически выполнит все необходимые шаги, включая выпуск сертификата:
        `bash deploy.sh`


### Проверка и автоматизация

После успешного выполнения скрипта ваше приложение будет доступно по вашему домену через HTTPS. Дальнейшие коммиты в ветку `main` будут автоматически разворачиваться на сервере.

**Настройка Cron:**
Для автоматического продления сертификатов добавьте следующую строку в `crontab`:
```bash
0 */12 * * * cd /home/ciсcd_user/evgd3v_cicd && docker compose run --rm certbot renew && docker compose exec nginx nginx -s reload
```
