#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <pem_private_key_path>"
  exit 1
fi

PEM_PATH="$1"

if [[ ! -f "$PEM_PATH" ]]; then
  echo "PEM file not found: $PEM_PATH"
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required"
  exit 1
fi

if ! command -v xxd >/dev/null 2>&1; then
  echo "xxd is required"
  exit 1
fi

HEX_HASH=$(
  openssl pkey -in "$PEM_PATH" -pubout -outform DER |
    openssl dgst -sha256 -binary |
    xxd -p -c 256 |
    cut -c 1-32
)

EXTENSION_ID=$(echo "$HEX_HASH" | tr '0123456789abcdef' 'abcdefghijklmnop')

echo "$EXTENSION_ID"
