# Windows acceptance: a real CLI safety check and non-destructive rollback.
# Runs only on the disposable GitHub Actions Windows runner.
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert([bool]$Ok, [string]$Message) {
    if (-not $Ok) { throw "FRIENDS_REGRESSION_FAIL: $Message" }
    Write-Host "PASS: $Message"
}

$safeCmd = Join-Path $env:LOCALAPPDATA 'Rafdi\AntigravityResearchKit\bin\agy-safe.cmd'
Assert (Test-Path -LiteralPath $safeCmd) 'Guarded launcher is installed'

$output = (& $safeCmd --dangerously-skip-permissions 2>&1 | Out-String)
$blockedExit = $LASTEXITCODE
Assert ($blockedExit -eq 64) "Dangerous CLI flag is blocked (exit=$blockedExit)"
Assert ($output -match '\[BLOCKED\]') 'Unsafe invocation explains the block'

# Simulate legitimate user changes made after installing the kit.
$userNote = 'C:\EXXRAWRRR_USER_ADDED_AFTER_SETUP'
$pathBefore = [Environment]::GetEnvironmentVariable('Path','User')
[Environment]::SetEnvironmentVariable('Path', ($pathBefore.TrimEnd(';') + ';' + $userNote), 'User')

$ideDir = Join-Path $env:APPDATA 'Antigravity IDE\User'
$ideSettings = Join-Path $ideDir 'settings.json'
Assert (Test-Path -LiteralPath $ideSettings) 'IDE settings exist'
$ide = Get-Content -LiteralPath $ideSettings -Raw | ConvertFrom-Json
$ide | Add-Member -NotePropertyName 'friendCustomSetting' -NotePropertyValue 'keep-me' -Force
$ide | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $ideSettings -Encoding UTF8
Set-Content -LiteralPath (Join-Path $ideDir 'settings.json.backup-ci-friends') -Value '{"workbench.colorTheme":"Solarized Dark","workbench.iconTheme":"other-icons"}' -Encoding UTF8

$cliDir = Join-Path $env:USERPROFILE '.gemini\antigravity-cli'
$cliSettings = Join-Path $cliDir 'settings.json'
Assert (Test-Path -LiteralPath $cliSettings) 'CLI settings exist'
$cli = Get-Content -LiteralPath $cliSettings -Raw | ConvertFrom-Json
$cli | Add-Member -NotePropertyName 'friendCustomSetting' -NotePropertyValue 'keep-me' -Force
$cli | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $cliSettings -Encoding UTF8
Set-Content -LiteralPath (Join-Path $cliDir 'settings.json.backup-ci-friends') -Value '{"enableTerminalSandbox":false}' -Encoding UTF8

& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\installer\rollback.ps1 -ConfirmRollback
Assert ($LASTEXITCODE -eq 0) 'Managed rollback finishes successfully'

$afterPath = [Environment]::GetEnvironmentVariable('Path','User')
Assert (@($afterPath -split ';') -contains $userNote) 'PATH entry added by friend after install is retained'
$managedBin = Join-Path $env:LOCALAPPDATA 'Rafdi\AntigravityResearchKit\bin'
Assert (-not (@($afterPath -split ';') -contains $managedBin)) 'Only kit-managed PATH entry was removed'

$ideAfter = Get-Content -LiteralPath $ideSettings -Raw | ConvertFrom-Json
$cliAfter = Get-Content -LiteralPath $cliSettings -Raw | ConvertFrom-Json
Assert ($ideAfter.friendCustomSetting -eq 'keep-me') 'Unrelated IDE setting survives rollback'
Assert ($cliAfter.friendCustomSetting -eq 'keep-me') 'Unrelated CLI setting survives rollback'
Assert ($ideAfter.'workbench.colorTheme' -eq 'Solarized Dark') 'Only kit-managed IDE theme restored'
Assert ($cliAfter.enableTerminalSandbox -eq $false) 'Only kit-managed CLI sandbox setting restored'

# A repair must restore the managed setup without erasing friend-added changes.
& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\installer\install.ps1 -NoPause
Assert ($LASTEXITCODE -eq 0) 'Reinstall after rollback passes'
& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File .\installer\verify.ps1
Assert ($LASTEXITCODE -eq 0) 'Post-repair verifier passes'
Assert (@([Environment]::GetEnvironmentVariable('Path','User') -split ';') -contains $userNote) 'Friend PATH entry survives repair'
Write-Host 'FRIENDS_REGRESSION_OK'
