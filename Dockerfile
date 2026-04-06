# --- ЭТАП 1: Сборка NestJS ---
FROM node:20-slim AS build
WORKDIR /app
COPY . .
#RUN npm ci --ignore-scripts
RUN npm run build
RUN npm prune --omit=dev

FROM node:20-slim
RUN apt-get update && apt-get install -y \
    curl bash jq ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=teddysun/xray:24.12.18 /usr/bin/xray /usr/bin/xray
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/package*.json /app/
COPY --from=build /app/dist /app/dist
COPY ./xray/scripts /xray/scripts

RUN chmod -R 755 /xray/scripts
RUN sed -i 's/\r$//' /xray/scripts/*.sh

EXPOSE 6020
CMD ["/bin/bash", "/xray/scripts/start.sh"]