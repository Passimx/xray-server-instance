#!/bin/sh
set -e

PUBLIC_KEY_FILE="/etc/xray/public.key"
PRIVATE_KEY_FILE="/etc/xray/private.key"

mkdir -p /data
touch "$PRIVATE_KEY_FILE" "$PUBLIC_KEY_FILE"

PRIVATE_KEY=$(tr -d '\r\n ' < "$PRIVATE_KEY_FILE")
ACTUAL_PUBLIC=$(tr -d '\r\n ' < "$PUBLIC_KEY_FILE")

if [ -z "$PRIVATE_KEY" ] || [ -z "$ACTUAL_PUBLIC" ]; then
  echo "❌ Keys are empty! Regenerating..."

  KEYS=$(xray x25519)

  PRIVATE_KEY=$(echo "$KEYS" | grep -i "private" | sed 's/.*: *//')
  PUBLIC_KEY=$(echo "$KEYS" | grep -i "public" | sed 's/.*: *//')

  if [ -z "$PRIVATE_KEY" ] || [ -z "$PUBLIC_KEY" ]; then
    echo "❌ Failed to parse keys!"
    echo "$KEYS"
    exit 1
  fi

  printf "%s" "$PRIVATE_KEY" > "$PRIVATE_KEY_FILE"
  printf "%s" "$PUBLIC_KEY" > "$PUBLIC_KEY_FILE"

  echo "✅ Keys regenerated (empty fix)"

else
  echo "Validating key pair..."

  EXPECTED_PUBLIC=$(xray x25519 -i "$PRIVATE_KEY" \
    | grep -i "public" \
    | sed 's/.*: *//' \
    | tr -d '\r\n ')

  if [ -z "$EXPECTED_PUBLIC" ] || [ "$EXPECTED_PUBLIC" != "$ACTUAL_PUBLIC" ]; then
    echo "❌ Key mismatch! Regenerating..."

    KEYS=$(xray x25519)

    PRIVATE_KEY=$(echo "$KEYS" | grep -i "private" | sed 's/.*: *//')
    PUBLIC_KEY=$(echo "$KEYS" | grep -i "public" | sed 's/.*: *//')

    printf "%s" "$PRIVATE_KEY" > "$PRIVATE_KEY_FILE"
    printf "%s" "$PUBLIC_KEY" > "$PUBLIC_KEY_FILE"

    echo "✅ Keys regenerated"
  else
    echo "✅ Keys are valid"
  fi
fi