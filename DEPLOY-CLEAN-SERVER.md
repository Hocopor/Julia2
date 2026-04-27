# Деплой и запуск на чистом сервере

Эта инструкция рассчитана на чистый VPS с `Ubuntu 24.04` или совместимой Debian-системой.

Цель:

- поднять лендинг на домене `yuliakimlach.ru`
- не использовать `Cloudflare Tunnel`
- не конфликтовать с другими сайтами на том же сервере
- сразу заложить безопасную схему под несколько проектов

## Архитектура

Используем такой контур:

1. Этот проект работает в Docker-контейнере.
2. Контейнер публикуется только на локальный адрес сервера: `127.0.0.1:4180`.
3. Наружу в интернет смотрит только общий `Caddy`.
4. `Caddy` принимает `80/443`, выпускает TLS и проксирует домен на локальный порт проекта.

Если позже на сервере появятся другие сайты, они будут жить так же:

- `site-a.ru` -> `127.0.0.1:4180`
- `site-b.ru` -> `127.0.0.1:4181`
- `site-c.ru` -> `127.0.0.1:4182`

Это и защищает от конфликтов.

## Что нужно заранее

До начала убедитесь, что у вас есть:

- доступ по SSH к серверу
- домен `yuliakimlach.ru`
- доступ к DNS-записям домена
- репозиторий проекта на GitHub

## Шаг 1. Подключиться к серверу

```bash
ssh root@<IP_СЕРВЕРА>
```

Если работаете не под `root`, используйте пользователя с `sudo`.

## Шаг 2. Обновить систему

```bash
apt update && apt upgrade -y
timedatectl set-timezone Europe/Moscow
```

## Шаг 3. Создать отдельного пользователя для деплоя

Если такого пользователя ещё нет:

```bash
adduser deploy
usermod -aG sudo deploy
usermod -aG docker deploy
```

Если `docker`-группы ещё нет, это нормально, она появится после установки Docker.

Потом можно переподключиться:

```bash
ssh deploy@<IP_СЕРВЕРА>
```

## Шаг 4. Настроить firewall

Открываем только SSH, HTTP и HTTPS:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

Важно:

- порт `4180` наружу не открываем
- локальные порты приложений должны оставаться только на `127.0.0.1`

