$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "git is required but not installed"
}

$syncScriptUrl = if ($env:EXT_SELF_UPDATE_SYNC_SCRIPT_URL) { $env:EXT_SELF_UPDATE_SYNC_SCRIPT_URL } else { "https://raw.githubusercontent.com/elsesourav/ext-self-update/main/policy/windows/sync-unmanaged-unpacked.ps1" }
$baseDir = if ($env:EXT_SELF_UPDATE_BASE_DIR) { $env:EXT_SELF_UPDATE_BASE_DIR } else { Join-Path $env:USERPROFILE ".ext-self-update" }
$syncScriptPath = Join-Path $baseDir "sync-unmanaged-unpacked.ps1"
$logPath = Join-Path $baseDir "sync.log"
$taskName = "ExtSelfUpdate-UnmanagedSync"

New-Item -ItemType Directory -Path $baseDir -Force | Out-Null

Invoke-WebRequest -Uri $syncScriptUrl -OutFile $syncScriptPath -UseBasicParsing

# Initial sync so user can load unpacked immediately.
powershell -NoProfile -ExecutionPolicy Bypass -File $syncScriptPath *>> $logPath

$taskCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$syncScriptPath`""

schtasks /Create /SC MINUTE /MO 15 /TN $taskName /TR $taskCommand /F | Out-Null
schtasks /Run /TN $taskName | Out-Null

Write-Host "Installed unmanaged auto-sync"
Write-Host "Repo sync script: $syncScriptPath"
Write-Host "Log file: $logPath"
Write-Host "Unpacked extension folder: $env:USERPROFILE\ext-self-update-unpacked"
Write-Host ""
Write-Host "Next steps:"
Write-Host "1) Open chrome://extensions"
Write-Host "2) Enable Developer mode"
Write-Host "3) Load unpacked -> $env:USERPROFILE\ext-self-update-unpacked"
Write-Host "4) After future syncs, click Reload on the extension card"
