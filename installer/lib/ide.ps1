Set-StrictMode -Version Latest

function Get-AntigravityIdeCli {
    $expected = Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE\bin\antigravity-ide.cmd"
    if (Test-Path -LiteralPath $expected) { return $expected }

    $cmd = Get-Command "antigravity-ide.cmd" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    return $null
}

function Test-IdeExtensionInstalled([string]$ExtensionId) {
    $root = Join-Path $env:USERPROFILE ".antigravity-ide\extensions"
    if (-not (Test-Path -LiteralPath $root)) { return $false }
    return [bool](Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like ($ExtensionId.ToLowerInvariant() + "-*") } |
        Select-Object -First 1)
}

function Install-IdeExtension {
    param(
        [string]$Cli,
        [string]$ExtensionId,
        [switch]$DryRun
    )

    if ($DryRun) {
        return @{ Success = $true; ExitCode = 0; Output = "DRY-RUN: install extension $ExtensionId" }
    }

    $output = (& $Cli --install-extension $ExtensionId --force 2>&1 | Out-String)
    $code = $LASTEXITCODE
    $installed = Test-IdeExtensionInstalled -ExtensionId $ExtensionId
    return @{ Success = $installed; ExitCode = $code; Output = $output.Trim() }
}

function Set-JsonProperty {
    param([object]$Object, [string]$Name, [object]$Value)
    if ($Object.PSObject.Properties.Name -contains $Name) {
        $Object.$Name = $Value
    } else {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

function Set-AntigravityIdeExperience {
    param(
        [hashtable]$Desired,
        [switch]$DryRun
    )

    $settingsDir = Join-Path $env:APPDATA "Antigravity IDE\User"
    $settingsPath = Join-Path $settingsDir "settings.json"

    if ($DryRun) {
        return @{ Success = $true; Changed = $false; Path = $settingsPath; Backup = $null; Output = "DRY-RUN: set IDE theme/icon settings" }
    }

    New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null

    if (Test-Path -LiteralPath $settingsPath) {
        try {
            $obj = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
        } catch {
            return @{ Success = $false; Changed = $false; Path = $settingsPath; Backup = $null; Output = "Refused to rewrite non-JSON settings file: $($_.Exception.Message)" }
        }
    } else {
        $obj = [pscustomobject]@{}
    }

    $needsChange = $false
    foreach ($key in $Desired.Keys) {
        if (($obj.PSObject.Properties.Name -notcontains $key) -or ($obj.$key -ne $Desired[$key])) {
            $needsChange = $true
            break
        }
    }

    if (-not $needsChange) {
        return @{ Success = $true; Changed = $false; Path = $settingsPath; Backup = $null; Output = "IDE experience already configured" }
    }

    $backup = $null
    if (Test-Path -LiteralPath $settingsPath) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "$settingsPath.backup-$stamp"
        Copy-Item -LiteralPath $settingsPath -Destination $backup -Force
    }

    foreach ($key in $Desired.Keys) {
        Set-JsonProperty -Object $obj -Name $key -Value $Desired[$key]
    }

    $json = $obj | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $settingsPath -Value $json -Encoding UTF8

    return @{ Success = $true; Changed = $true; Path = $settingsPath; Backup = $backup; Output = "IDE experience updated" }
}
function Test-AgySafetyCapabilities {
    if (-not (Get-Command "agy" -ErrorAction SilentlyContinue)) {
        return @{ Success = $false; Sandbox = $false; PermissionGuard = $false; Output = "agy command not found" }
    }

    $help = (& cmd.exe /d /c "agy --help 2>&1" | Out-String)
    $sandbox = $help -match "(?m)^\s*--sandbox\s"
    $danger = $help -match "(?m)^\s*--dangerously-skip-permissions\s"

    return @{
        Success = ($sandbox -and $danger)
        Sandbox = $sandbox
        PermissionGuard = $danger
        Output = "sandbox=$sandbox dangerous-skip-flag=$danger"
    }
}

function Install-AgySafeLauncher {
    param([switch]$DryRun)

    $bin = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\bin"
    $path = Join-Path $bin "agy-safe.cmd"
    $content = "@echo off`r`nREM Made by Rafdi D. Ulhaq`r`nagy --sandbox %*`r`n"

    if ($DryRun) {
        return @{ Success = $true; Path = $path; Changed = $false; Output = "DRY-RUN: create agy-safe.cmd" }
    }

    if (Test-Path -LiteralPath $path) {
        $existing = Get-Content -LiteralPath $path -Raw
        if ($existing -eq $content) {
            return @{ Success = $true; Path = $path; Changed = $false; Output = "Safe CLI launcher already correct" }
        }
    }

    New-Item -ItemType Directory -Force -Path $bin | Out-Null
    Set-Content -LiteralPath $path -Value $content -Encoding ASCII

    return @{ Success = (Test-Path -LiteralPath $path); Path = $path; Changed = $true; Output = "Safe CLI launcher created" }
}
function Set-AgySandboxPersistent {
    param([switch]$DryRun)

    $settingsDir = Join-Path $env:USERPROFILE ".gemini\antigravity-cli"
    $settingsPath = Join-Path $settingsDir "settings.json"

    if ($DryRun) {
        return @{ Success = $true; Changed = $false; Path = $settingsPath; Backup = $null; Output = "DRY-RUN: enableTerminalSandbox=true" }
    }

    New-Item -ItemType Directory -Force -Path $settingsDir | Out-Null

    if (Test-Path -LiteralPath $settingsPath) {
        try {
            $obj = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
        } catch {
            return @{ Success = $false; Changed = $false; Path = $settingsPath; Backup = $null; Output = "Refused to rewrite non-JSON CLI settings: $($_.Exception.Message)" }
        }

        if (($obj.PSObject.Properties.Name -contains "enableTerminalSandbox") -and ($obj.enableTerminalSandbox -eq $true)) {
            return @{ Success = $true; Changed = $false; Path = $settingsPath; Backup = $null; Output = "enableTerminalSandbox already true" }
        }
    } else {
        $obj = [pscustomobject]@{}
    }

    $backup = $null
    if (Test-Path -LiteralPath $settingsPath) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backup = "$settingsPath.backup-$stamp"
        Copy-Item -LiteralPath $settingsPath -Destination $backup -Force
    }

    Set-JsonProperty -Object $obj -Name "enableTerminalSandbox" -Value $true
    $json = $obj | ConvertTo-Json -Depth 20
    Set-Content -LiteralPath $settingsPath -Value $json -Encoding UTF8

    return @{ Success = $true; Changed = $true; Path = $settingsPath; Backup = $backup; Output = "enableTerminalSandbox=true" }
}

