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

function Get-AntigravityIdeExe {
    $expected = Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE\Antigravity IDE.exe"
    if (Test-Path -LiteralPath $expected) { return $expected }
    return $null
}

function Initialize-AntigravityIdeProfile {
    $exe = Get-AntigravityIdeExe
    if (-not $exe) {
        return @{ Success = $false; Output = "Antigravity IDE executable not found for profile bootstrap" }
    }

    try {
        $proc = Start-Process -FilePath $exe -ArgumentList @("--disable-extensions","--skip-welcome","--skip-release-notes") -PassThru
        Start-Sleep -Seconds 8
        if (-not $proc.HasExited) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
            $proc.WaitForExit(5000) | Out-Null
        }
        return @{ Success = $true; Output = "Antigravity IDE profile bootstrap attempted" }
    } catch {
        return @{ Success = $false; Output = "Antigravity IDE profile bootstrap failed: $($_.Exception.Message)" }
    }
}

function Invoke-IdeExtensionCommand {
    param(
        [string]$Command,
        [string[]]$Arguments
    )

    $oldPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = (& $Command @Arguments 2>&1 | Out-String)
        $code = $LASTEXITCODE
        return @{ ExitCode = $code; Output = $output.Trim() }
    } catch {
        return @{ ExitCode = 99; Output = $_.Exception.Message }
    } finally {
        $ErrorActionPreference = $oldPreference
    }
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

    $attempts = @()

    $first = Invoke-IdeExtensionCommand -Command $Cli -Arguments @("--install-extension",$ExtensionId,"--force")
    $output = $first.Output
    $code = $first.ExitCode
    $attempts += "CLI exit=$code :: $output"
    if (Test-IdeExtensionInstalled -ExtensionId $ExtensionId) {
        return @{ Success = $true; ExitCode = $code; Output = ($attempts -join " | ") }
    }

    $exe = Get-AntigravityIdeExe
    if ($exe) {
        $exeAttempt = Invoke-IdeExtensionCommand -Command $exe -Arguments @("--install-extension",$ExtensionId,"--force")
        $exeOutput = $exeAttempt.Output
        $exeCode = $exeAttempt.ExitCode
        $attempts += "EXE exit=$exeCode :: $exeOutput"
        if (Test-IdeExtensionInstalled -ExtensionId $ExtensionId) {
            return @{ Success = $true; ExitCode = $exeCode; Output = ($attempts -join " | ") }
        }
    }

    $registrationFailure = (($output -match "NOT registered") -or ($output -match "antigravityAnalytics") -or ($output -match "extensionManagementService"))
    if ($registrationFailure) {
        $bootstrap = Initialize-AntigravityIdeProfile
        $attempts += "BOOTSTRAP :: $($bootstrap.Output)"
        if ($bootstrap.Success) {
            $retryAttempt = Invoke-IdeExtensionCommand -Command $Cli -Arguments @("--install-extension",$ExtensionId,"--force")
            $retry = $retryAttempt.Output
            $retryCode = $retryAttempt.ExitCode
            $attempts += "RETRY exit=$retryCode :: $retry"
            if (Test-IdeExtensionInstalled -ExtensionId $ExtensionId) {
                return @{ Success = $true; ExitCode = $retryCode; Output = ($attempts -join " | ") }
            }
        }
    }

    return @{ Success = $false; ExitCode = $code; Output = ($attempts -join " | ") }
}

function Set-JsonProperty {
    param([object]$Object, [string]$Name, [object]$Value)
    $propertyNames = @($Object.PSObject.Properties | ForEach-Object { $_.Name })
    if ($propertyNames -contains $Name) {
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
    $propertyNames = @($obj.PSObject.Properties | ForEach-Object { $_.Name })
    foreach ($key in $Desired.Keys) {
        if (($propertyNames -notcontains $key) -or ($obj.$key -ne $Desired[$key])) {
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
        Success = $sandbox
        Sandbox = $sandbox
        DangerousFlagAdvertised = $danger
        Output = "sandbox=$sandbox dangerous-skip-flag=$danger"
    }
}

function Install-AgySafeLauncher {
    param([switch]$DryRun)

    $bin = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\bin"
    $path = Join-Path $bin "agy-safe.cmd"
    $scriptPath = Join-Path $bin "agy-safe.ps1"
    $cmdBody = @'
@echo off
setlocal EnableExtensions DisableDelayedExpansion
REM Made by Rafdi D. Ulhaq
:check
if "%~1"=="" goto run
if /I "%~1"=="--dangerously-skip-permissions" goto blocked
if /I "%~1"=="--dangerously-skip-permissions=true" goto blocked
shift
goto check
:blocked
echo [BLOCKED] agy-safe refuses dangerous auto-approval.
exit /b 64
:run
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0agy-safe.ps1" %*
exit /b %ERRORLEVEL%
'@
    $content = (($cmdBody -split '\r?\n') -join [Environment]::NewLine) + [Environment]::NewLine
    $script = @'
# Made by Rafdi D. Ulhaq
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CliArgs
)
$ErrorActionPreference = 'Stop'
foreach ($arg in $CliArgs) {
    if ($arg -match '^(?i:--dangerously-skip-permissions)(?:=.*)?$') {
        [Console]::Error.WriteLine('[BLOCKED] agy-safe refuses dangerous auto-approval.')
        exit 64
    }
}
& agy --sandbox @CliArgs
exit $LASTEXITCODE
'@

    if ($DryRun) {
        return @{ Success = $true; Path = $path; Changed = $false; Output = "DRY-RUN: create guarded agy-safe.cmd and agy-safe.ps1" }
    }

    $unchanged = (Test-Path -LiteralPath $path) -and (Test-Path -LiteralPath $scriptPath)
    if ($unchanged) {
        $unchanged = ((Get-Content -LiteralPath $path -Raw).TrimEnd([char]13,[char]10) -eq $content.TrimEnd([char]13,[char]10)) -and
                     ((Get-Content -LiteralPath $scriptPath -Raw).TrimEnd([char]13,[char]10) -eq $script.TrimEnd([char]13,[char]10))
    }
    if ($unchanged) {
        return @{ Success = $true; Path = $path; Changed = $false; Output = "Guarded safe launcher already correct" }
    }

    New-Item -ItemType Directory -Force -Path $bin | Out-Null
    Set-Content -LiteralPath $scriptPath -Value $script -Encoding ASCII -NoNewline
    Set-Content -LiteralPath $path -Value $content -Encoding ASCII -NoNewline
    return @{ Success = ((Test-Path -LiteralPath $path) -and (Test-Path -LiteralPath $scriptPath)); Path = $path; Changed = $true; Output = "Guarded agy-safe launcher created" }
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

        $propertyNames = @($obj.PSObject.Properties | ForEach-Object { $_.Name })
        if (($propertyNames -contains "enableTerminalSandbox") -and ($obj.enableTerminalSandbox -eq $true)) {
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

