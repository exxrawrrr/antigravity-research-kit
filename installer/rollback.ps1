[CmdletBinding()]
param([switch]$ConfirmRollback)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $ConfirmRollback) {
    Write-Host "Rollback requires explicit confirmation." -ForegroundColor Red
    Write-Host "Use ROLLBACK-MANAGED-SETUP.bat instead." -ForegroundColor Yellow
    exit 60
}

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "lib\ui.ps1")
. (Join-Path $PSScriptRoot "lib\research-pack.ps1")

Write-Banner
Write-Section "Managed Rollback"
Write-Status INFO "Core Antigravity apps and third-party IDE extensions will NOT be uninstalled."

$errors = @()

function Restore-LatestFileBackup {
    param([string]$Target,[string]$SearchDirectory,[string]$Filter,[string]$Label)
    $backup = Get-ChildItem -LiteralPath $SearchDirectory -Filter $Filter -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $backup) {
        Write-Status WARN "No managed backup found for $Label; leaving current value unchanged."
        return
    }
    Copy-Item -LiteralPath $backup.FullName -Destination $Target -Force
    Write-Status OK "$Label restored from $($backup.Name)."
}

try {
    $ideDir = Join-Path $env:APPDATA "Antigravity IDE\User"
    Restore-LatestFileBackup -Target (Join-Path $ideDir "settings.json") -SearchDirectory $ideDir -Filter "settings.json.backup-*" -Label "Antigravity IDE settings"
} catch { Write-Status FAIL "IDE settings restore failed: $($_.Exception.Message)"; $errors += "IDE settings" }

try {
    $cliDir = Join-Path $env:USERPROFILE ".gemini\antigravity-cli"
    Restore-LatestFileBackup -Target (Join-Path $cliDir "settings.json") -SearchDirectory $cliDir -Filter "settings.json.backup-*" -Label "Antigravity CLI settings"
} catch { Write-Status FAIL "CLI settings restore failed: $($_.Exception.Message)"; $errors += "CLI settings" }

try {
    $pathBackupDir = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\backups"
    $pathBackup = Get-ChildItem -LiteralPath $pathBackupDir -Filter "user-path-*.txt" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($pathBackup) {
        $previousPath = (Get-Content -LiteralPath $pathBackup.FullName -Raw).TrimEnd([char]13,[char]10)
        [Environment]::SetEnvironmentVariable("Path", $previousPath, "User")
        Write-Status OK "User PATH restored from $($pathBackup.Name)."
    } else { Write-Status WARN "No managed user PATH backup found; PATH left unchanged." }
} catch { Write-Status FAIL "User PATH restore failed: $($_.Exception.Message)"; $errors += "User PATH" }

try {
    $safePath = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\bin\agy-safe.cmd"
    if (Test-Path -LiteralPath $safePath) {
        $safeText = Get-Content -LiteralPath $safePath -Raw
        if (($safeText -match "Made by Rafdi D\. Ulhaq") -and ($safeText -match "agy --sandbox")) {
            Remove-Item -LiteralPath $safePath -Force
            Write-Status OK "Managed agy-safe launcher removed."
        } else { Write-Status WARN "agy-safe exists but is not recognized as installer-owned; not removed." }
    } else { Write-Status SKIP "Managed agy-safe launcher already absent." }
} catch { Write-Status FAIL "agy-safe removal failed: $($_.Exception.Message)"; $errors += "agy-safe" }

try {
    if (Test-RafdiAcademicPackInstalled) {
        $oldPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        $output = (& agy plugin uninstall rafdi-academic-research-pack 2>&1 | Out-String)
        $code = $LASTEXITCODE
        $ErrorActionPreference = $oldPreference
        if (($code -eq 0) -and (-not (Test-RafdiAcademicPackInstalled))) {
            Write-Status OK "Rafdi Academic Research Pack uninstalled."
        } else { Write-Status FAIL "Academic pack uninstall failed: $output"; $errors += "academic pack" }
    } else { Write-Status SKIP "Rafdi Academic Research Pack already absent." }
} catch { Write-Status FAIL "Academic pack rollback failed: $($_.Exception.Message)"; $errors += "academic pack" }

Write-Section "Rollback Result"
if ($errors.Count -eq 0) {
    Write-Status OK "Managed customization rollback completed."
    Write-Status INFO "Run REPAIR.bat to apply the kit again."
    exit 0
}
Write-Status FAIL ("Rollback completed with " + $errors.Count + " error(s).")
exit 61
