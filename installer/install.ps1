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
. (Join-Path $PSScriptRoot "lib\ide.ps1")

$LogPath = New-InstallLog
$ManifestPath = Join-Path $Root "config\packages.json"
$IdeManifestPath = Join-Path $Root "config\ide.json"

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

    Write-Section "IDE Experience"

    if (-not (Test-Path -LiteralPath $IdeManifestPath)) {
        Write-Status FAIL "IDE manifest is missing."
        Log "Missing IDE manifest: $IdeManifestPath"
        $failed += "IDE manifest"
    } else {
        $ideManifest = Get-Content -LiteralPath $IdeManifestPath -Raw | ConvertFrom-Json
        $ideCli = Get-AntigravityIdeCli

        if (-not $ideCli) {
            Write-Status FAIL "Antigravity IDE CLI was not found."
            Log "Antigravity IDE CLI missing"
            $failed += "Antigravity IDE CLI"
        } else {
            Write-Status OK "Antigravity IDE CLI detected."

            foreach ($ext in @($ideManifest.extensions)) {
                $extName = [string]$ext.name
                $extId = [string]$ext.id

                if (Test-IdeExtensionInstalled -ExtensionId $extId) {
                    Write-Status SKIP "$extName already installed ($extId)."
                    Log "SKIP extension installed: $extName [$extId]"
                    continue
                }

                if ($DryRun) {
                    Write-Status INFO "Would install IDE extension $extName ($extId)."
                } else {
                    Write-Status RUN "Installing IDE extension $extName ($extId)..."
                }

                $extResult = Install-IdeExtension -Cli $ideCli -ExtensionId $extId -DryRun:$DryRun
                Log ("EXTENSION {0} [{1}] exit={2} output={3}" -f $extName, $extId, $extResult.ExitCode, $extResult.Output)

                if ($extResult.Success) {
                    Write-Status OK "$extName extension action verified."
                } else {
                    Write-Status FAIL "$extName extension installation could not be verified."
                    $failed += $extName
                }
            }

            $desired = @{}
            foreach ($prop in $ideManifest.settings.PSObject.Properties) {
                $desired[$prop.Name] = $prop.Value
            }

            $experience = Set-AntigravityIdeExperience -Desired $desired -DryRun:$DryRun
            Log ("IDE EXPERIENCE success={0} changed={1} path={2} backup={3} output={4}" -f $experience.Success, $experience.Changed, $experience.Path, $experience.Backup, $experience.Output)

            if ($experience.Success) {
                if ($DryRun) {
                    Write-Status INFO "Would select Tokyo Night Storm + Material Icon Theme."
                } else {
                    Write-Status OK "Tokyo Night Storm + Material Icon Theme configured."
                    if ($experience.Backup) {
                        Write-Status INFO "Previous IDE settings backed up to $($experience.Backup)"
                    }
                }
            } else {
                Write-Status FAIL "IDE settings were left unchanged: $($experience.Output)"
                $failed += "IDE settings"
            }
        }
    }

    Write-Section "Safety Defaults"

    $safety = Test-AgySafetyCapabilities
    Log ("AGY SAFETY: " + $safety.Output)
    if ($safety.Success) {
        Write-Status OK "agy supports terminal sandbox (--sandbox)."
        Write-Status OK "Permission prompts stay ON; dangerous auto-approval is never enabled."
    } else {
        Write-Status FAIL "Required agy safety capabilities were not verified."
        $failed += "agy safety"
    }

    $safeLauncher = Install-AgySafeLauncher -DryRun:$DryRun
    Log ("SAFE LAUNCHER success={0} path={1} output={2}" -f $safeLauncher.Success, $safeLauncher.Path, $safeLauncher.Output)
    if ($safeLauncher.Success) {
        if ($DryRun) {
            Write-Status INFO "Would create agy-safe launcher at $($safeLauncher.Path)."
        } else {
            Write-Status OK "agy-safe launcher created at $($safeLauncher.Path)."
        }
    } else {
        Write-Status FAIL "Could not create agy-safe launcher."
        $failed += "agy-safe launcher"
    }

    Write-Section "Installer Verification"
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

    Write-Status INFO "Research agents and academic skills arrive in Phase 3."
    Log "Phase 1 completed successfully."

    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor DarkGray
    Write-Host "  ANTIGRAVITY BASE SETUP COMPLETE" -ForegroundColor Green
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
