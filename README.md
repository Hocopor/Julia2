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

## Ассеты

В `public/assets/` сейчас лежат валидные `jpg`-placeholder-файлы:

- `hero-photo.jpg`
- `about-photo.jpg`
- `issues-flower.jpg`
- `pricing-flower.jpg`
- `sea-photo.jpg`
- `contacts-photo.jpg`

Их можно заменить на финальные изображения без перестройки вёрстки.
