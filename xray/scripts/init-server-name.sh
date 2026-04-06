#!/bin/sh
set -e

SERVER_NAME_FILE="/xray/data/server.name"

if [ ! -f "$SERVER_NAME_FILE" ] || [ ! -s "$SERVER_NAME_FILE" ]; then
  echo "Generating SERVER_NAME..."

  SERVER_NAME=www.cloudflare.com
  echo "$SERVER_NAME" > "$SERVER_NAME_FILE"

  echo "✅ SERVER_NAME generated: $SERVER_NAME"
fi