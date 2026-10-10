# EXXRAWRRR Research Kit — friend-friendly release downloader.
# Made by Rafdi D. Ulhaq. Source: https://github.com/exxrawrrr/antigravity-research-kit
# This downloads only the published GitHub Release (not the mutable main branch ZIP).
[CmdletBinding()]
param([switch]$DownloadOnly, [switch]$Preview)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest


# The preview is presentation-only. Every real progress state represents a completed gate.
$script:KitEsc = [char]27
$script:KitTrueColor = [bool]$env:WT_SESSION

function Ink([string]$Message, [string]$Hex='#E7E1D7', [string]$Fallback='White', [switch]$NoNewline) {
    if ($script:KitTrueColor) {
        $v = $Hex.TrimStart('#')
        $rgb = @([Convert]::ToInt32($v.Substring(0,2),16), [Convert]::ToInt32($v.Substring(2,2),16), [Convert]::ToInt32($v.Substring(4,2),16))
        $code = "$($script:KitEsc)[38;2;$($rgb[0]);$($rgb[1]);$($rgb[2])m"
        $reset = "$($script:KitEsc)[0m"
        if ($NoNewline) { [Console]::Write($code+$Message+$reset) }
        else { [Console]::WriteLine($code+$Message+$reset) }
    } else {
        Write-Host $Message -ForegroundColor $Fallback -NoNewline:$NoNewline
    }
}

function Show-Exxrawrrr {
    $font = @{
        E = @('11111','1    ','1111 ','1    ','11111')
        X = @('1   1',' 1 1 ','  1  ',' 1 1 ','1   1')
        R = @('1111 ','1   1','1111 ','1  1 ','1   1')
        A = @(' 111 ','1   1','11111','1   1','1   1')
        W = @('1   1','1   1','1 1 1','11 11','1   1')
    }
    $colors = @('#FFD35D','#FFC34A','#F6B83C','#D87938','#99613A')
    $word = 'EXXRAWRRR'
    Write-Host ''
    for($line=0;$line -lt 5;$line++) {
        $text = '  '
        foreach($char in $word.ToCharArray()) { $text += $font[[string]$char][$line] + ' ' }
        Ink -Message ($text.Replace('1',[string][char]0x2588)) -Hex $colors[$line] -Fallback 'Yellow'
    }
    Write-Host ''
    Ink '  ANTIGRAVITY RESEARCH KIT   /   CMD EDITION' '#FFC34A' 'Yellow'
    Ink '  made by Rafdi D. Ulhaq  |  skripsi - tesis - disertasi' '#AFA79D' 'Gray'
    Ink '  ----------------------------------------------------------' '#8F5C38' 'DarkYellow'
    Ink '  GITHUB RELEASE  /  SHA256 LOCK  /  PERMISSION-FIRST' '#7DD3A7' 'Green'
    Write-Host ''
}

function Show-Phase([int]$Number, [string]$Title) {
    $total = 6
    $done = [Math]::Max(0,$Number-1)
    $width = 28
    $filled = [int][Math]::Floor(($done / $total) * $width)
    $empty = $width - $filled
    $block = [string][char]0x2588
    $shade = [string][char]0x2591
    Ink ("  PHASE {0:D2}/{1:D2}  {2}" -f $Number,$total,$Title.ToUpperInvariant()) '#FFD35D' 'Yellow'
    Ink ('  [' + ($block * $filled) + ($shade * $empty) + ('] {0,3}%' -f ([int][Math]::Floor(($done/$total)*100)))) '#F6B83C' 'DarkYellow'
}

function Show-Complete([string]$Detail) {
    $block = [string][char]0x2588
    Ink ('  [' + ($block * 28) + '] 100%') '#7DD3A7' 'Green'
    Ink '  ==========================================================' '#8F5C38' 'DarkYellow'
    Ink '  EXXRAWRRR READY  /  VERIFIED RELEASE PAYLOAD' '#7DD3A7' 'Green'
    Ink ('  ' + $Detail) '#E7E1D7' 'White'
    Ink '  ==========================================================' '#8F5C38' 'DarkYellow'
}

function Say([string]$Kind,[string]$Message) {
    $color = switch ($Kind) { 'OK' {'Green'} 'FAIL' {'Red'} 'RUN' {'Yellow'} default {'Cyan'} }
    Write-Host ("  [{0}] {1}" -f $Kind,$Message) -ForegroundColor $color
}

if ($Preview) {
    Show-Exxrawrrr
    1..6 | ForEach-Object { Show-Phase $_ (@('Checking Windows','Resolving official release','Downloading verified payload','Locking SHA256 integrity','Validating package files','Installer handoff')[$_-1]) }
    Show-Complete 'UI preview only - no downloads or changes made'
    exit 0
}

try {
    Show-Exxrawrrr
    Show-Phase 1 'Checking Windows'
    if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
        throw 'Only Windows is supported.'
    }
    Say OK 'Windows detected. Running as current user (no forced admin).'
    $repo = 'exxrawrrr/antigravity-research-kit'
    $api = "https://api.github.com/repos/$repo/releases/latest"
    $headers = @{ 'User-Agent' = 'EXXRAWRRR-Research-Kit-Installer'; 'Accept' = 'application/vnd.github+json' }

    Show-Phase 2 'Resolving official release'
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

    Show-Phase 3 "Downloading verified payload"
    Say RUN ("Downloading $tag ZIP and SHA256...")
    Invoke-WebRequest -Uri ([string]$zipAsset.browser_download_url) -OutFile $zip -UseBasicParsing -TimeoutSec 180
    Invoke-WebRequest -Uri ([string]$hashAsset.browser_download_url) -OutFile $checksum -UseBasicParsing -TimeoutSec 40
    Show-Phase 4 'Locking SHA256 integrity'
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

    Show-Phase 5 'Validating package files'
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
    Show-Phase 6 "Installer handoff"
    Say OK "Installer ready: $starter"
    Show-Complete "Verified release: $tag"

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
