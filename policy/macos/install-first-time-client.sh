#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -ne 0 ]]; then
  echo "Run as root: sudo bash policy/macos/install-first-time-client.sh"
  exit 1
fi

EXTENSION_ID="jngcnbojdjmlecbcmkdbfinkhienmpmm"
UPDATE_URL="https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml"
POLICY_PATH_MACHINE="/Library/Managed Preferences/com.google.Chrome.plist"
TARGET_USER="${SUDO_USER:-$(stat -f%Su /dev/console 2>/dev/null || true)}"

if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
  echo "Could not determine a non-root console user; policy will be written only at machine scope."
fi

write_policy() {
  local policy_path="$1"

  mkdir -p "$(dirname "$policy_path")"

  cat >"$policy_path" <<EOF
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

  chown root:wheel "$policy_path"
  chmod 644 "$policy_path"
  plutil -lint "$policy_path" >/dev/null
}

write_policy "$POLICY_PATH_MACHINE"

POLICY_PATH_USER=""
if [[ -n "$TARGET_USER" && "$TARGET_USER" != "root" ]]; then
  POLICY_PATH_USER="/Library/Managed Preferences/${TARGET_USER}/com.google.Chrome.plist"
  write_policy "$POLICY_PATH_USER"
fi

# Refresh both system and user preference daemons so Chrome sees the updated managed keys.
killall cfprefsd >/dev/null 2>&1 || true

if [[ -n "$TARGET_USER" && "$TARGET_USER" != "root" ]]; then
  launchctl asuser "$(id -u "$TARGET_USER")" killall cfprefsd >/dev/null 2>&1 || true
fi

killall "Google Chrome" >/dev/null 2>&1 || true
killall "Google Chrome Helper" >/dev/null 2>&1 || true

echo "Machine policy installed: $POLICY_PATH_MACHINE"

if [[ -n "$POLICY_PATH_USER" ]]; then
  echo "User policy installed: $POLICY_PATH_USER"
fi

echo "ExtensionInstallForcelist set for ${EXTENSION_ID}"
echo "Open Chrome, then check chrome://policy (Reload policies) and chrome://extensions"
