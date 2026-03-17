# Client First-Time Setup (No Local Files Needed)

This guide is for client machines that do not have this repository cloned.
Everything is done from terminal commands only.

## What This Setup Does

- Applies managed Chrome policy to force-install extension ID `jngcnbojdjmlecbcmkdbfinkhienmpmm`
- Uses update manifest URL:
  - https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml
- Restarts Chrome process
- Lets Chrome install the extension automatically

## Requirements

- Google Chrome installed on the client machine
- Admin rights on the client machine
- Network access to:
  - raw.githubusercontent.com
  - github.com
- Organization policy allows managed Chrome policies

## One-Command Install (Fast)

### macOS

Run in Terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/install-first-time-client.sh | sudo bash
```

### Windows

Run in Administrator PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/install-first-time-client.ps1 -UseBasicParsing | iex"
```

## Safer Install (Download, Review, Then Run)

### macOS

```bash
curl -fsSL -o /tmp/ext-self-update-install.sh https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/macos/install-first-time-client.sh
cat /tmp/ext-self-update-install.sh
sudo bash /tmp/ext-self-update-install.sh
rm -f /tmp/ext-self-update-install.sh
```

### Windows

Run in Administrator PowerShell:

```powershell
$url = "https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/install-first-time-client.ps1"
$path = "$env:TEMP\ext-self-update-install-first-time-client.ps1"
iwr $url -OutFile $path -UseBasicParsing
Get-Content $path
powershell -NoProfile -ExecutionPolicy Bypass -File $path
Remove-Item $path -Force
```

## Verify On Client

1. Open `chrome://policy`
2. Click `Reload policies`
3. Confirm `ExtensionInstallForcelist` exists
4. Open `chrome://extensions`
5. Confirm extension is installed and enabled

Expected extension ID:

- jngcnbojdjmlecbcmkdbfinkhienmpmm

## Optional CLI Verification

### macOS

```bash
defaults read "/Library/Managed Preferences/com.google.Chrome.plist" ExtensionInstallForcelist
```

### Windows

```powershell
reg query "HKLM\Software\Policies\Google\Chrome\ExtensionInstallForcelist" /v 1
```

## If Extension Does Not Install

1. Check managed policy is present in `chrome://policy`
2. Check update manifest is reachable:

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml
```

### Windows

```powershell
iwr https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml -UseBasicParsing | Select-Object -ExpandProperty Content
```

3. Confirm GitHub release asset exists and is reachable:

- https://github.com/elsesourav/ext-self-update/releases/download/v1.0.0/ext-self-update.crx

4. Close and reopen Chrome, then check `chrome://extensions` again

## Rollback / Remove From Client

### macOS

```bash
sudo rm -f "/Library/Managed Preferences/com.google.Chrome.plist"
```

Then restart Chrome.

### Windows

Run in Administrator PowerShell:

```powershell
reg delete "HKLM\Software\Policies\Google\Chrome\ExtensionInstallForcelist" /v 1 /f
```

Then restart Chrome.

## Notes

- This is managed-policy installation, not normal user installation.
- For unmanaged devices, full automatic off-store install/update is not available.
