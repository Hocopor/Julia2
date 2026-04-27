# Yandex Cloud CDN для мобильной загрузки

Этот проект подготовлен под подключение `Yandex Cloud CDN` без переноса основного сайта с `yuliakimlach.ru`.

Рекомендуемая схема для этого лендинга:

- HTML остаётся на `https://yuliakimlach.ru`
- тяжёлые изображения отдаются через `https://cdn.yuliakimlach.ru`
- origin для CDN остаётся ваш текущий сайт на VPS

Такой подход проще, чем ставить CDN сразу на apex-домен, и лучше подходит для ускорения мобильной загрузки изображений.

## Что уже реализовано в коде

В проект добавлена переменная:

- `VITE_ASSET_BASE_URL`

Если она пустая:

- изображения загружаются как раньше с основного домена

Если она задана, например:

```env
VITE_ASSET_BASE_URL=https://cdn.yuliakimlach.ru
```

тогда изображения из `public/assets` будут запрашиваться так:

- `https://cdn.yuliakimlach.ru/assets/hero-photo-v5.png`
- `https://cdn.yuliakimlach.ru/assets/about-photo-v5.png`
- и так далее

## Почему это хороший вариант

Плюсы:

- основной сайт не трогаем
- не упираемся в ограничения `CNAME` для apex-домена
- ускоряем именно тяжёлые изображения
- можно быстро откатить, просто очистив `VITE_ASSET_BASE_URL`

## Как настроить в Yandex Cloud

Официальные документы:

- Getting started: https://yandex.cloud/en/docs/cdn/quickstart
- Caching: https://yandex.cloud/en/docs/cdn/concepts/caching
- Host header: https://yandex.cloud/en/docs/cdn/concepts/servers-to-origins-host

Ниже схема именно под этот проект.

## Шаг 1. Подготовить домен CDN

Выберите отдельный поддомен для раздачи ассетов:

- `cdn.yuliakimlach.ru`

Важно:

- основной сайт остаётся на `yuliakimlach.ru`
- CDN-домен будет использоваться только для ассетов

## Шаг 2. Создать CDN resource

В `Yandex Cloud CDN`:

1. Создайте `Origin group`
2. Origin type: `Server`
3. Origin:

```text
yuliakimlach.ru
```

Потом создайте `CDN resource`:

1. Primary domain:

```text
cdn.yuliakimlach.ru
```

2. Origin / origin group:
   используйте origin group с `yuliakimlach.ru`

3. Host header:
   выберите `Custom`

4. Header value:

```text
yuliakimlach.ru
```

Это важно: origin-сервер должен видеть запросы как к `yuliakimlach.ru`, а не как к `cdn.yuliakimlach.ru`.

## Шаг 3. Настроить DNS

После создания CDN ресурса `Yandex Cloud` даст вам домен вида:

```text
e1b83ae3********.topology.gslb.yccdn.ru
```

В DNS нужно создать:

```text
cdn CNAME e1b83ae3********.topology.gslb.yccdn.ru.
```

Важно:

- используйте именно `CNAME`
- по документации `Yandex Cloud` не рекомендует использовать `ANAME` для доменов раздачи CDN

## Шаг 4. Включить CDN в проекте

В `.env` проекта задайте:

```env
VITE_ASSET_BASE_URL=https://cdn.yuliakimlach.ru
```

Потом пересоберите проект:

```bash
npm run build
```

Дальше обновите сервер:

```bash
git pull
docker compose up -d --build
```

## Шаг 5. Проверить

Проверьте HTML:

```bash
curl -s https://yuliakimlach.ru | grep cdn.yuliakimlach.ru
```

Проверьте один ассет:

```bash
curl -I https://cdn.yuliakimlach.ru/assets/about-photo-v5.png
```

Ожидаемо должен быть `200`.

## Кэш и обновление фото

Сейчас в проекте для ассетов настроен долгий кэш.

Это хорошо для скорости, но важно помнить:

### Если имя файла меняется

Например:

- `about-photo-v5.png` -> `about-photo-v6.png`

тогда CDN сам начнёт тянуть новый файл, и проблем обычно не будет.

### Если имя файла не меняется

Например вы просто перезалили новый файл с тем же именем:

- `about-photo-v5.png`

тогда после деплоя может понадобиться `purge` этого пути в `Yandex Cloud CDN`.

Очищать нужно путь вида:

```text
/assets/about-photo-v5.png
```

## Что ускорится

После включения `VITE_ASSET_BASE_URL` через CDN пойдут:

- `hero-photo-v5.png`
- `about-photo-v5.png`
- `issues-flower-v5.png`
- `pricing-flower-v5.png`
- `sea-photo-v5.png`
- `contacts-photo-v5.png`

То есть именно самые тяжёлые изображения лендинга.

## Что не пойдёт через CDN в текущей реализации

Пока через CDN не уводятся:

- HTML
- Vite JS bundle
- CSS bundle

Это осознанно: для первого шага мы ускоряем именно изображения, не усложняя весь контур сайта.

Если позже захотите, можно отдельно перевести на CDN и остальную статику, но это уже следующий этап.
