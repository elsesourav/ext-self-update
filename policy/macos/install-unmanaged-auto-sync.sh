#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
  echo "Run without sudo. This installs a user-level LaunchAgent."
  echo "Example: bash policy/macos/install-unmanaged-auto-sync.sh"
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required but not installed"
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but not installed"
  exit 1
fi

SYNC_SCRIPT_SOURCE_URL="${EXT_SELF_UPDATE_SYNC_SCRIPT_URL:-https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/sync-unmanaged-unpacked.sh}"
BASE_DIR="${EXT_SELF_UPDATE_BASE_DIR:-$HOME/.ext-self-update}"
SYNC_SCRIPT_PATH="$BASE_DIR/sync-unmanaged-unpacked.sh"
LOG_PATH="$BASE_DIR/sync.log"
AGENT_LABEL="com.elsesourav.extselfupdate.unmanagedsync"
AGENT_PATH="$HOME/Library/LaunchAgents/${AGENT_LABEL}.plist"
UID_VALUE="$(id -u)"

mkdir -p "$BASE_DIR" "$HOME/Library/LaunchAgents"

curl -fsSL "$SYNC_SCRIPT_SOURCE_URL" -o "$SYNC_SCRIPT_PATH"
chmod +x "$SYNC_SCRIPT_PATH"

"$SYNC_SCRIPT_PATH" >>"$LOG_PATH" 2>&1 || true

cat >"$AGENT_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>${AGENT_LABEL}</string>
    <key>ProgramArguments</key>
    <array>
      <string>/bin/bash</string>
      <string>${SYNC_SCRIPT_PATH}</string>
    </array>
    <key>StartInterval</key>
    <integer>900</integer>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>${LOG_PATH}</string>
    <key>StandardErrorPath</key>
    <string>${LOG_PATH}</string>
  </dict>
</plist>
EOF

launchctl bootout "gui/${UID_VALUE}" "$AGENT_PATH" >/dev/null 2>&1 || true
if ! launchctl bootstrap "gui/${UID_VALUE}" "$AGENT_PATH" >/dev/null 2>&1; then
  launchctl unload "$AGENT_PATH" >/dev/null 2>&1 || true
  launchctl load "$AGENT_PATH"
fi

launchctl kickstart -k "gui/${UID_VALUE}/${AGENT_LABEL}" >/dev/null 2>&1 || true

echo "Installed unmanaged auto-sync"
echo "Repo sync script: $SYNC_SCRIPT_PATH"
echo "Log file: $LOG_PATH"
echo "Unpacked extension folder: $HOME/ext-self-update-unpacked"
echo ""
echo "Next steps:"
echo "1) Open chrome://extensions"
echo "2) Enable Developer mode"
echo "3) Load unpacked -> $HOME/ext-self-update-unpacked"
echo "4) After future syncs, click Reload on the extension card"
