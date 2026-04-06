#!/bin/bash
set -e

SHORT_ID_FILE="/xray/data/short_id.key"

if [ ! -f "$SHORT_ID_FILE" ] || [ ! -s "$SHORT_ID_FILE" ]; then
  echo "Generating SHORT_ID..."

  SHORT_ID=$(openssl rand -hex 8)
  echo "$SHORT_ID" > "$SHORT_ID_FILE"

  echo "✅ SHORT_ID generated: $SHORT_ID"
fi