## Шаг 5. Установить Docker

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo $VERSION_CODENAME) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker
docker --version
docker compose version
```

Если работаете не под `root`, добавьте пользователя в docker-группу:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Шаг 6. Установить Caddy

```bash
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update
sudo apt install -y caddy
sudo systemctl enable caddy
sudo systemctl start caddy
sudo systemctl status caddy --no-pager
```

## Шаг 7. Настроить DNS домена

Для домена `yuliakimlach.ru` создайте записи:

- `A` для `@` -> IP вашего сервера
- `A` для `www` -> IP вашего сервера

Если используете `AAAA`, добавьте и IPv6 записи, но только если сервер реально доступен по IPv6.

Проверка:

```bash
dig yuliakimlach.ru +short
dig www.yuliakimlach.ru +short
```

Обе записи должны указывать на ваш VPS.

## Шаг 8. Клонировать проект

```bash
mkdir -p ~/sites
cd ~/sites
git clone <URL_ВАШЕГО_РЕПОЗИТОРИЯ> Julia2
cd Julia2
git checkout deploy/direct-server-yuliakimlach
```

Если ветка будет переименована или смержена, используйте актуальную ветку деплоя.

Если разворачиваете именно CDN-вариант из отдельной ветки, переключитесь на:

```bash
git checkout feature/yandex-cdn
```

## Шаг 9. Подготовить `.env`

```bash
cp .env.example .env
nano .env
```

Заполните минимум:

```env
VITE_CTA_URL=https://wa.me/7928...
VITE_WHATSAPP_URL=https://wa.me/7928...
VITE_TELEGRAM_URL=https://t.me/...
VITE_VK_URL=https://vk.com/...
VITE_DEVELOPED_BY_URL=https://t.me/...
VITE_BASE_PATH=/
VITE_ASSET_BASE_URL=
PRIMARY_DOMAIN=yuliakimlach.ru
APP_PORT=4180
COMPOSE_PROJECT_NAME=julia2
```

Важно:

- `VITE_BASE_PATH=/`
- `VITE_ASSET_BASE_URL` оставьте пустым, если CDN ещё не подключён
- `APP_PORT=4180` можно менять, если он занят
- если на сервере уже есть другой сайт на `4180`, поставьте `4181` или другой свободный локальный порт

Если подключаете `Yandex Cloud CDN` для изображений, задайте:

```env
VITE_ASSET_BASE_URL=https://cdn.yuliakimlach.ru
```

Подробности в:

- `YANDEX-CDN.md`

## Шаг 10. Проверить, что локальный порт свободен

```bash
ss -ltnp | grep 4180
```

Если команда ничего не вернула, порт свободен.

Если порт занят, измените `APP_PORT` в `.env`.

## Шаг 11. Первый запуск проекта

```bash
chmod +x deploy-server.sh
./deploy-server.sh
```

Что делает скрипт:

- читает `.env`
- пересобирает образ
- поднимает контейнер
- публикует сайт только на `127.0.0.1:${APP_PORT}`

Проверка:

```bash
docker compose ps
docker compose logs --tail=100 app
curl -I http://127.0.0.1:4180
```

Если `APP_PORT` у вас другой, подставьте его.

Ожидаемо должен прийти `HTTP/1.1 200 OK`.

## Шаг 12. Подключить домен через Caddy

Откройте общий конфиг:

```bash
sudo nano /etc/caddy/Caddyfile
```

Добавьте блок:

```caddy
yuliakimlach.ru, www.yuliakimlach.ru {
    encode zstd gzip

    header {
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
        Permissions-Policy "camera=(), geolocation=(), microphone=()"
    }

    reverse_proxy 127.0.0.1:4180
}
```

Если ваш локальный порт не `4180`, замените его в `reverse_proxy`.

Проверка конфига:

```bash
sudo caddy validate --config /etc/caddy/Caddyfile
```

Если всё хорошо:

```bash
sudo systemctl reload caddy
```

## Шаг 13. Проверить публичный сайт

```bash
curl -I https://yuliakimlach.ru
curl -I https://www.yuliakimlach.ru
```

И затем откройте сайт в браузере.

Если DNS уже распространился, Caddy сам выпустит TLS-сертификат.

## Шаг 14. Проверить безопасность

Проверьте, что наружу не торчит локальный порт приложения:

```bash
sudo ss -ltnp
```

Ожидаемая картина:

- `80` и `443` слушает `caddy`
- порт проекта опубликован как `127.0.0.1:4180`, а не `0.0.0.0:4180`

Также проверьте firewall:

```bash
sudo ufw status numbered
```

## Обновление проекта в будущем

Когда запушите новые изменения:

```bash
cd ~/sites/Julia2
git pull origin deploy/direct-server-yuliakimlach
./deploy-server.sh
```

Если ветка будет уже смержена в `main`, тогда:

```bash
git pull origin main
./deploy-server.sh
```

## Если на сервере уже есть другие сайты

Тогда действует простое правило:

- у каждого проекта свой `APP_PORT`
- у всех проектов один общий `Caddy`
- у каждого домена свой блок в `/etc/caddy/Caddyfile`

Пример:

```caddy
site-one.ru {
    reverse_proxy 127.0.0.1:4180
}

site-two.ru {
    reverse_proxy 127.0.0.1:4181
}

yuliakimlach.ru, www.yuliakimlach.ru {
    reverse_proxy 127.0.0.1:4182
}
```

## Если что-то не работает

### Проверить контейнер

```bash
cd ~/sites/Julia2
docker compose ps
docker compose logs --tail=200 app
```

### Проверить локальную отдачу сайта

```bash
curl -I http://127.0.0.1:4180
```

### Проверить Caddy

```bash
sudo systemctl status caddy --no-pager
sudo journalctl -u caddy -n 100 --no-pager
sudo caddy validate --config /etc/caddy/Caddyfile
```

### Проверить DNS

```bash
dig yuliakimlach.ru +short
dig www.yuliakimlach.ru +short
```

## Минимальный чеклист после завершения

После полного деплоя должно быть так:

- `https://yuliakimlach.ru` открывается
- `https://www.yuliakimlach.ru` открывается
- контейнер проекта healthy
- `docker compose ps` без ошибок
- `caddy` работает без ошибок
- локальный порт приложения не открыт наружу

## Что не делать

- не публиковать сайт напрямую на `0.0.0.0:4180`
- не открывать `4180` в firewall
- не хранить реальные секреты в git
- не запускать несколько сайтов на одном и том же `APP_PORT`
- не использовать `vite preview` как production-веб-сервер
