#!/bin/bash

# Полная автоматизация деплоя через Cloudflare Tunnel
# Использование: ./auto-deploy-cloudflare.sh

set -e

echo "=== Полная автоматизация деплоя через Cloudflare Tunnel ==="
echo "=========================================================="

# Проверяем наличие .env файла
if [ ! -f .env ]; then
    echo "[ERROR] Файл .env не найден."
    echo ""
    echo "Создайте .env файл:"
    echo "cp .env.example .env"
    echo ""
    echo "Заполните следующие переменные в .env:"
    echo ""
    echo "1. CLOUDFLARE_TUNNEL_TOKEN - токен туннеля"
    echo "   Получить: Cloudflare Dashboard → Zero Trust → Access → Tunnels → Create tunnel"
    echo ""
    echo "2. CLOUDFLARE_DOMAIN - ваш домен (например: example.com)"
    echo ""
    echo "3. (Опционально) Для автоматической настройки DNS:"
    echo "   CLOUDFLARE_API_TOKEN - API токен Cloudflare"
    echo "   CLOUDFLARE_ACCOUNT_ID - ID аккаунта Cloudflare"
    echo ""
    echo "Получить API токен:"
    echo "Cloudflare Dashboard → My Profile → API Tokens → Create Token"
    echo "Используйте шаблон: 'Edit zone DNS'"
    exit 1
fi

# Загружаем переменные
source .env

# Проверяем обязательные переменные
MISSING_VARS=()
[ -z "$CLOUDFLARE_TUNNEL_TOKEN" ] && MISSING_VARS+=("CLOUDFLARE_TUNNEL_TOKEN")
[ -z "$CLOUDFLARE_DOMAIN" ] && MISSING_VARS+=("CLOUDFLARE_DOMAIN")

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo "[ERROR] Отсутствуют обязательные переменные в .env:"
    for var in "${MISSING_VARS[@]}"; do
        echo "   - $var"
    done
    exit 1
fi

# Устанавливаем значения по умолчанию
TUNNEL_NAME=${CLOUDFLARE_TUNNEL_NAME:-"julia2-site"}
HAS_API_ACCESS=false

if [ -n "$CLOUDFLARE_API_TOKEN" ] && [ -n "$CLOUDFLARE_ACCOUNT_ID" ]; then
    HAS_API_ACCESS=true
    echo "[OK] Обнаружен API доступ к Cloudflare"
else
    echo "[INFO] API доступ не настроен. DNS нужно настроить вручную."
fi

echo ""
echo "=== Конфигурация ==="
echo "   • Домен: $CLOUDFLARE_DOMAIN"
echo "   • Имя туннеля: $TUNNEL_NAME"
echo "   • Автоматическая настройка DNS: $HAS_API_ACCESS"
echo ""

# Проверяем Docker
if ! command -v docker &> /dev/null; then
    echo "[ERROR] Docker не установлен"
    echo "Установите Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose не установлен"
    echo "Установите Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "[OK] Docker и Docker Compose готовы"

# Собираем проект через Docker
echo ""
echo "[INFO] Собираем проект через Docker..."
if [ "$HAS_API_ACCESS" = true ]; then
    docker-compose -f docker-compose-cloudflare.yml build
else
    docker-compose build
fi

# Запускаем Docker Compose
echo ""
echo "[INFO] Запускаем Docker Compose..."

if [ "$HAS_API_ACCESS" = true ]; then
    echo "Используем автоматическую настройку DNS..."
    docker-compose -f docker-compose-cloudflare.yml up -d
else
    echo "Используем базовую конфигурацию..."
    docker-compose up -d
fi

echo ""
echo "⏳ Ожидаем запуска (40 секунд)..."
sleep 40

# Проверяем статус
echo ""
echo "📊 Статус контейнеров:"
docker-compose ps

echo ""
echo "📝 Логи Cloudflare Tunnel:"
docker-compose logs --tail=10 cloudflared

echo ""
echo "========================================================"
echo "🎉 Деплой запущен!"
echo ""

if [ "$HAS_API_ACCESS" = true ]; then
    echo "✅ DNS настроены автоматически через Cloudflare API"
    echo "⏱️  Подождите 5-30 минут для распространения DNS"
else
    echo "📋 Ручная настройка DNS:"
    echo ""
    echo "1. Перейдите в Cloudflare Dashboard:"
    echo "   https://dash.cloudflare.com"
    echo ""
    echo "2. Zero Trust → Access → Tunnels"
    echo ""
    echo "3. Выберите туннель: '$TUNNEL_NAME'"
    echo ""
    echo "4. Нажмите 'Configure' → 'Public Hostname'"
    echo ""
    echo "5. Добавьте новую запись:"
    echo "   • Hostname: $CLOUDFLARE_DOMAIN"
    echo "   • Service: http://app:4173"
    echo "   • (Опционально) www.$CLOUDFLARE_DOMAIN"
    echo ""
    echo "6. Сохраните и подождите 5-30 минут"
fi

echo ""
echo "[OK] Проверьте работу:"
echo "   https://$CLOUDFLARE_DOMAIN"
echo ""
echo "[INFO] Управление:"
echo "   • Логи: docker-compose logs -f"
echo "   • Остановка: docker-compose down"
echo "   • Перезапуск: docker-compose restart"
echo "   • Обновление: docker-compose pull && docker-compose up -d"
echo ""
echo "[INFO] Файлы конфигурации:"
echo "   • docker-compose.yml - базовая конфигурация"
echo "   • docker-compose-cloudflare.yml - с автоматической настройкой DNS"
echo "   • Dockerfile - сборка приложения"
echo ""
echo "[INFO] Для отладки:"
echo "   docker-compose logs cloudflared"
echo "   docker-compose exec app sh"
echo ""
echo "========================================================"