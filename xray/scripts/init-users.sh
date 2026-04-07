#!/bin/bash
set -e

USERS_DIR="/xray/data/users"
XRAY_API_SERVER="127.0.0.1:10085"

if [ -d "$USERS_DIR" ]; then
    cd "$USERS_DIR"
    shopt -s nullglob
    for file in *.json; do
        xray api adu --server="$XRAY_API_SERVER" "$USERS_DIR/$file"
        echo "✅ Successfully added user from $file"
    done
    shopt -u nullglob

else
    echo "Directory $USERS_DIR does not exist. Skipping."
fi
