# Прямой деплой на VPS без Cloudflare Tunnel

Этот проект переведён на прямую публикацию с сервера через общий reverse proxy.

Рекомендуемая схема для VPS с несколькими сайтами:

1. У каждого проекта свой Docker-контейнер приложения.
2. Каждый проект публикует только локальный порт вида `127.0.0.1:4180`.
3. Единственный внешний `80/443` держит общий reverse proxy на сервере.
4. Для этого проекта домен: `yuliakimlach.ru`.

Такая схема:

- не конфликтует с другими сайтами на том же VPS
- не открывает внутренний порт приложения наружу
- упрощает TLS и ротацию сертификатов
- уменьшает площадь атаки

## Что используется в этом репозитории

- `docker-compose.yml` — приложение, доступное только на `127.0.0.1:${APP_PORT}`
- `Dockerfile` — сборка Vite и запуск статического сайта через `nginx-unprivileged`
- `deploy/caddy/Caddyfile.example` — рекомендуемый reverse proxy для домена
- `deploy-server.sh` — деплой на Linux VPS
- `deploy-server.ps1` — деплой из PowerShell

## Рекомендуемая схема на сервере

### Приложение

- контейнер слушает `8080` внутри Docker
- на хост пробрасывается только `127.0.0.1:${APP_PORT}`

### Reverse proxy

Рекомендуется один общий `Caddy` или `Nginx` на весь VPS.

Для этого проекта прокси должен направлять:

- `yuliakimlach.ru`
- `www.yuliakimlach.ru`

на:

- `127.0.0.1:4180` или другой локальный порт, который вы зададите в `.env`

## Быстрый деплой на VPS

### 1. Подготовить `.env`

```bash
cp .env.example .env
```

Минимально заполните:

```env
VITE_CTA_URL=https://wa.me/...
VITE_WHATSAPP_URL=https://wa.me/...
VITE_TELEGRAM_URL=https://t.me/...
VITE_VK_URL=https://vk.com/...
VITE_DEVELOPED_BY_URL=https://t.me/...
VITE_BASE_PATH=/
PRIMARY_DOMAIN=yuliakimlach.ru
APP_PORT=4180
COMPOSE_PROJECT_NAME=julia2
```

Если на сервере уже есть сайт на `4180`, просто выберите другой локальный порт, например `4181`, `4280` или `4380`.

### 2. Проверить DNS

Домен `yuliakimlach.ru` и `www.yuliakimlach.ru` должны указывать на IP вашего VPS.

### 3. Поднять контейнер приложения

```bash
chmod +x deploy-server.sh
./deploy-server.sh
```

Или вручную:

```bash
docker compose down --remove-orphans
docker compose up -d --build
docker compose ps
```

### 4. Подключить домен через reverse proxy

Скопируйте пример-конфиг из:

- `deploy/caddy/Caddyfile.example`

и включите его в общий `Caddyfile` сервера.

## Конфиг Caddy

Пример уже подготовлен:

- `deploy/caddy/Caddyfile.example`

Что он делает:

- принимает `80/443`
- автоматически выпускает TLS-сертификаты
- проксирует только на локальный порт приложения
- добавляет базовые security headers

## Обновление после `git pull`

Если проект уже развернут на VPS, после обновления кода:

```bash
git pull origin <ваша-ветка>
./deploy-server.sh
```

Пересборка контейнера обязательна, потому что статический билд запекается внутрь Docker-образа.

## Безопасность

Для этого проекта зафиксированы такие меры:

1. Приложение не публикуется в интернет напрямую, только в `127.0.0.1`.
2. Контейнер работает на `nginx-unprivileged`, а не на root.
3. У контейнера включены:
   - `read_only: true`
   - `tmpfs`
   - `cap_drop: ALL`
   - `no-new-privileges:true`
4. В reverse proxy должны быть включены HTTPS и редирект с `http` на `https`.
5. На VPS наружу должны быть открыты только:
   - `22` или ваш SSH-порт
   - `80`
   - `443`
6. Локальные порты приложений типа `4180` не нужно открывать в firewall.

## Проверка

После деплоя проверьте:

```bash
docker compose ps
docker compose logs --tail=100 app
curl -I http://127.0.0.1:4180
curl -I https://yuliakimlach.ru
```

## Если на сервере несколько сайтов

Безопасный паттерн такой:

- `site-a.ru` -> `127.0.0.1:4180`
- `site-b.ru` -> `127.0.0.1:4181`
- `site-c.ru` -> `127.0.0.1:4182`

А внешний `80/443` держит один общий reverse proxy.

Именно это и защищает сайты от конфликтов по портам.
