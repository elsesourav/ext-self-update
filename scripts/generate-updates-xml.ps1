param(
  [Parameter(Mandatory = $true)]
  [string]$ExtensionId,

  [Parameter(Mandatory = $true)]
  [string]$Version,

  [Parameter(Mandatory = $true)]
  [string]$CodebaseUrl,

  [Parameter(Mandatory = $false)]
  [string]$OutputPath = "artifacts/updates.xml"
)

$ErrorActionPreference = "Stop"

$outputDir = Split-Path -Path $OutputPath -Parent
if ($outputDir) {
  New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$xml = @"
<?xml version='1.0' encoding='UTF-8'?>
<gupdate xmlns='http://www.google.com/update2/response' protocol='2.0'>
  <app appid='$ExtensionId'>
    <updatecheck codebase='$CodebaseUrl' version='$Version' />
  </app>
</gupdate>
"@

Set-Content -Path $OutputPath -Value $xml -Encoding utf8
Write-Host "Wrote update manifest to: $OutputPath"
