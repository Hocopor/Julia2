# Полная автоматизация деплоя через Cloudflare Tunnel для Windows
# Использование: .\auto-deploy-cloudflare.ps1

Write-Host "🚀 Полная автоматизация деплоя через Cloudflare Tunnel..." -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Cyan

# Проверяем наличие .env файла
if (-not (Test-Path .env)) {
    Write-Host "❌ Файл .env не найден." -ForegroundColor Red
    Write-Host ""
    Write-Host "Создайте .env файл:" -ForegroundColor Yellow
    Write-Host "Copy-Item .env.example .env" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Заполните следующие переменные в .env:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. CLOUDFLARE_TUNNEL_TOKEN - токен туннеля" -ForegroundColor White
    Write-Host "   Получить: Cloudflare Dashboard → Zero Trust → Access → Tunnels → Create tunnel" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. CLOUDFLARE_DOMAIN - ваш домен (например: example.com)" -ForegroundColor White
    Write-Host ""
    Write-Host "3. (Опционально) Для автоматической настройки DNS:" -ForegroundColor White
    Write-Host "   CLOUDFLARE_API_TOKEN - API токен Cloudflare" -ForegroundColor Gray
    Write-Host "   CLOUDFLARE_ACCOUNT_ID - ID аккаунта Cloudflare" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Получить API токен:" -ForegroundColor White
    Write-Host "Cloudflare Dashboard → My Profile → API Tokens → Create Token" -ForegroundColor Gray
    Write-Host "Используйте шаблон: 'Edit zone DNS'" -ForegroundColor Gray
    exit 1
}

# Загружаем переменные из .env
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]+)=(.*)') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

# Проверяем обязательные переменные
$MISSING_VARS = @()
if (-not $env:CLOUDFLARE_TUNNEL_TOKEN) { $MISSING_VARS += "CLOUDFLARE_TUNNEL_TOKEN" }
if (-not $env:CLOUDFLARE_DOMAIN) { $MISSING_VARS += "CLOUDFLARE_DOMAIN" }

if ($MISSING_VARS.Count -gt 0) {
    Write-Host "❌ Отсутствуют обязательные переменные в .env:" -ForegroundColor Red
    foreach ($var in $MISSING_VARS) {
        Write-Host "   - $var" -ForegroundColor Yellow
    }
    exit 1
}

# Устанавливаем значения по умолчанию
$TUNNEL_NAME = if ($env:CLOUDFLARE_TUNNEL_NAME) { $env:CLOUDFLARE_TUNNEL_NAME } else { "julia2-site" }
$HAS_API_ACCESS = $false

if ($env:CLOUDFLARE_API_TOKEN -and $env:CLOUDFLARE_ACCOUNT_ID) {
    $HAS_API_ACCESS = $true
    Write-Host "✅ Обнаружен API доступ к Cloudflare" -ForegroundColor Green
} else {
    Write-Host "ℹ️  API доступ не настроен. DNS нужно настроить вручную." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Конфигурация:" -ForegroundColor Cyan
Write-Host "   • Домен: $($env:CLOUDFLARE_DOMAIN)" -ForegroundColor White
Write-Host "   • Имя туннеля: $TUNNEL_NAME" -ForegroundColor White
Write-Host "   • Автоматическая настройка DNS: $HAS_API_ACCESS" -ForegroundColor White
Write-Host ""

# Проверяем Docker
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker установлен: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker не установлен" -ForegroundColor Red
    Write-Host "Установите Docker Desktop: https://docs.docker.com/desktop/install/windows-install/" -ForegroundColor Yellow
    exit 1
}

# Проверяем Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "✅ Docker Compose установлен: $composeVersion" -ForegroundColor Green
} catch {
    try {
        $composeVersion = docker compose version
        Write-Host "✅ Docker Compose (новый формат) установлен" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker Compose не установлен" -ForegroundColor Red
        Write-Host "Установите Docker Compose: https://docs.docker.com/compose/install/" -ForegroundColor Yellow
        exit 1
    }
}

# Собираем проект
Write-Host ""
Write-Host "📦 Собираем проект..." -ForegroundColor Yellow
npm run build

# Запускаем Docker Compose
Write-Host ""
Write-Host "🚀 Запускаем Docker Compose..." -ForegroundColor Yellow

if ($HAS_API_ACCESS) {
    Write-Host "Используем автоматическую настройку DNS..." -ForegroundColor Cyan
    docker-compose -f docker-compose-cloudflare.yml up -d
} else {
    Write-Host "Используем базовую конфигурацию..." -ForegroundColor Cyan
    docker-compose up -d
}

Write-Host ""
Write-Host "⏳ Ожидаем запуска (40 секунд)..." -ForegroundColor Yellow
Start-Sleep -Seconds 40

# Проверяем статус
Write-Host ""
Write-Host "📊 Статус контейнеров:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "📝 Логи Cloudflare Tunnel:" -ForegroundColor Cyan
docker-compose logs --tail=10 cloudflared

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "🎉 Деплой запущен!" -ForegroundColor Green
Write-Host ""

if ($HAS_API_ACCESS) {
    Write-Host "✅ DNS настроены автоматически через Cloudflare API" -ForegroundColor Green
    Write-Host "⏱️  Подождите 5-30 минут для распространения DNS" -ForegroundColor Yellow
} else {
    Write-Host "📋 Ручная настройка DNS:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Перейдите в Cloudflare Dashboard:" -ForegroundColor White
    Write-Host "   https://dash.cloudflare.com" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Zero Trust → Access → Tunnels" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Выберите туннель: '$TUNNEL_NAME'" -ForegroundColor White
    Write-Host ""
    Write-Host "4. Нажмите 'Configure' → 'Public Hostname'" -ForegroundColor White
    Write-Host ""
    Write-Host "5. Добавьте новую запись:" -ForegroundColor White
    Write-Host "   • Hostname: $($env:CLOUDFLARE_DOMAIN)" -ForegroundColor Gray
    Write-Host "   • Service: http://app:4173" -ForegroundColor Gray
    Write-Host "   • (Опционально) www.$($env:CLOUDFLARE_DOMAIN)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6. Сохраните и подождите 5-30 минут" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Проверьте работу:" -ForegroundColor Cyan
Write-Host "   https://$($env:CLOUDFLARE_DOMAIN)" -ForegroundColor Gray
Write-Host ""
Write-Host "🛠️  Управление:" -ForegroundColor Cyan
Write-Host "   • Логи: docker-compose logs -f" -ForegroundColor Gray
Write-Host "   • Остановка: docker-compose down" -ForegroundColor Gray
Write-Host "   • Перезапуск: docker-compose restart" -ForegroundColor Gray
Write-Host "   • Обновление: docker-compose pull && docker-compose up -d" -ForegroundColor Gray
Write-Host ""
Write-Host "📁 Файлы конфигурации:" -ForegroundColor Cyan
Write-Host "   • docker-compose.yml - базовая конфигурация" -ForegroundColor Gray
Write-Host "   • docker-compose-cloudflare.yml - с автоматической настройкой DNS" -ForegroundColor Gray
Write-Host "   • Dockerfile - сборка приложения" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Для отладки:" -ForegroundColor Cyan
Write-Host "   docker-compose logs cloudflared" -ForegroundColor Gray
Write-Host "   docker-compose exec app sh" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan