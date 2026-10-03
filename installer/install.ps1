[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "lib\ui.ps1")
. (Join-Path $PSScriptRoot "lib\common.ps1")

$LogPath = New-InstallLog
$ManifestPath = Join-Path $Root "config\packages.json"

function Log([string]$Message) {
    Add-InstallLog -Path $LogPath -Message $Message
}

try {
    Write-Banner
    Log "Installer started. DryRun=$DryRun"

    Write-Section "System Check"

    $platform = [System.Environment]::OSVersion.Platform
    if ($platform -ne [System.PlatformID]::Win32NT) {
        Write-Status FAIL "This installer currently supports Windows only."
        Log "Unsupported OS platform: $platform"
        exit 20
    }
    Write-Status OK "Windows detected."

    if (-not (Test-CommandExists "winget")) {
        Write-Status FAIL "WinGet was not found. Install/update App Installer first."
        Log "winget missing"
        exit 21
    }
    Write-Status OK "WinGet detected."

    $freeGB = Get-FreeSystemDriveGB
    if ($freeGB -lt 5) {
        Write-Status WARN "Only $freeGB GB free on the system drive."
    } else {
        Write-Status OK "$freeGB GB free on the system drive."
    }

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        Write-Status FAIL "Package manifest is missing."
        Log "Missing manifest: $ManifestPath"
        exit 22
    }

    $manifest = Get-Content -LiteralPath $ManifestPath -Raw | ConvertFrom-Json
    $packages = @($manifest.packages)

    Write-Section "Antigravity"
    $done = 0
    $failed = @()

    foreach ($pkg in $packages) {
        $done++
        $name = [string]$pkg.name
        $id = [string]$pkg.id

        if (Test-WingetPackageInstalled -Id $id) {
            Write-Status SKIP "$name already installed ($id)."
            Log "SKIP installed: $name [$id]"
            Write-ProgressLine -Done $done -Total $packages.Count
            continue
        }

        if ($DryRun) {
            Write-Status INFO "Would install $name ($id)."
        } else {
            Write-Status RUN "Installing $name ($id)..."
        }

        $result = Install-WingetPackage -Id $id -DryRun:$DryRun
        Log ("INSTALL {0} [{1}] exit={2} output={3}" -f $name, $id, $result.ExitCode, $result.Output)

        if ($result.Success) {
            if ($DryRun) {
                Write-Status OK "Dry-run validated install action for $name."
            } elseif (Test-WingetPackageInstalled -Id $id) {
                Write-Status OK "$name installed and detected."
            } else {
                Write-Status WARN "$name command finished but verification did not detect the package."
                $failed += $name
            }
        } else {
            Write-Status FAIL "$name installation failed with exit code $($result.ExitCode)."
            $failed += $name
        }

        Write-ProgressLine -Done $done -Total $packages.Count
    }

    Write-Section "Phase 1 Verification"
    if ($failed.Count -gt 0) {
        Write-Status FAIL ("Failed/uncertain components: " + ($failed -join ", "))
        Log ("Phase 1 failed components: " + ($failed -join ", "))
        Write-Host ""
        Write-Host "  Log: $LogPath" -ForegroundColor Gray
        exit 30
    }

    Write-Status OK "Installer engine completed without package failures."
    if ($DryRun) {
        Write-Status INFO "DRY-RUN mode made no package changes."
    }

    Write-Status INFO "Research agents, skills, themes, and safety settings arrive in later phases."
    Log "Phase 1 completed successfully."

    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor DarkGray
    Write-Host "  PHASE 1 INSTALLER ENGINE COMPLETE" -ForegroundColor Green
    Write-Host "  made by Rafdi D. Ulhaq" -ForegroundColor DarkYellow
    Write-Host "  Log: $LogPath" -ForegroundColor Gray
    Write-Host "  ============================================================" -ForegroundColor DarkGray

    exit 0
}
catch {
    try { Log ("UNHANDLED ERROR: " + $_.Exception.Message) } catch {}
    Write-Host ""
    Write-Status FAIL $_.Exception.Message
    Write-Host "  Log: $LogPath" -ForegroundColor Gray
    exit 99
}
