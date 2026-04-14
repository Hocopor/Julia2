# Деплой через Docker и Cloudflare Tunnel

## Полная автоматизация деплоя

Теперь проект поддерживает полную автоматизацию деплоя через Docker и Cloudflare Tunnel. Всё, что нужно - добавить токен и домен в `.env` файл.

## Быстрый старт (3 минуты)

### Шаг 1: Подготовка .env файла

```bash
# Копируем пример
cp .env.example .env

# Редактируем .env
nano .env  # или используйте любой редактор
```

**Заполните в .env:**
```env
# Обязательные:
CLOUDFLARE_TUNNEL_TOKEN=ваш_токен_туннеля
CLOUDFLARE_DOMAIN=ваш-домен.com

# Опционально (для автоматической настройки DNS):
CLOUDFLARE_API_TOKEN=ваш_api_токен
CLOUDFLARE_ACCOUNT_ID=ваш_account_id
CLOUDFLARE_TUNNEL_NAME=julia2-site  # по умолчанию
```

### Шаг 2: Получение токенов

#### 1. Токен туннеля (обязательно):
- Перейдите в [Cloudflare Dashboard](https://dash.cloudflare.com)
- Zero Trust → Access → Tunnels
- Нажмите "Create a tunnel"
- Дайте имя (например, `julia2-site`)
- **Скопируйте токен** (показывается один раз!)

#### 2. API токен (для автоматической настройки DNS, опционально):
- Cloudflare Dashboard → My Profile → API Tokens
- Create Token → Use template → "Edit zone DNS"
- Выберите зону вашего домена
- Скопируйте токен

### Шаг 3: Запуск деплоя
sudo chown -R $USER:$USER .../Julia2
sudo chmod -R 755 .../Julia2
git pull origin main
# Если не работает:
# 1. Обнови репозиторий (принудительно)
git fetch origin
git reset --hard origin/main

```bash
# Дайте права на выполнение скрипта (Linux/macOS)
chmod +x auto-deploy-cloudflare.sh

# Запустите автоматический деплой
./auto-deploy-cloudflare.sh
```

**Или вручную через Docker:**
```bash
# Соберите и запустите проект через Docker Compose
docker compose up -d --build 
docker-compose up -d

# Проверьте статус
docker-compose ps
```

### Шаг 4: Настройка DNS

#### Вариант A: Автоматически (если указаны API токены)
- Скрипт сам настроит DNS записи
- Подождите 5-30 минут для распространения DNS

#### Вариант B: Вручную (если нет API токенов)
1. Cloudflare Dashboard → Zero Trust → Access → Tunnels
2. Выберите ваш туннель
3. Configure → Public Hostname
4. Добавьте:
   - Hostname: `ваш-домен.com`
   - Service: `http://app:4173`
   - (Опционально) `www.ваш-домен.com`

### Шаг 5: Проверка
```bash
# Проверьте работу через 5-30 минут
curl -I https://ваш-домен.com

# Или откройте в браузере
open https://ваш-домен.com
```

## Файлы и скрипты

### Основные файлы:
- **`.env.example`** - шаблон конфигурации
- **`docker-compose.yml`** - базовая конфигурация Docker
- **`docker-compose-cloudflare.yml`** - с автоматической настройкой DNS
- **`Dockerfile`** - сборка приложения

### Скрипты:
- **`auto-deploy-cloudflare.sh`** - полная автоматизация (Linux/macOS)
- **`auto-deploy-cloudflare.ps1`** - полная автоматизация (Windows PowerShell)

## Архитектура решения

### Контейнеры:
1. **`app`** - React приложение на Vite
   - Порт: 4173
   - Запускает `npm run preview`
   - Healthcheck для мониторинга

2. **`cloudflared`** - Cloudflare Tunnel
   - Подключается к Cloudflare
   - Проксирует трафик на `app:4173`
   - Автоматическая настройка DNS (если есть API токен)

3. **`nginx`** (опционально) - для статики
   - Альтернатива preview серверу
   - Проксирование и SSL

### Переменные окружения:
```env
# Обязательные для деплоя
CLOUDFLARE_TUNNEL_TOKEN=eyJ...  # JWT токен туннеля
CLOUDFLARE_DOMAIN=example.com

# Для автоматической настройки DNS
CLOUDFLARE_API_TOKEN=ваш_api_токен
CLOUDFLARE_ACCOUNT_ID=ваш_account_id

# Настройки приложения
VITE_CTA_URL=https://wa.me/...
VITE_WHATSAPP_URL=https://wa.me/...
VITE_TELEGRAM_URL=https://t.me/...
VITE_DEVELOPED_BY_URL=https://t.me/...
```

## Управление после деплоя

### Просмотр логов:
```bash
# Все логи
docker-compose logs -f

# Только Cloudflare Tunnel
docker-compose logs -f cloudflared

# Только приложение
docker-compose logs -f app
```

### Управление контейнерами:
```bash
# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Обновление образов
docker-compose pull
docker-compose up -d

# Проверка статуса
docker-compose ps

# Вход в контейнер
docker-compose exec app sh
```

### Мониторинг:
```bash
# Использование ресурсов
docker stats

# Логи в реальном времени
docker-compose logs --tail=50 -f

# Проверка healthcheck
docker-compose ps --filter "health=healthy"
```

## Устранение неполадок

### Проблема: Туннель не запускается
```bash
# Проверьте токен
echo $CLOUDFLARE_TUNNEL_TOKEN

# Проверьте логи
docker-compose logs cloudflared

# Пересоздайте туннель
docker-compose down -v
docker-compose up -d
```

### Проблема: Приложение не запускается
```bash
# Проверьте сборку
npm run build

# Проверьте Docker образ
docker-compose build --no-cache

# Проверьте порты
netstat -tulpn | grep 4173
```

### Проблема: DNS не работает
```bash
# Проверьте DNS записи
nslookup ваш-домен.com
dig ваш-домен.com

# Проверьте Cloudflare Dashboard
# Убедитесь, что домен подключен к Cloudflare
```

### Проблема: SSL ошибки
1. В Cloudflare: SSL/TLS → Edge Certificates
2. Включите "Always Use HTTPS"
3. Выберите режим "Full"

## Производственная настройка

### Автоматический перезапуск:
```bash
# В docker-compose.yml
restart: always

# Или при запуске
docker-compose up -d --restart always
```

### Мониторинг и алерты:
```bash
# Используйте watchtower для обновлений
docker-compose -f docker-compose-cloudflare.yml up -d

# Настройте логирование в файл
docker-compose logs > logs/cloudflared-$(date +%Y%m%d).log
```

### Резервное копирование:
```bash
# Бэкап конфигурации
tar -czf backup-$(date +%Y%m%d).tar.gz .env docker-compose*.yml Dockerfile

# Бэкап Docker volumes
docker run --rm -v cloudflared-creds:/data -v $(pwd):/backup alpine tar -czf /backup/cloudflared-creds-$(date +%Y%m%d).tar.gz -C /data .
```

## Безопасность

### Рекомендации:
1. **Никогда не коммитьте `.env`** в git
2. Используйте `.gitignore` для чувствительных файлов
3. Регулярно обновляйте Docker образы
4. Используйте разные токены для разных окружений
5. Настройте брандмауэр для порта 4173

### Обновление токенов:
```bash
# Обновите .env файл
nano .env

# Перезапустите контейнеры
docker-compose down
docker-compose up -d
```

## Альтернативные варианты

### Без Docker (прямая установка):
Для настройки без Docker следуйте официальной документации Cloudflare:
```bash
# Установите cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb

# Создайте туннель
cloudflared tunnel create julia2-site

# Настройте DNS
cloudflared tunnel route dns julia2-site ваш-домен.com

# Запустите туннель
cloudflared tunnel run julia2-site
```

### Только Cloudflare Pages:
Для деплоя на Cloudflare Pages используйте Wrangler CLI:
```bash
# Установите Wrangler
npm install -g wrangler

# Соберите проект
npm run build

# Деплой
wrangler pages deploy ./dist --project-name=julia2-site
```

### GitHub Actions + Docker:
```yaml
# .github/workflows/docker-deploy.yml
name: Docker Deploy
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./auto-deploy-cloudflare.sh
```

## Поддержка

### Полезные ссылки:
- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Отладка:
```bash
# Полная отладка
docker-compose down
docker-compose build --no-cache
docker-compose up --force-recreate

# Проверка сети
docker network ls
docker network inspect julia2_default

# Очистка
docker system prune -a
docker volume prune
```

## Заключение

Теперь у вас есть полностью автоматизированная система деплоя:

1. **Добавьте токен и домен в `.env`**
2. **Запустите `./auto-deploy-cloudflare.sh`**
3. **Настройте DNS** (автоматически или вручную)
4. **Проверьте работу**

Всё остальное система сделает за вас: сборка, запуск контейнеров, подключение к Cloudflare, настройка HTTPS.

Для production используйте `docker-compose-cloudflare.yml` с API токенами для полной автоматизации.