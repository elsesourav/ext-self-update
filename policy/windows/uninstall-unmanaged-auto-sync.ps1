$ErrorActionPreference = "Stop"

$taskName = "ExtSelfUpdate-UnmanagedSync"
$baseDir = if ($env:EXT_SELF_UPDATE_BASE_DIR) { $env:EXT_SELF_UPDATE_BASE_DIR } else { Join-Path $env:USERPROFILE ".ext-self-update" }

schtasks /Delete /TN $taskName /F | Out-Null

Write-Host "Removed scheduled task: $taskName"
Write-Host "Sync files remain at: $baseDir"
Write-Host "If you want full cleanup: Remove-Item -Path '$baseDir' -Recurse -Force"
