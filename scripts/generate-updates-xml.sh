#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <extension_id> <version> <codebase_url> <output_path>"
  exit 1
fi

EXTENSION_ID="$1"
VERSION="$2"
CODEBASE_URL="$3"
OUTPUT_PATH="$4"

mkdir -p "$(dirname "$OUTPUT_PATH")"

cat >"$OUTPUT_PATH" <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
  <app appid='$EXTENSION_ID'>
    <updatecheck codebase='$CODEBASE_URL' version='$VERSION' />
  </app>
</gupdate>
EOF

echo "Wrote update manifest to: $OUTPUT_PATH"
