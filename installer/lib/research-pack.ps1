Set-StrictMode -Version Latest

function Get-RafdiAcademicPackSource([string]$Root) {
    return (Join-Path $Root "pack\rafdi-academic-research-pack")
}

function Test-RafdiAcademicPackInstalled {
    if (-not (Get-Command "agy" -ErrorAction SilentlyContinue)) { return $false }
    $text = (& cmd.exe /d /c "agy plugin list 2>&1" | Out-String)
    return ($text -match "(?im)rafdi-academic-research-pack")
}

function Test-RafdiAcademicPackValid([string]$Source) {
    if (-not (Test-Path -LiteralPath $Source)) {
        return @{ Success = $false; ExitCode = 2; Output = "Pack source not found: $Source" }
    }

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = (& agy plugin validate $Source 2>&1 | Out-String)
    $code = $LASTEXITCODE
    $ErrorActionPreference = $oldPreference
    $ok = ($code -eq 0) -and ($output -match "(?i)skills\s*:\s*5 processed")
    return @{ Success = $ok; ExitCode = $code; Output = $output.Trim() }
}

function Install-RafdiAcademicPack {
    param(
        [string]$Source,
        [switch]$DryRun
    )

    $validation = Test-RafdiAcademicPackValid -Source $Source
    if (-not $validation.Success) {
        return @{ Success = $false; ExitCode = $validation.ExitCode; Output = "Validation failed: $($validation.Output)" }
    }

    if (Test-RafdiAcademicPackInstalled) {
        return @{ Success = $true; ExitCode = 0; Output = "Already installed"; Skipped = $true }
    }

    if ($DryRun) {
        return @{ Success = $true; ExitCode = 0; Output = "DRY-RUN: agy plugin install $Source"; Skipped = $false }
    }

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $output = (& agy plugin install $Source 2>&1 | Out-String)
    $code = $LASTEXITCODE
    $ErrorActionPreference = $oldPreference
    $installed = Test-RafdiAcademicPackInstalled
    if ($installed -and ($code -eq 0)) {
        $stateDir = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\state"
        New-Item -ItemType Directory -Force -Path $stateDir | Out-Null
        Set-Content -LiteralPath (Join-Path $stateDir "academic-pack-installed-by-kit.flag") -Value "Installed by Antigravity Research Kit" -Encoding ASCII
    }

    return @{ Success = ($installed -and ($code -eq 0)); ExitCode = $code; Output = $output.Trim(); Skipped = $false }
}
