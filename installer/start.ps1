[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "lib\ui.ps1")
. (Join-Path $PSScriptRoot "lib\ui-rich.ps1")
. (Join-Path $PSScriptRoot "lib\ui-color.ps1")

$install = Join-Path $PSScriptRoot "install.ps1"
$verify = Join-Path $PSScriptRoot "verify.ps1"
$repair = Join-Path $Root "REPAIR.bat"

function Invoke-KitScript {
    param(
        [string]$Script,
        [string[]]$Arguments,
        [ref]$ExitCode
    )

    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File $Script @Arguments
    $ExitCode.Value = [int]$LASTEXITCODE
}

function Open-Antigravity {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE\Antigravity IDE.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            Start-Process -FilePath $candidate -WorkingDirectory $Root | Out-Null
            return $true
        }
    }

    return $false
}

$installArgs = @("-NoPause")
if ($DryRun) { $installArgs += "-DryRun" }

$installCode = 0
Invoke-KitScript -Script $install -Arguments $installArgs -ExitCode ([ref]$installCode)

if ($installCode -ne 0) {
    Write-Section "User Action Required"
    Write-Status FAIL "Installation stopped with exit code $installCode."
    Write-Status INFO "Review the installer message above before retrying."
    Write-ActionPanel -Title "NEXT ACTION" -Items @(
        "[R] Run repair",
        "[L] Leave terminal open",
        "[Q] Quit"
    )

    $choice = (Read-Host "  choose").Trim().ToUpperInvariant()
    if ($choice -eq "R") {
        & $repair
        exit $LASTEXITCODE
    }
    if ($choice -eq "L") {
        Read-Host "  press Enter when ready to close" | Out-Null
    }
    exit $installCode
}

while ($true) {
    Write-ActionPanel -Title "USER ACTION" -Items @(
        "[V] Verify installation",
        "[A] Open Antigravity",
        "[R] Run repair",
        "[Q] Close terminal"
    )

    $choice = (Read-Host "  choose").Trim().ToUpperInvariant()

    switch ($choice) {
        "V" {
            $verifyCode = 0
            Invoke-KitScript -Script $verify -Arguments @() -ExitCode ([ref]$verifyCode)
            if ($verifyCode -eq 0) {
                Write-Status OK "Verification passed."
            } else {
                Write-Status WARN "Verification returned exit code $verifyCode."
            }
        }
        "A" {
            if (Open-Antigravity) {
                Write-Status OK "Antigravity launched."
            } else {
                Write-Status WARN "Antigravity executable was not found."
            }
        }
        "R" {
            & $repair
        }
        "Q" {
            Write-Host ""
            Write-Status INFO "Session closed. Installed tools remain available."
            exit 0
        }
        default {
            Write-Status WARN "Unknown action. Choose V, A, R, or Q."
        }
    }
}
