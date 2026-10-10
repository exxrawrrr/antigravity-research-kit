[CmdletBinding()]
param(
    [string]$Version = "0.1.0-rc1"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$RepoRoot = Split-Path -Parent $PSScriptRoot
$Dist = Join-Path $RepoRoot "dist"
$Stage = Join-Path $Dist ("Antigravity-Research-Kit-v" + $Version)
$Zip = $Stage + ".zip"
$Checksum = $Zip + ".sha256"

if (Test-Path -LiteralPath $Stage) { Remove-Item -LiteralPath $Stage -Recurse -Force }
if (Test-Path -LiteralPath $Zip) { Remove-Item -LiteralPath $Zip -Force }
if (Test-Path -LiteralPath $Checksum) { Remove-Item -LiteralPath $Checksum -Force }
New-Item -ItemType Directory -Force -Path $Stage | Out-Null

$include = @(
    "GET-EXXRAWRRR.ps1",
    "START.cmd",
    "INSTALL.bat",
    "STATUS.cmd",
    "VERIFY.bat",
    "REPAIR.bat",
    "ROLLBACK-MANAGED-SETUP.bat",
    "README.md",
    "QUICKSTART.md",
    "FRIENDS-START.md",
    "SECURITY.md",
    "LICENSE",
    "VERSION",
    "assets",
    "config",
    "installer",
    "pack"
)

foreach ($item in $include) {
    $source = Join-Path $RepoRoot $item
    if (-not (Test-Path -LiteralPath $source)) { throw "Release input missing: $item" }
    Copy-Item -LiteralPath $source -Destination $Stage -Recurse -Force
}

$manifest = Join-Path $Stage "MANIFEST-SHA256.txt"
$files = Get-ChildItem -LiteralPath $Stage -Recurse -File | Where-Object { $_.FullName -ne $manifest } | Sort-Object FullName
$lines = foreach ($file in $files) {
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    $relative = $file.FullName.Substring($Stage.Length).TrimStart([char]92,[char]47).Replace([char]92,[char]47)
    "$hash  $relative"
}
Set-Content -LiteralPath $manifest -Value $lines -Encoding UTF8

Compress-Archive -LiteralPath $Stage -DestinationPath $Zip -CompressionLevel Optimal
$zipHash = (Get-FileHash -LiteralPath $Zip -Algorithm SHA256).Hash.ToLowerInvariant()
Set-Content -LiteralPath $Checksum -Value ("{0}  {1}" -f $zipHash, (Split-Path $Zip -Leaf)) -Encoding ASCII

Write-Host "RELEASE_ZIP=$Zip"
Write-Host "SHA256=$zipHash"
Write-Host "CHECKSUM_FILE=$Checksum"
