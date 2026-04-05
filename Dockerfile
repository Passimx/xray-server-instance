# --- ЭТАП 1: Сборка NestJS ---
FROM node:20-slim AS build
WORKDIR /app
COPY . .
RUN npm ci --ignore-scripts --omit=dev
RUN npm run build

FROM node:20-slim
RUN apt-get update && apt-get install -y \
    curl bash jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=teddysun/xray:latest /usr/bin/xray /usr/bin/xray
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/package*.json /app/
COPY --from=build /app/dist /app/dist
COPY ./xray/scripts /etc/xray/scripts

RUN chmod -R 755 /etc/xray/scripts
RUN sed -i 's/\r$//' /etc/xray/scripts/*.sh

EXPOSE 6020
CMD ["/bin/bash", "/etc/xray/scripts/start.sh"]
