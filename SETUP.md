# Client Setup (Unmanaged Auto-Sync + Manual Reload)

This guide is for client machines that do not have this repository cloned.
Everything is done from terminal commands only.

## What This Setup Does

- Downloads extension code from GitHub to a local unpacked folder.
- Runs background sync every 15 minutes.
- Force-cleans local folder to match current GitHub branch exactly.
- Leaves reload manual in Chrome (`Reload` button on extension card).

Important:

- Any local file edits inside the unpacked extension folder are deleted on sync.

## Requirements

- Google Chrome installed
- Git installed
- Network access to:
  - raw.githubusercontent.com
  - github.com

## One-Command Install

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/install-unmanaged-auto-sync.sh | bash
```

### Windows (PowerShell)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/install-unmanaged-auto-sync.ps1 -UseBasicParsing | iex"
```

## Safer Install (Download, Review, Then Run)

### macOS

```bash
curl -fsSL -o /tmp/ext-self-update-install-unmanaged.sh https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/install-unmanaged-auto-sync.sh
cat /tmp/ext-self-update-install-unmanaged.sh
bash /tmp/ext-self-update-install-unmanaged.sh
rm -f /tmp/ext-self-update-install-unmanaged.sh
```

### Windows

```powershell
$url = "https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/install-unmanaged-auto-sync.ps1"
$path = "$env:TEMP\ext-self-update-install-unmanaged-auto-sync.ps1"
iwr $url -OutFile $path -UseBasicParsing
Get-Content $path
powershell -NoProfile -ExecutionPolicy Bypass -File $path
Remove-Item $path -Force
```

## First Load In Chrome

1. Open `chrome://extensions`
2. Enable `Developer mode`
3. Click `Load unpacked`
4. Select:
   - macOS: `~/ext-self-update-unpacked`
   - Windows: `%USERPROFILE%\ext-self-update-unpacked`

## Apply Updates (Manual Reload)

1. Wait for scheduler (15 minutes), or force sync now:

### macOS

```bash
bash "$HOME/.ext-self-update/sync-unmanaged-unpacked.sh"
```

### Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.ext-self-update\sync-unmanaged-unpacked.ps1"
```

2. Open `chrome://extensions`
3. Click `Reload` for the extension

## Check Sync Logs

### macOS

```bash
tail -n 50 "$HOME/.ext-self-update/sync.log"
```

### Windows

```powershell
Get-Content "$env:USERPROFILE\.ext-self-update\sync.log" -Tail 50
```

## Disable Auto-Sync

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/uninstall-unmanaged-auto-sync.sh | bash
```

### Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/uninstall-unmanaged-auto-sync.ps1 -UseBasicParsing | iex"
```

## Troubleshooting

### Sync script says git missing

Install git and run installer again.

### Chrome extension does not update

1. Force sync with command above
2. Check logs
3. Click `Reload` in `chrome://extensions`

### Unexpected local changes disappeared

This is expected in clean-sync mode.
The folder is reset to GitHub branch state on each sync.
