# EXXRAWRRR Research Kit — friend-friendly release downloader.
# Made by Rafdi D. Ulhaq. Source: https://github.com/exxrawrrr/antigravity-research-kit
# This downloads only the published GitHub Release (not the mutable main branch ZIP).
[CmdletBinding()]
param([switch]$DownloadOnly)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Say([string]$Kind,[string]$Message) {
    $color = switch ($Kind) { 'OK' {'Green'} 'FAIL' {'Red'} 'RUN' {'Yellow'} default {'Cyan'} }
    Write-Host ("  [{0}] {1}" -f $Kind,$Message) -ForegroundColor $color
}

try {
    Write-Host ''
    Write-Host '  EXXRAWRRR / ANTIGRAVITY RESEARCH KIT' -ForegroundColor Yellow
    Write-Host '  Made by Rafdi D. Ulhaq' -ForegroundColor DarkYellow
    Write-Host '  Official release downloader + SHA256 verification' -ForegroundColor Gray
    Write-Host ''

    if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
        throw 'Only Windows is supported.'
    }
    $repo = 'exxrawrrr/antigravity-research-kit'
    $api = "https://api.github.com/repos/$repo/releases/latest"
    $headers = @{ 'User-Agent' = 'EXXRAWRRR-Research-Kit-Installer'; 'Accept' = 'application/vnd.github+json' }

    Say RUN 'Finding the latest published release...'
    $release = Invoke-RestMethod -Uri $api -Headers $headers -TimeoutSec 40
    $tag = [string]$release.tag_name
    if ($tag -notmatch '^v[0-9]+\.[0-9]+\.[0-9]+$') { throw "Unexpected release tag: $tag" }
    $expectedZipName = "Antigravity-Research-Kit-$tag.zip"
    $zipAsset = @($release.assets | Where-Object { $_.name -ceq $expectedZipName }) | Select-Object -First 1
    $hashAsset = @($release.assets | Where-Object { $_.name -ceq ($expectedZipName + '.sha256') }) | Select-Object -First 1
    if (-not $zipAsset -or -not $hashAsset) { throw 'Release ZIP or its SHA256 file is missing. Cannot continue.' }
    $releaseUrlPrefix = "https://github.com/$repo/releases/download/$tag/"
    if (-not ([string]$zipAsset.browser_download_url).StartsWith($releaseUrlPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Unexpected ZIP download URL.'
    }
    if (-not ([string]$hashAsset.browser_download_url).StartsWith($releaseUrlPrefix,[StringComparison]::OrdinalIgnoreCase)) {
        throw 'Unexpected checksum download URL.'
    }

    $kitHome = Join-Path $env:LOCALAPPDATA 'Rafdi\AntigravityResearchKit'
    $downloads = Join-Path $kitHome 'downloads'
    $releaseHome = Join-Path (Join-Path $kitHome 'releases') $tag
    New-Item -ItemType Directory -Force -Path $downloads,$releaseHome | Out-Null
    $zip = Join-Path $downloads $expectedZipName
    $checksum = "$zip.sha256"

    Say RUN ("Downloading $tag ZIP and SHA256...")
    Invoke-WebRequest -Uri ([string]$zipAsset.browser_download_url) -OutFile $zip -UseBasicParsing -TimeoutSec 180
    Invoke-WebRequest -Uri ([string]$hashAsset.browser_download_url) -OutFile $checksum -UseBasicParsing -TimeoutSec 40
    $line = (Get-Content -LiteralPath $checksum -Raw).Trim()
    if ($line -notmatch '^([0-9a-fA-F]{64})\s+(\S+)$') { throw 'Malformed SHA256 file.' }
    $expectedHash = $Matches[1].ToLowerInvariant()
    if ($Matches[2] -cne $expectedZipName) { throw 'Checksum filename mismatch.' }
    $actualHash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -cne $expectedHash) { throw 'SHA256 mismatch. Refusing to execute downloaded files.' }
    if (($zipAsset.PSObject.Properties.Name -contains 'digest') -and $zipAsset.digest) {
        if ([string]$zipAsset.digest -cne "sha256:$actualHash") { throw 'GitHub release digest mismatch.' }
    }
    Say OK 'Downloaded ZIP SHA256 verified.'

    $stage = Join-Path $releaseHome 'stage'
    if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Force -Recurse }
    New-Item -ItemType Directory -Force -Path $stage | Out-Null
    Expand-Archive -LiteralPath $zip -DestinationPath $stage -Force
    $root = Join-Path $stage ("Antigravity-Research-Kit-" + $tag)
    $manifest = Join-Path $root 'MANIFEST-SHA256.txt'
    $starter = Join-Path $root 'START.cmd'
    if (-not (Test-Path -LiteralPath $starter)) { throw 'START.cmd missing from published ZIP.' }
    if (-not (Test-Path -LiteralPath $manifest)) { throw 'Internal checksum manifest missing.' }

    $verified = 0
    foreach ($entry in (Get-Content -LiteralPath $manifest)) {
        if ($entry -notmatch '^([0-9a-fA-F]{64})\s{2}(.+)$') { throw 'Malformed internal manifest entry.' }
        $expected = $Matches[1].ToLowerInvariant()
        $relative = $Matches[2] -replace '/', '\'
        $full = [System.IO.Path]::GetFullPath((Join-Path $root $relative))
        $allowed = [System.IO.Path]::GetFullPath($root).TrimEnd('\') + '\'
        if (-not $full.StartsWith($allowed,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe file path in archive.' }
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { throw "Missing release file: $relative" }
        if ((Get-FileHash -LiteralPath $full -Algorithm SHA256).Hash.ToLowerInvariant() -cne $expected) {
            throw "Release file hash mismatch: $relative"
        }
        $verified++
    }
    if ($verified -lt 1) { throw 'Empty internal manifest.' }
    Say OK ("Verified $verified bundled files.")
    Say OK "Installer ready: $starter"

    if ($DownloadOnly) {
        Say INFO 'Download-only mode. No installation was started.'
    } else {
        Say RUN 'Opening the branded EXXRAWRRR installer...'
        & $starter
        if ($LASTEXITCODE -ne 0) { throw "Launcher returned exit code $LASTEXITCODE" }
    }
} catch {
    Say FAIL $_.Exception.Message
    Write-Host '  No checksums were bypassed. Read the instructions at:' -ForegroundColor Gray
    Write-Host '  https://github.com/exxrawrrr/antigravity-research-kit' -ForegroundColor Gray
    exit 1
}
