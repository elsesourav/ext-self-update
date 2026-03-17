# Self Update Test Extension (Unmanaged Auto-Sync)

This project now uses an unmanaged client update flow only.

- Clients auto-sync extension files from GitHub every 15 minutes.
- Clients manually click Reload in chrome://extensions to apply updates.
- Old local files and local edits are removed on each sync (clean-sync).

Repo:

- https://github.com/elsesourav/ext-self-update

Use SETUP.md for full client instructions.

## Quick Install (Client)

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/install-unmanaged-auto-sync.sh | bash
```

### Windows (PowerShell)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/install-unmanaged-auto-sync.ps1 -UseBasicParsing | iex"
```

After first sync:

1. Open chrome://extensions
2. Enable Developer mode
3. Click Load unpacked
4. Select:
   - macOS: ~/ext-self-update-unpacked
   - Windows: %USERPROFILE%\\ext-self-update-unpacked

## Update Behavior

1. Sync runs every 15 minutes.
2. Sync force-resets local folder to current GitHub branch state.
3. User clicks Reload on extension card to apply code.

## Project Files

- SETUP.md
- manifest.json
- background.js
- popup.html
- popup.js
- popup.css
- policy/macos/install-unmanaged-auto-sync.sh
- policy/macos/sync-unmanaged-unpacked.sh
- policy/macos/uninstall-unmanaged-auto-sync.sh
- policy/windows/install-unmanaged-auto-sync.ps1
- policy/windows/sync-unmanaged-unpacked.ps1
- policy/windows/uninstall-unmanaged-auto-sync.ps1

## Maintainer Notes

- Push changes to main branch to distribute new code.
- Clients pull updates automatically via scheduler.
- Clients apply updates manually with Reload in chrome://extensions.
