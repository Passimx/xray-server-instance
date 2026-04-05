#!/bin/bash
set -e

CONFIG_FILE="/etc/xray/config.json"
PRIVATE_KEY_FILE="/etc/xray/private.key"
SHORT_ID_FILE="/etc/xray/short_id.key"
SERVER_NAME_FILE="/etc/xray/server.name"
PORT_FILE="/etc/xray/server.port"

# Проверяем, существует ли конфиг. Если нет — создаем.
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config not found. Creating $CONFIG_FILE..."

    # Читаем значения из файлов (удаляя лишние пробелы и переносы)
    # Если файлов нет, можно добавить значения по умолчанию
    PRIVATE_KEY=$(cat "$PRIVATE_KEY_FILE" | tr -d '\n')
    SHORT_ID=$(cat "$SHORT_ID_FILE" | tr -d '\n')
    SERVER_NAME=$(cat "$SERVER_NAME_FILE" | tr -d '\n')
    XRAY_PORT=$(cat "$PORT_FILE" | tr -d '\n')

    # Создаем директорию для конфига, если её нет
    mkdir -p "$(dirname "$CONFIG_FILE")"
    # Создаем директорию для логов
    mkdir -p /var/log/xray

    # Записываем JSON в файл
    cat <<EOF > "$CONFIG_FILE"
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
  },
  "api": {
    "tag": "api",
    "services": ["HandlerService", "StatsService"]
  },
  "stats": {},
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true,
        "statsUserOnline": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true
    }
  },
  "inbounds": [
    {
      "port": $XRAY_PORT,
      "protocol": "vless",
      "settings": {
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$SERVER_NAME:443",
          "xver": 0,
          "serverNames": [
            "$SERVER_NAME"
          ],
          "privateKey": "$PRIVATE_KEY",
          "shortIds": [
            "$SHORT_ID"
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls", "quic"],
        "metadataOnly": false
      },
      "tag": "vless-in"
    },
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "freedom",
      "tag": "api"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "inboundTag": ["api"],
        "outboundTag": "api"
      }
    ]
  }
}
EOF

    echo "✅ Config created successfully."
else
    echo "Config already exists. Skipping creation."
fi
