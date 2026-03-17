param(
  [Parameter(Mandatory = $true)]
  [string]$ExtensionDir,

  [Parameter(Mandatory = $false)]
  [string]$PemKeyPath = "",

  [Parameter(Mandatory = $false)]
  [string]$ChromePath = ""
)

$ErrorActionPreference = "Stop"

function Resolve-ChromePath {
  param([string]$RequestedPath)

  if ($RequestedPath -and (Test-Path $RequestedPath)) {
    return $RequestedPath
  }

  $candidates = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles(x86)\Google\Chrome\Application\chrome.exe"
  )

  foreach ($candidate in $candidates) {
    if (Test-Path $candidate) {
      return $candidate
    }
  }

  throw "Could not find chrome.exe. Provide -ChromePath explicitly."
}

if (-not (Test-Path $ExtensionDir)) {
  throw "Extension directory not found: $ExtensionDir"
}

if ($PemKeyPath -and -not (Test-Path $PemKeyPath)) {
  throw "PEM key not found: $PemKeyPath"
}

$chromeExe = Resolve-ChromePath -RequestedPath $ChromePath

$args = @("--pack-extension=$ExtensionDir")
if ($PemKeyPath) {
  $args += "--pack-extension-key=$PemKeyPath"
}

Write-Host "Packing extension from: $ExtensionDir"
if ($PemKeyPath) {
  Write-Host "Using existing key: $PemKeyPath"
} else {
  Write-Host "No key provided. Chrome may generate a new .pem. Keep it safe for future updates."
}

$process = Start-Process -FilePath $chromeExe -ArgumentList $args -NoNewWindow -PassThru -Wait
if ($process.ExitCode -ne 0) {
  throw "Chrome packaging failed with exit code $($process.ExitCode)"
}

Write-Host "Pack complete. Chrome writes .crx and possibly .pem next to the extension directory."
