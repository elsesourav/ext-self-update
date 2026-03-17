# Self Update Test Extension (Windows + macOS Managed Chrome)

This repository is now pre-wired for your GitHub project:

- Repo: https://github.com/elsesourav/ext-self-update
- Extension ID: jngcnbojdjmlecbcmkdbfinkhienmpmm
- Update manifest URL used by Chrome: https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml

For client machines with only terminal access (no local repo files), use SETUP.md.

## Important Limitation

Automatic off-store updates on Windows and macOS require managed Chrome policy.
For unmanaged consumer devices, full automatic off-store update is not supported.

## Already Configured

- manifest.json contains:
  - fixed key (for stable extension ID)
  - update_url pointing to your GitHub raw updates.xml
- artifacts/updates.xml is created for version 1.0.0.
- policy templates exist for both macOS and Windows.
- scripts are provided for both bash and PowerShell.

## Project Files

- SETUP.md
- manifest.json
- background.js
- popup.html
- popup.js
- popup.css
- artifacts/updates.xml
- artifacts/updates.xml.template
- scripts/package-extension.sh
- scripts/package-extension.ps1
- scripts/extension-id-from-pem.sh
- scripts/extension-id-from-pem.ps1
- scripts/generate-updates-xml.sh
- scripts/generate-updates-xml.ps1
- policy/com.google.Chrome.plist.template
- policy/macos/install-first-time-client.sh
- policy/windows/chrome-force-install.reg.template
- policy/windows/install-first-time-client.ps1
- policy/windows/set-force-install-policy.ps1

## Signing Key

A local signing key is used at .local/ext-self-update.pem.
This directory is gitignored.

Do not delete or rotate this key unless you intentionally want a new extension ID.

## macOS Build + Release

1. Package CRX using the same PEM key:

```bash
./scripts/package-extension.sh "$PWD" ".local/ext-self-update.pem"
```

2. Upload the generated CRX as release asset named ext-self-update.crx under tag v1.0.0:

https://github.com/elsesourav/ext-self-update/releases/tag/v1.0.0

3. Commit and push artifacts/updates.xml so the raw URL serves the latest manifest.

## Windows Build + Release

1. Package CRX in PowerShell:

```powershell
.\scripts\package-extension.ps1 -ExtensionDir (Get-Location).Path -PemKeyPath ".\.local\ext-self-update.pem"
```

2. Upload ext-self-update.crx to the matching GitHub release tag.

3. Commit and push artifacts/updates.xml after each version change.

## Generate updates.xml For New Version

Example for v1.0.1:

### bash

```bash
./scripts/generate-updates-xml.sh \
  "jngcnbojdjmlecbcmkdbfinkhienmpmm" \
  "1.0.1" \
  "https://github.com/elsesourav/ext-self-update/releases/download/v1.0.1/ext-self-update.crx" \
  "artifacts/updates.xml"
```

### PowerShell

```powershell
.\scripts\generate-updates-xml.ps1 -ExtensionId "jngcnbojdjmlecbcmkdbfinkhienmpmm" -Version "1.0.1" -CodebaseUrl "https://github.com/elsesourav/ext-self-update/releases/download/v1.0.1/ext-self-update.crx" -OutputPath "artifacts/updates.xml"
```

Then bump manifest.json version to the same value and publish both CRX + updates.xml.

## First-Time Client Setup (One Command)

Use these commands directly on client machines.

### macOS (local repo)

```bash
sudo bash policy/macos/install-first-time-client.sh
```

### macOS (without cloning repo)

```bash
curl -fsSL https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/install-first-time-client.sh | sudo bash
```

### Windows (local repo, Administrator PowerShell)

```powershell
.\policy\windows\install-first-time-client.ps1
```

### Windows (without cloning repo, Administrator PowerShell)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/install-first-time-client.ps1 -UseBasicParsing | iex"
```

After running the command on the client:

1. Open chrome://policy and click Reload policies.
2. Open chrome://extensions and confirm the extension is installed.

## Managed Policy Setup (Manual Options)

### macOS

Use policy/com.google.Chrome.plist.template through MDM or managed preferences.

Verify in:

- chrome://policy
- chrome://extensions

### Windows

Option A: import policy/windows/chrome-force-install.reg.template as admin.

Option B: run policy/windows/set-force-install-policy.ps1:

```powershell
.\policy\windows\set-force-install-policy.ps1 -PolicyHive HKLM
```

Use HKCU for current-user lab testing if you do not have admin rights.

## Update Flow (All Platforms)

1. Bump version in manifest.json.
2. Package CRX with the same PEM key.
3. Upload CRX to matching GitHub release tag.
4. Regenerate artifacts/updates.xml with same version and new release URL.
5. Commit and push updates.xml.
6. On client Chrome, force check from chrome://extensions (Developer mode > Update) for quick testing.

## Private Collaboration Note

If this repository becomes private, Chrome update checks may not be able to access private release assets.
In that case, keep source private but host updates.xml and CRX on a public or internal unauthenticated endpoint reachable by managed devices.

## Security Notes

- Never commit PEM keys.
- Keep .local/ext-self-update.pem in secure backup.
- Signed CRX files are deployable release artifacts.
