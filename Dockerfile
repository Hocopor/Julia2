# Этап сборки
FROM node:22-alpine AS builder

WORKDIR /app

# Копируем package.json и package-lock.json
COPY package*.json ./

# Устанавливаем зависимости
RUN npm ci --only=production

# Копируем исходный код
COPY . .

# Собираем приложение
RUN npm run build

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