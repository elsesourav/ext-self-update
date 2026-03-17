#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${EXT_SELF_UPDATE_REPO_URL:-https://github.com/elsesourav/ext-self-update.git}"
REPO_BRANCH="${EXT_SELF_UPDATE_REPO_BRANCH:-main}"
REPO_DIR="${EXT_SELF_UPDATE_REPO_DIR:-$HOME/ext-self-update-unpacked}"

safe_clear_repo_dir() {
  local target="$1"

  if [[ -z "$target" || "$target" == "/" || "$target" == "$HOME" ]]; then
    echo "Refusing to remove unsafe path: $target"
    exit 1
  fi

  rm -rf "$target"
}

if ! command -v git >/dev/null 2>&1; then
  echo "git is required but not installed"
  exit 1
fi

mkdir -p "$(dirname "$REPO_DIR")"

changed="0"

if [[ ! -d "$REPO_DIR" ]]; then
  git clone --branch "$REPO_BRANCH" --single-branch "$REPO_URL" "$REPO_DIR" >/dev/null 2>&1
  changed="1"
else
  if [[ ! -d "$REPO_DIR/.git" ]]; then
    safe_clear_repo_dir "$REPO_DIR"
    git clone --branch "$REPO_BRANCH" --single-branch "$REPO_URL" "$REPO_DIR" >/dev/null 2>&1
    changed="1"
  else
    before="$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo "")"
    had_local_changes="0"

    if [[ -n "$(git -C "$REPO_DIR" status --porcelain)" ]]; then
      had_local_changes="1"
    fi

    git -C "$REPO_DIR" remote set-url origin "$REPO_URL"
    git -C "$REPO_DIR" fetch origin "$REPO_BRANCH" --quiet
    # Force local folder to exactly match current remote branch state.
    git -C "$REPO_DIR" reset --hard "origin/$REPO_BRANCH" --quiet
    git -C "$REPO_DIR" clean -fdx -q
    after="$(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo "")"

    if [[ "$before" != "$after" || "$had_local_changes" == "1" ]]; then
      changed="1"
    fi
  fi
fi

manifest_version="unknown"
if [[ -f "$REPO_DIR/manifest.json" ]]; then
  manifest_version="$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$REPO_DIR/manifest.json" | head -n 1)"
  if [[ -z "$manifest_version" ]]; then
    manifest_version="unknown"
  fi
fi

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
if [[ "$changed" == "1" ]]; then
  echo "$timestamp synced update; version=$manifest_version; repo=$REPO_DIR"
else
  echo "$timestamp no change; version=$manifest_version; repo=$REPO_DIR"
fi

echo "$timestamp|$manifest_version|$changed" >"$REPO_DIR/.sync-state"
