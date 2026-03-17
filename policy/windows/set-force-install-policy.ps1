param(
  [Parameter(Mandatory = $false)]
  [string]$ExtensionId = "jngcnbojdjmlecbcmkdbfinkhienmpmm",

  [Parameter(Mandatory = $false)]
  [string]$UpdateUrl = "https://raw.githubusercontent.com/elsesourav/ext-self-update/main/artifacts/updates.xml",

  [Parameter(Mandatory = $false)]
  [string]$PolicyHive = "HKCU"
)

$ErrorActionPreference = "Stop"

if ($PolicyHive -ne "HKCU" -and $PolicyHive -ne "HKLM") {
  throw "PolicyHive must be HKCU or HKLM"
}

$policyPath = "$PolicyHive`:\Software\Policies\Google\Chrome\ExtensionInstallForcelist"
New-Item -Path $policyPath -Force | Out-Null

$value = "$ExtensionId;$UpdateUrl"
New-ItemProperty -Path $policyPath -Name "1" -Value $value -PropertyType String -Force | Out-Null

Write-Host "Set policy at $policyPath"
Write-Host "Value 1 = $value"
Write-Host "Restart Chrome and verify in chrome://policy"
