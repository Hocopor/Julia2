#!/usr/bin/env sh

set -eu

if [ -f .env ]; then
  set -a
  . ./.env
  set +a
fi

APP_PORT="${APP_PORT:-4180}"
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-julia2}"

echo "==> Deploying ${PROJECT_NAME} on localhost:${APP_PORT}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed." >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  DOCKER_COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  DOCKER_COMPOSE="docker-compose"
else
  echo "Docker Compose is not available." >&2
  exit 1
fi

$DOCKER_COMPOSE down --remove-orphans

if command -v ss >/dev/null 2>&1; then
  if ss -ltn | grep -Eq "[.:]${APP_PORT}[[:space:]]"; then
    echo "Port ${APP_PORT} is already in use. Pick another APP_PORT in .env." >&2
    exit 1
  fi
fi

$DOCKER_COMPOSE up -d --build
$DOCKER_COMPOSE ps

echo "==> App is published only on 127.0.0.1:${APP_PORT}"
echo "==> Connect your reverse proxy to that local port"
