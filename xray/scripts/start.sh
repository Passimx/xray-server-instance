#!/bin/bash

set -e

TMP_CONFIG="/tmp/config.json"
PRIVATE_KEY_FILE="/etc/xray/private.key"
SHORT_ID_FILE="/etc/xray/short_id.key"
SERVER_NAME_FILE="/etc/xray/server.name"
PORT_FILE="/etc/xray/server.port"

# === XRAY_PORT INIT ===
XRAY_PORT=${XRAY_PORT:-443}
mkdir -p "$(dirname "$PORT_FILE")"
echo "$XRAY_PORT" > "$PORT_FILE"

cd /etc/xray/scripts
bash ./init-short-id.sh
bash ./init-server-name.sh
bash ./init-keys.sh
bash ./init-config.sh

PRIVATE_KEY=$(tr -d '\n' < "$PRIVATE_KEY_FILE")
SHORT_ID=$(tr -d '\n' < "$SHORT_ID_FILE")
SERVER_NAME=$(tr -d '\n' < "$SERVER_NAME_FILE")

# === CONFIG GENERATION ===
sed -e "s/\"XRAY_PORT\"/$XRAY_PORT/g" \
    -e "s/\"PRIVATE_KEY\"/\"$PRIVATE_KEY\"/g" \
    -e "s/\"SHORT_ID\"/\"$SHORT_ID\"/g" \
    -e "s/SERVER_NAME/$SERVER_NAME/g" \
    /etc/xray/config.json > $TMP_CONFIG

xray -config $TMP_CONFIG &
XRAY_PID=$!

sleep 3

echo "Starting NestJS..."
node /app/dist/src/main &
#NODE_PID=$!

sleep 2

wait $XRAY_PID
#wait $NODE_PID