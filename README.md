# Julia2

Точный mobile-first лендинг по документации из `docs/` для деплоя на `GitHub Pages`.

## Стек

- `Vite`
- `React`
- `TypeScript`

## Запуск локально

```bash
npm install
npm run dev
```

## Production build

```bash
npm run build
npm run preview
```

Сайт собирается с `base: /Julia2/` под репозиторий `Julia2`.

## Переменные окружения

Создайте `.env` на основе `.env.example`.

Используемые публичные переменные:

- `VITE_CTA_URL`
- `VITE_WHATSAPP_URL`
- `VITE_TELEGRAM_URL`
- `VITE_DEVELOPED_BY_URL`

Если переменные не заданы, проект использует безопасные заглушки и продолжает собираться.

## GitHub Pages

Деплой настроен через workflow:

- [deploy.yml](/A:/DevAI/Projects/Site/Julia2/.github/workflows/deploy.yml)

Для production-ссылок добавьте `Repository variables` в GitHub:

- `VITE_CTA_URL`
- `VITE_WHATSAPP_URL`
- `VITE_TELEGRAM_URL`
- `VITE_DEVELOPED_BY_URL`

## Docker + Cloudflare Tunnel (полная автоматизация)

Для автоматического деплоя через Docker и Cloudflare Tunnel:

### Быстрый старт (3 минуты):
```bash
# 1. Настройте .env
cp .env.example .env
# Отредактируйте .env, добавьте токен и домен

# 2. Запустите автоматический деплой
./auto-deploy-cloudflare.sh
```

### Полная документация:
- [DOCKER-DEPLOY.md](DOCKER-DEPLOY.md) - полная инструкция по Docker деплою и Cloudflare Tunnel

### Основные файлы:
- `docker-compose.yml` - базовая конфигурация Docker
- `docker-compose-cloudflare.yml` - с автоматической настройкой DNS
- `Dockerfile` - сборка приложения
- `auto-deploy-cloudflare.sh` - скрипт полной автоматизации

### Что нужно сделать:
1. Создайте туннель в Cloudflare Zero Trust
2. Сохраните токен в `.env` как `CLOUDFLARE_TUNNEL_TOKEN`
3. Укажите домен в `.env` как `CLOUDFLARE_DOMAIN`
4. Запустите скрипт деплоя
5. (Опционально) Настройте DNS автоматически через API токен

## Ассеты

В `public/assets/` сейчас лежат валидные `jpg`-placeholder-файлы:

- `hero-photo.jpg`
- `about-photo.jpg`
- `issues-flower.jpg`
- `pricing-flower.jpg`
- `sea-photo.jpg`
- `contacts-photo.jpg`

Их можно заменить на финальные изображения без перестройки вёрстки.
