param(
  [Parameter(Mandatory = $true)]
  [string]$PemPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $PemPath)) {
  throw "PEM file not found: $PemPath"
}

$pemContent = Get-Content -Path $PemPath -Raw
$rsa = [System.Security.Cryptography.RSA]::Create()

try {
  $rsa.ImportFromPem($pemContent)
} catch {
  throw "ImportFromPem failed. Use PowerShell 7+ or compute ID via scripts/extension-id-from-pem.sh."
}

$pubDer = $rsa.ExportSubjectPublicKeyInfo()
$sha256 = [System.Security.Cryptography.SHA256]::Create()
$hash = $sha256.ComputeHash($pubDer)

$alphabet = "abcdefghijklmnop"
$builder = New-Object System.Text.StringBuilder

for ($i = 0; $i -lt 16; $i++) {
  $byteVal = [int]$hash[$i]
  [void]$builder.Append($alphabet[($byteVal -shr 4)])
  [void]$builder.Append($alphabet[($byteVal -band 0x0F)])
}

Write-Output $builder.ToString()