FROM node:22-alpine AS builder

WORKDIR /app

ARG VITE_CTA_URL
ARG VITE_WHATSAPP_URL
ARG VITE_TELEGRAM_URL
ARG VITE_VK_URL
ARG VITE_DEVELOPED_BY_URL
ARG VITE_BASE_PATH

COPY package*.json ./
RUN npm ci

COPY . .

RUN VITE_CTA_URL=${VITE_CTA_URL} \
    VITE_WHATSAPP_URL=${VITE_WHATSAPP_URL} \
    VITE_TELEGRAM_URL=${VITE_TELEGRAM_URL} \
    VITE_VK_URL=${VITE_VK_URL} \
    VITE_DEVELOPED_BY_URL=${VITE_DEVELOPED_BY_URL} \
    VITE_BASE_PATH=${VITE_BASE_PATH:-/} \
    npm run build

FROM nginxinc/nginx-unprivileged:1.29-alpine AS runner

WORKDIR /usr/share/nginx/html

COPY docker/nginx/site.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist ./

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
