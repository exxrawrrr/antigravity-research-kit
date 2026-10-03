[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$NoPause
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "lib\ui.ps1")
. (Join-Path $PSScriptRoot "lib\ui-rich.ps1")
. (Join-Path $PSScriptRoot "lib\ui-color.ps1")
. (Join-Path $PSScriptRoot "lib\common.ps1")
. (Join-Path $PSScriptRoot "lib\ide.ps1")
. (Join-Path $PSScriptRoot "lib\research-pack.ps1")

$LogPath = New-InstallLog
$ManifestPath = Join-Path $Root "config\packages.json"
$IdeManifestPath = Join-Path $Root "config\ide.json"

function Log([string]$Message) {
    Add-InstallLog -Path $LogPath -Message $Message
}

try {
    Write-Banner
    Log "Installer started. DryRun=$DryRun"

    Write-StepHeader -Number 1 -Total 6 -Title "System Check" -Subtitle "Platform, package manager, and free-space preflight"

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

    Write-StepHeader -Number 2 -Total 6 -Title "Antigravity" -Subtitle "Core app, IDE, and CLI package state"
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

    $null = Refresh-ProcessPath
    Log "Process PATH refreshed after core package phase."

    Write-StepHeader -Number 3 -Total 6 -Title "IDE Experience" -Subtitle "Theme, icons, and managed editor settings"

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
                } elseif ($experience.Changed) {
                    Write-Status OK "Tokyo Night Storm + Material Icon Theme configured."
                    if ($experience.Backup) {
                        Write-Status INFO "Previous IDE settings backed up to $($experience.Backup)"
                    }
                } else {
                    Write-Status SKIP "Tokyo Night Storm + Material Icon Theme already configured."
                }
            } else {
                Write-Status FAIL "IDE settings were left unchanged: $($experience.Output)"
                $failed += "IDE settings"
            }
        }
    }

    Write-StepHeader -Number 4 -Total 6 -Title "Safety Defaults" -Subtitle "Sandbox and permission-first launcher behavior"

    $safety = Test-AgySafetyCapabilities
    Log ("AGY SAFETY: " + $safety.Output)
    if ($safety.Success) {
        Write-Status OK "agy supports terminal sandbox (--sandbox)."
        Write-Status OK "Permission prompts stay ON; dangerous auto-approval is never enabled."
    } else {
        Write-Status FAIL "Required agy safety capabilities were not verified."
        $failed += "agy safety"
    }

    $sandboxSetting = Set-AgySandboxPersistent -DryRun:$DryRun
    Log ("SANDBOX SETTING success={0} path={1} backup={2} output={3}" -f $sandboxSetting.Success, $sandboxSetting.Path, $sandboxSetting.Backup, $sandboxSetting.Output)
    if ($sandboxSetting.Success) {
        if ($DryRun) {
            Write-Status INFO "Would persist enableTerminalSandbox=true."
        } elseif ($sandboxSetting.Changed) {
            Write-Status OK "Persistent terminal sandbox enabled."
            if ($sandboxSetting.Backup) {
                Write-Status INFO "Previous CLI settings backed up to $($sandboxSetting.Backup)"
            }
        } else {
            Write-Status SKIP "Persistent terminal sandbox already enabled."
        }
    } else {
        Write-Status FAIL "Could not persist terminal sandbox safely: $($sandboxSetting.Output)"
        $failed += "persistent sandbox"
    }

    $safeLauncher = Install-AgySafeLauncher -DryRun:$DryRun
    Log ("SAFE LAUNCHER success={0} path={1} output={2}" -f $safeLauncher.Success, $safeLauncher.Path, $safeLauncher.Output)
    if ($safeLauncher.Success) {
        if ($DryRun) {
            Write-Status INFO "Would create agy-safe launcher at $($safeLauncher.Path)."
        } elseif ($safeLauncher.Changed) {
            Write-Status OK "agy-safe launcher created at $($safeLauncher.Path)."
        } else {
            Write-Status SKIP "agy-safe launcher already correct."
        }

        $safeBin = Split-Path -Parent $safeLauncher.Path
        $pathResult = Ensure-UserPathEntry -Entry $safeBin -DryRun:$DryRun
        Log ("PATH REGISTER success={0} changed={1} backup={2} output={3}" -f $pathResult.Success, $pathResult.Changed, $pathResult.Backup, $pathResult.Output)
        if ($pathResult.Success) {
            if ($DryRun) {
                Write-Status INFO "Would add managed bin to user PATH so 'agy-safe' works anywhere."
            } elseif ($pathResult.Changed) {
                Write-Status OK "agy-safe registered on user PATH."
                Write-Status INFO "Previous user PATH backed up to $($pathResult.Backup)"
            } else {
                Write-Status SKIP "Managed bin already present on user PATH."
            }
        } else {
            Write-Status FAIL "Could not register agy-safe on user PATH."
            $failed += "agy-safe PATH"
        }
    } else {
        Write-Status FAIL "Could not create agy-safe launcher."
        $failed += "agy-safe launcher"
    }

    Write-StepHeader -Number 5 -Total 6 -Title "Rafdi Academic Research Pack" -Subtitle "Lazy-loaded research, document, and reviewer skills"

    $packSource = Get-RafdiAcademicPackSource -Root $Root
    $packResult = Install-RafdiAcademicPack -Source $packSource -DryRun:$DryRun
    Log ("ACADEMIC PACK success={0} exit={1} skipped={2} output={3}" -f $packResult.Success, $packResult.ExitCode, $packResult.Skipped, $packResult.Output)

    if ($packResult.Success) {
        if ($packResult.Skipped) {
            Write-Status SKIP "Rafdi Academic Research Pack already installed."
        } elseif ($DryRun) {
            Write-Status INFO "Would install Rafdi Academic Research Pack (5 lazy-loaded skills)."
        } else {
            Write-Status OK "Rafdi Academic Research Pack installed."
        }
        Write-Status INFO "Includes 3 role-skills: Research, Document, Reviewer."
        Write-Status INFO "Includes 2 helper skills: Document Style Learning, Evidence Tracing."
    } else {
        Write-Status FAIL "Academic pack installation/validation failed."
        $failed += "Rafdi Academic Research Pack"
    }

    Write-StepHeader -Number 6 -Total 6 -Title "Installer Verification" -Subtitle "Final install gate before handoff"
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

    Write-Status INFO "Academic pack uses progressive disclosure; only relevant skills should load."
    Log "Phase 1 completed successfully."

    $completionDetails = @(
        "Core apps + IDE experience + safety defaults verified",
        "Rafdi Academic Research Pack: 5 lazy-loaded skills",
        "Log: $LogPath"
    )
    Write-CompletionCard -Title "Installation Complete" -Subtitle "Antigravity Research Environment is ready." -Details $completionDetails -State Success

    exit 0
}
catch {
    try { Log ("UNHANDLED ERROR: " + $_.Exception.Message) } catch {}
    Write-Host ""
    Write-Status FAIL $_.Exception.Message
    Write-Host "  Log: $LogPath" -ForegroundColor Gray
    exit 99
}
