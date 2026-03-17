#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <extension_dir> [pem_key_path] [chrome_binary_path]"
  exit 1
fi

EXTENSION_DIR="$1"
PEM_KEY_PATH="${2:-}"
CHROME_BIN="${3:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"

if [[ ! -d "$EXTENSION_DIR" ]]; then
  echo "Extension directory not found: $EXTENSION_DIR"
  exit 1
fi

if [[ ! -x "$CHROME_BIN" ]]; then
  echo "Chrome binary not found or not executable: $CHROME_BIN"
  exit 1
fi

CMD=("$CHROME_BIN" "--pack-extension=$EXTENSION_DIR")

if [[ -n "$PEM_KEY_PATH" ]]; then
  if [[ ! -f "$PEM_KEY_PATH" ]]; then
    echo "PEM key not found: $PEM_KEY_PATH"
    exit 1
  fi
  CMD+=("--pack-extension-key=$PEM_KEY_PATH")
fi

echo "Packing extension from: $EXTENSION_DIR"
if [[ -n "$PEM_KEY_PATH" ]]; then
  echo "Using existing key: $PEM_KEY_PATH"
else
  echo "No key provided. Chrome will generate a new .pem key. Keep it safe for future updates."
fi

"${CMD[@]}"

echo "Pack complete. Chrome writes .crx and possibly .pem next to the extension directory."
