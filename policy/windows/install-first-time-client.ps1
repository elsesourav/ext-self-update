$ErrorActionPreference = "Stop"

$currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  throw "Run this script in an Administrator PowerShell session."
}

$extensionId = "jngcnbojdjmlecbcmkdbfinkhienmpmm"
$updateUrl = "https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml"
$policyPath = "HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist"

New-Item -Path $policyPath -Force | Out-Null
New-ItemProperty -Path $policyPath -Name "1" -Value "$extensionId;$updateUrl" -PropertyType String -Force | Out-Null

Start-Process -FilePath "gpupdate.exe" -ArgumentList "/target:computer /force" -Wait -NoNewWindow

Get-Process -Name chrome -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "Policy installed: $policyPath"
Write-Host "Value 1 = $extensionId;$updateUrl"
Write-Host "Open Chrome and verify at chrome://policy then chrome://extensions"
