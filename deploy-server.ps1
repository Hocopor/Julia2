$ErrorActionPreference = "Stop"

if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^\s*#' -or $_ -match '^\s*$') {
            return
        }

        $parts = $_ -split '=', 2
        if ($parts.Length -eq 2) {
            [System.Environment]::SetEnvironmentVariable($parts[0], $parts[1])
        }
    }
}

$appPort = if ($env:APP_PORT) { $env:APP_PORT } else { "4180" }
$projectName = if ($env:COMPOSE_PROJECT_NAME) { $env:COMPOSE_PROJECT_NAME } else { "julia2" }

Write-Host "==> Deploying $projectName on localhost:$appPort"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed."
}

docker compose down --remove-orphans

$existingPort = Get-NetTCPConnection -State Listen -LocalPort $appPort -ErrorAction SilentlyContinue
if ($existingPort) {
    throw "Port $appPort is already in use. Pick another APP_PORT in .env."
}

docker compose up -d --build
docker compose ps

Write-Host "==> App is published only on 127.0.0.1:$appPort"
Write-Host "==> Connect your reverse proxy to that local port"
