# Julia2

Лендинг психолога Юлии Кимлач на `Vite + React + TypeScript`.

В этой ветке деплой переведён с `Cloudflare Tunnel` на прямую публикацию с VPS через общий reverse proxy.

## Локальная разработка

```bash
npm install
npm run dev
```

## Production build

```bash
npm run build
npm run preview
```

## Переменные окружения

Создайте `.env` на основе `.env.example`.

Публичные переменные сайта:

- `VITE_CTA_URL`
- `VITE_WHATSAPP_URL`
- `VITE_TELEGRAM_URL`
- `VITE_VK_URL`
- `VITE_DEVELOPED_BY_URL`
- `VITE_BASE_PATH`

Серверные переменные деплоя:

- `PRIMARY_DOMAIN`
- `APP_PORT`
- `COMPOSE_PROJECT_NAME`

## Деплой на VPS без Cloudflare Tunnel

Ключевая схема:

1. Этот проект поднимает только контейнер приложения.
2. Контейнер доступен только на `127.0.0.1:${APP_PORT}`.
3. Домен `yuliakimlach.ru` обслуживается общим reverse proxy сервера.

Главные файлы:

- [docker-compose.yml](/A:/DevAI/Projects/Site/Julia2/docker-compose.yml)
- [Dockerfile](/A:/DevAI/Projects/Site/Julia2/Dockerfile)
- [DOCKER-DEPLOY.md](/A:/DevAI/Projects/Site/Julia2/DOCKER-DEPLOY.md)
- [deploy-server.sh](/A:/DevAI/Projects/Site/Julia2/deploy-server.sh)
- [deploy/caddy/Caddyfile.example](/A:/DevAI/Projects/Site/Julia2/deploy/caddy/Caddyfile.example)

Быстрый запуск на VPS:

```bash
cp .env.example .env
./deploy-server.sh
```

## Безопасность

В текущей схеме уже заложено:

- приложение не торчит в интернет напрямую
- локальный порт можно изолировать для каждого сайта отдельно
- контейнер работает на `nginx-unprivileged`
- включены `read_only`, `tmpfs`, `cap_drop: ALL`, `no-new-privileges`

## GitHub Pages

GitHub Pages можно оставить как отдельный запасной канал публикации, но основная production-схема в этой ветке теперь server-first.
