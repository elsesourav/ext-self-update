# Self Update Test Extension (No Chrome Web Store)

This project is a minimal MV3 extension made for testing self-update flows outside the Chrome Web Store.

## Important Reality Check

- Fully automatic off-store updates on macOS Chrome are practical only for enterprise-managed devices (policy-managed install).
- This repository is set up for that managed flow.
- For unmanaged consumer Chrome, you cannot rely on fully automatic off-store install/update.

## What Is In This Repo

- Minimal extension code (popup + service worker)
- Packaging script for CRX generation
- Script to calculate extension ID from the PEM key
- Script to generate updates.xml

## Files

- manifest.json
- background.js
- popup.html
- popup.js
- popup.css
- scripts/package-extension.sh
- scripts/extension-id-from-pem.sh
- scripts/generate-updates-xml.sh
- artifacts/updates.xml.template
- policy/com.google.Chrome.plist.template

## Prerequisites

- macOS
- Google Chrome installed
- Enterprise policy control for Chrome test devices
- GitHub account
- Public HTTPS endpoint for update artifacts (GitHub Pages or internal static server)

## Private Collaboration + Public Artifacts Pattern

If your source must stay private, use two repositories:

1. Private source repository: keep all extension code here and add collaborators/teams normally.
2. Public artifact repository: store only signed CRX files and updates.xml.

Why: Chrome extension auto-update checks do not use your private GitHub auth session, so private GitHub release assets are not a reliable direct updater source.

If everything must remain private, host updates.xml and CRX files on an internal static server reachable by managed devices without interactive login.

## 1) Set Your Update URL In Manifest

Edit manifest.json and replace update_url with your stable updates.xml URL.

Example:

https://YOUR_GITHUB_USERNAME.github.io/ext-self-update-artifacts/updates.xml

Do this before packaging releases.

## 2) Generate First Package + Signing Key

From this project directory:

```bash
./scripts/package-extension.sh "$PWD"
```

- First run creates .crx and .pem (private key).
- Keep the PEM file secret and backed up.
- Every future release must use the same PEM key, or update/install will break due to changed extension identity.

## 3) Get Deterministic Extension ID From PEM

```bash
./scripts/extension-id-from-pem.sh /secure/path/ext-self-update.pem
```

Save this ID. You need it for:

- Chrome enterprise policy
- updates.xml appid field

## 4) Prepare updates.xml

Generate updates.xml:

```bash
./scripts/generate-updates-xml.sh \
  "YOUR_EXTENSION_ID" \
  "1.0.0" \
  "https://github.com/OWNER/ARTIFACT_REPO/releases/download/v1.0.0/ext-self-update.crx" \
  "./artifacts/updates.xml"
```

Upload artifacts/updates.xml to a stable public URL, such as GitHub Pages.

## 5) Publish Release Artifacts On GitHub

In your artifact repo:

1. Create GitHub release tag v1.0.0.
2. Upload ext-self-update.crx as a release asset.
3. Publish updates.xml at your stable URL.

## 6) Configure Managed Chrome Policy On macOS

Use enterprise policy (MDM/profile preferred).

Policy value format:

- ExtensionInstallForcelist item: EXTENSION_ID;UPDATE_XML_URL

Example value:

YOUR_EXTENSION_ID;https://YOUR_GITHUB_USERNAME.github.io/ext-self-update-artifacts/updates.xml

A ready template is included at policy/com.google.Chrome.plist.template.

Quick local lab-style plist example (for testing environments where you control managed preferences):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>ExtensionInstallForcelist</key>
    <array>
      <string>YOUR_EXTENSION_ID;https://YOUR_GITHUB_USERNAME.github.io/ext-self-update-artifacts/updates.xml</string>
    </array>
  </dict>
</plist>
```

Deploy policy, restart Chrome, then verify in:

- chrome://policy
- chrome://extensions

## 7) Release Update v1.0.1

1. Bump version in manifest.json from 1.0.0 to 1.0.1.
2. Re-package with the same PEM key:

```bash
./scripts/package-extension.sh "$PWD" "/secure/path/ext-self-update.pem"
```

3. Upload new CRX to artifact repo release v1.0.1.
4. Re-generate updates.xml pointing to v1.0.1 CRX URL and version 1.0.1.
5. Publish updated updates.xml to the same stable URL.

Managed clients should auto-update. You can force a check from chrome://extensions using "Update" in developer mode.

## 8) Validate End To End

- Confirm extension installs via policy (without manual CRX install).
- Open popup and verify Installed version.
- Publish a newer version and force update check.
- Confirm popup version changes.

## Troubleshooting

- Extension does not install:
  - Check chrome://policy for policy parsing errors.
  - Ensure EXTENSION_ID matches the ID from your PEM.
- Update does not apply:
  - Confirm updates.xml appid equals extension ID.
  - Confirm updates.xml version equals manifest version in CRX.
  - Confirm CRX was signed with the same PEM key.
  - Confirm codebase URL is reachable over HTTPS.
- Source is private and you need collaborator access:
  - Keep source in private repo and add collaborators/teams.
  - Only publish binaries and updates.xml in public artifact repo.

## Security Notes

- Never commit PEM keys.
- Rotate artifact credentials if leaked.
- Treat signed CRX outputs as deployable binaries.
