#!/usr/bin/env bash
set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
  echo "Run without sudo. This removes a user-level LaunchAgent."
  exit 1
fi

BASE_DIR="${EXT_SELF_UPDATE_BASE_DIR:-$HOME/.ext-self-update}"
AGENT_LABEL="com.elsesourav.extselfupdate.unmanagedsync"
AGENT_PATH="$HOME/Library/LaunchAgents/${AGENT_LABEL}.plist"
UID_VALUE="$(id -u)"

launchctl bootout "gui/${UID_VALUE}" "$AGENT_PATH" >/dev/null 2>&1 || true
launchctl disable "gui/${UID_VALUE}/${AGENT_LABEL}" >/dev/null 2>&1 || true
rm -f "$AGENT_PATH"

echo "Removed launch agent: $AGENT_PATH"
echo "Sync files remain at: $BASE_DIR"
echo "If you want full cleanup: rm -rf \"$BASE_DIR\""
