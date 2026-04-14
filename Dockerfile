# Этап сборки
FROM node:22-alpine AS builder

WORKDIR /app

# ARG для переменных сборки
ARG VITE_CTA_URL
ARG VITE_WHATSAPP_URL
ARG VITE_TELEGRAM_URL
ARG VITE_DEVELOPED_BY_URL

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm ci

# Копируем исходный код
COPY . .

# Собираем приложение с переменными окружения
RUN VITE_CTA_URL=${VITE_CTA_URL} \
    VITE_WHATSAPP_URL=${VITE_WHATSAPP_URL} \
    VITE_TELEGRAM_URL=${VITE_TELEGRAM_URL} \
    VITE_DEVELOPED_BY_URL=${VITE_DEVELOPED_BY_URL} \
    npm run build

# Этап запуска
FROM node:22-alpine AS runner

WORKDIR /app

# Устанавливаем serve для статики (альтернатива vite preview)
RUN npm install -g serve

# Копируем собранное приложение из builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Устанавливаем только production зависимости для preview
RUN npm ci --only=production

# Копируем исходный код для dev режима (опционально)
COPY . .

# Экспортируем порт
EXPOSE 4173

# Запускаем preview сервер
CMD ["npm", "run", "preview"]

# Альтернатива: использовать serve для статики
# CMD ["serve", "-s", "dist", "-l", "4173"]