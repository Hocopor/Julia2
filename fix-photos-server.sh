#!/bin/bash

# Скрипт для полной очистки и пересборки с новыми фотографиями
# Использование: ./fix-photos-server.sh

set -e

echo "=== СКРИПТ ОЧИСТКИ И ПЕРЕСБОРКИ С НОВЫМИ ФОТОГРАФИЯМИ ==="
echo "=========================================================="

# Проверяем что мы в директории проекта
if [ ! -f "package.json" ]; then
    echo "[ERROR] Не найден package.json. Запустите скрипт в директории проекта."
    exit 1
fi

echo "[1/8] Проверяем git статус..."
git status

echo "[2/8] Проверяем наличие новых фотографий в public/assets/..."
ls -lh public/assets/ || echo "WARNING: public/assets/ не существует"

echo "[3/8] Удаляем локальную папку dist если существует..."
rm -rf dist/ 2>/dev/null || true

echo "[4/8] Останавливаем Docker контейнеры..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null || echo "Контейнеры уже остановлены"

echo "[5/8] Очищаем Docker кэш и образы..."
docker builder prune -f -a 2>/dev/null || echo "Не удалось очистить builder кэш"
docker image rm julia2-app:latest 2>/dev/null || true

echo "[6/8] Принудительно обновляем проект из git..."
git fetch origin
git reset --hard origin/main

echo "[7/8] Пересобираем Docker с очисткой кэша..."
if command -v docker-compose &> /dev/null; then
    docker-compose build --no-cache --pull
else
    docker compose build --no-cache --pull
fi

echo "[8/8] Запускаем контейнеры..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

echo ""
echo "=========================================================="
echo "[OK] Пересборка завершена!"
echo ""
echo "Проверьте файлы внутри контейнера:"
CONTAINER_ID=$(docker ps --filter "name=julia2-app" --format "{{.ID}}" 2>/dev/null || echo "")
if [ -n "$CONTAINER_ID" ]; then
    echo "docker exec $CONTAINER_ID ls -lh /app/dist/assets/"
    echo ""
    echo "Проверьте прямые ссылки на фотографии:"
    echo "https://ваш-домен.ru/assets/hero-photo-v4.png"
    echo "https://ваш-домен.ru/assets/about-photo-v4.png"
    echo "https://ваш-домен.ru/assets/sea-photo-v4.png"
else
    echo "Контейнер не запущен. Проверьте логи:"
    echo "docker compose logs"
fi

echo ""
echo "[INFO] Если фотографии всё ещё старые:"
echo "1. Очистите кэш браузера (Ctrl+F5)"
echo "2. Очистите Cloudflare кэш через Dashboard"
echo "3. Проверьте headers: curl -I https://ваш-домен.ru/assets/hero-photo-v4.png"