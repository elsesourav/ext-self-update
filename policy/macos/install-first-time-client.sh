#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root: sudo bash policy/macos/install-first-time-client.sh"
  exit 1
fi

EXTENSION_ID="jngcnbojdjmlecbcmkdbfinkhienmpmm"
UPDATE_URL="https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml"
POLICY_PATH="/Library/Managed Preferences/com.google.Chrome.plist"

mkdir -p "/Library/Managed Preferences"

cat >"$POLICY_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>ExtensionInstallForcelist</key>
    <array>
      <string>${EXTENSION_ID};${UPDATE_URL}</string>
    </array>
  </dict>
</plist>
EOF

chown root:wheel "$POLICY_PATH"
chmod 644 "$POLICY_PATH"
plutil -lint "$POLICY_PATH" >/dev/null

killall "Google Chrome" >/dev/null 2>&1 || true

echo "Policy installed: $POLICY_PATH"
echo "ExtensionInstallForcelist set for ${EXTENSION_ID}"
echo "Open Chrome and verify at chrome://policy then chrome://extensions"
