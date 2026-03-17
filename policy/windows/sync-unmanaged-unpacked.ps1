$ErrorActionPreference = "Stop"

$repoUrl = if ($env:EXT_SELF_UPDATE_REPO_URL) { $env:EXT_SELF_UPDATE_REPO_URL } else { "https://github.com/elsesourav/ext-self-update.git" }
$repoBranch = if ($env:EXT_SELF_UPDATE_REPO_BRANCH) { $env:EXT_SELF_UPDATE_REPO_BRANCH } else { "main" }
$repoDir = if ($env:EXT_SELF_UPDATE_REPO_DIR) { $env:EXT_SELF_UPDATE_REPO_DIR } else { Join-Path $env:USERPROFILE "ext-self-update-unpacked" }

function Remove-RepoDirSafely {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path)) {
    throw "Refusing to remove empty path"
  }

  $resolved = [System.IO.Path]::GetFullPath($Path)
  $home = [System.IO.Path]::GetFullPath($env:USERPROFILE)
  $root = [System.IO.Path]::GetPathRoot($resolved)

  if ($resolved.TrimEnd('\\') -eq $root.TrimEnd('\\') -or $resolved.TrimEnd('\\') -eq $home.TrimEnd('\\')) {
    throw "Refusing to remove unsafe path: $resolved"
  }

  Remove-Item -Path $resolved -Recurse -Force
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "git is required but not installed"
}

$parent = Split-Path -Path $repoDir -Parent
if ($parent) {
  New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

$changed = $false

if (-not (Test-Path $repoDir)) {
  git clone --branch $repoBranch --single-branch $repoUrl $repoDir | Out-Null
  $changed = $true
} else {
  if (-not (Test-Path (Join-Path $repoDir ".git"))) {
    Remove-RepoDirSafely -Path $repoDir
    git clone --branch $repoBranch --single-branch $repoUrl $repoDir | Out-Null
    $changed = $true
  } else {
    $before = (git -C $repoDir rev-parse HEAD).Trim()
    $hadLocalChanges = -not [string]::IsNullOrWhiteSpace((git -C $repoDir status --porcelain | Out-String).Trim())

    git -C $repoDir remote set-url origin $repoUrl | Out-Null
    git -C $repoDir fetch origin $repoBranch --quiet
    # Force local folder to exactly match current remote branch state.
    git -C $repoDir reset --hard "origin/$repoBranch" --quiet
    git -C $repoDir clean -fdx -q
    $after = (git -C $repoDir rev-parse HEAD).Trim()

    if ($before -ne $after -or $hadLocalChanges) {
      $changed = $true
    }
  }
}

$manifestVersion = "unknown"
$manifestPath = Join-Path $repoDir "manifest.json"
if (Test-Path $manifestPath) {
  try {
    $manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.version) {
      $manifestVersion = [string]$manifest.version
    }
  } catch {
    $manifestVersion = "unknown"
  }
}

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
if ($changed) {
  Write-Output "$timestamp synced update; version=$manifestVersion; repo=$repoDir"
} else {
  Write-Output "$timestamp no change; version=$manifestVersion; repo=$repoDir"
}

"$timestamp|$manifestVersion|$changed" | Set-Content -Path (Join-Path $repoDir ".sync-state") -Encoding UTF8
