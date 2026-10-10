[CmdletBinding()]
param([switch]$ConfirmRollback)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $ConfirmRollback) {
    Write-Host "Rollback requires explicit confirmation. Use ROLLBACK-MANAGED-SETUP.bat." -ForegroundColor Red
    exit 60
}

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "lib\ui.ps1")
. (Join-Path $PSScriptRoot "lib\common.ps1")
. (Join-Path $PSScriptRoot "lib\research-pack.ps1")
$null = Refresh-ProcessPath

Write-Banner
Write-Section "Managed Rollback"
Write-Status INFO "Preserving personal settings, newly added PATH entries, and core Antigravity apps."
$errors = @()

function Restore-ManagedJsonKeys {
    param(
        [string]$Target,
        [string]$BackupFilter,
        [hashtable]$Managed,
        [string]$Label
    )
    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Status SKIP "$Label is missing; nothing to restore."
        return
    }
    $dir = Split-Path -Parent $Target
    $backup = Get-ChildItem -LiteralPath $dir -Filter $BackupFilter -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $backup) {
        Write-Status WARN "No installation backup for $Label; leaving current settings unchanged."
        return
    }
    $current = Get-Content -LiteralPath $Target -Raw | ConvertFrom-Json
    $original = Get-Content -LiteralPath $backup.FullName -Raw | ConvertFrom-Json
    $changed = $false
    foreach ($key in $Managed.Keys) {
        $currentProperty = $current.PSObject.Properties[$key]
        if ($null -eq $currentProperty -or $currentProperty.Value -ne $Managed[$key]) {
            continue # Preserve user changes after setup
        }
        $originalProperty = $original.PSObject.Properties[$key]
        if ($null -eq $originalProperty) {
            $current.PSObject.Properties.Remove($key)
        } else {
            $currentProperty.Value = $originalProperty.Value
        }
        $changed = $true
    }
    if ($changed) {
        $json = $current | ConvertTo-Json -Depth 20
        Set-Content -LiteralPath $Target -Value $json -Encoding UTF8
        Write-Status OK "$Label restored for kit-managed keys; unrelated changes preserved."
    } else {
        Write-Status SKIP "$Label has no kit-managed values to restore."
    }
}

try {
    $ideSettings = Join-Path $env:APPDATA "Antigravity IDE\User\settings.json"
    Restore-ManagedJsonKeys -Target $ideSettings -BackupFilter "settings.json.backup-*" -Managed @{
        "workbench.colorTheme" = "Tokyo Night Storm"
        "workbench.iconTheme" = "material-icon-theme"
    } -Label "IDE settings"
} catch {
    Write-Status FAIL "IDE settings rollback failed: $($_.Exception.Message)"
    $errors += "IDE settings"
}

try {
    $cliSettings = Join-Path $env:USERPROFILE ".gemini\antigravity-cli\settings.json"
    Restore-ManagedJsonKeys -Target $cliSettings -BackupFilter "settings.json.backup-*" -Managed @{
        enableTerminalSandbox = $true
    } -Label "CLI sandbox settings"
} catch {
    Write-Status FAIL "CLI settings rollback failed: $($_.Exception.Message)"
    $errors += "CLI settings"
}

try {
    $pathDir = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\backups"
    $pathBackup = Get-ChildItem -LiteralPath $pathDir -Filter "user-path-*.txt" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($pathBackup) {
        $managedBin = [System.IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\bin")).TrimEnd('\')
        $originalEntries = @((Get-Content -LiteralPath $pathBackup.FullName -Raw) -split ';' | Where-Object { $_.Trim() })
        $preexisting = @($originalEntries | Where-Object {
            try { [System.IO.Path]::GetFullPath($_.Trim()).TrimEnd('\') -ieq $managedBin } catch { $false }
        }).Count -gt 0
        if (-not $preexisting) {
            $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
            $kept = @($currentPath -split ';' | Where-Object {
                if (-not $_.Trim()) { return $false }
                try { [System.IO.Path]::GetFullPath($_.Trim()).TrimEnd('\') -ine $managedBin }
                catch { $true }
            })
            [Environment]::SetEnvironmentVariable("Path", ($kept -join ';'), "User")
            Write-Status OK "Removed only kit-managed PATH entry; other additions preserved."
        } else {
            Write-Status SKIP "Managed bin was already on PATH before install; preserving it."
        }
    } else {
        Write-Status WARN "No PATH ownership backup; PATH left untouched."
    }
} catch {
    Write-Status FAIL "PATH rollback failed: $($_.Exception.Message)"
    $errors += "PATH"
}

try {
    $bin = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\bin"
    $safePath = Join-Path $bin "agy-safe.cmd"
    $safeScript = Join-Path $bin "agy-safe.ps1"
    if (Test-Path -LiteralPath $safePath) {
        $text = Get-Content -LiteralPath $safePath -Raw
        if (($text -match 'Made by Rafdi D\. Ulhaq') -and ($text -match 'agy-safe\.ps1')) {
            Remove-Item -LiteralPath $safePath -Force
            if (Test-Path -LiteralPath $safeScript) {
                $scriptText = Get-Content -LiteralPath $safeScript -Raw
                if (($scriptText -match 'Made by Rafdi D\. Ulhaq') -and ($scriptText -match 'agy --sandbox')) {
                    Remove-Item -LiteralPath $safeScript -Force
                }
            }
            Write-Status OK "Kit-owned guarded launcher removed."
        } else {
            Write-Status WARN "Launcher is not recognized as kit-owned; leaving it unchanged."
        }
    } else {
        Write-Status SKIP "Kit-owned launcher already absent."
    }
} catch {
    Write-Status FAIL "Launcher rollback failed: $($_.Exception.Message)"
    $errors += "launcher"
}

try {
    $ownerMarker = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\state\academic-pack-installed-by-kit.flag"
    if (-not (Test-Path -LiteralPath $ownerMarker)) {
        Write-Status WARN "Academic pack ownership unknown; leaving plugin installed to prevent data loss."
    } elseif (Test-RafdiAcademicPackInstalled) {
        $output = (& agy plugin uninstall rafdi-academic-research-pack 2>&1 | Out-String)
        $code = $LASTEXITCODE
        if (($code -eq 0) -and (-not (Test-RafdiAcademicPackInstalled))) {
            Remove-Item -LiteralPath $ownerMarker -Force
            Write-Status OK "Kit-owned Academic Research Pack removed."
        } else {
            Write-Status FAIL "Academic pack uninstall failed: $output"
            $errors += "academic pack"
        }
    } else {
        Remove-Item -LiteralPath $ownerMarker -Force
        Write-Status SKIP "Kit-owned Academic Research Pack already absent."
    }
} catch {
    Write-Status FAIL "Academic pack rollback failed: $($_.Exception.Message)"
    $errors += "academic pack"
}

Write-Section "Rollback Result"
if ($errors.Count -eq 0) {
    Write-Status OK "Managed rollback completed without modifying unrelated user data."
    Write-Status INFO "Run REPAIR.bat to restore kit-managed tools if needed."
    exit 0
}
Write-Status FAIL ("Rollback completed with " + $errors.Count + " error(s).")
exit 61
