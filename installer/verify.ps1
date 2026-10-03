[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$Root = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "lib\ui.ps1")
. (Join-Path $PSScriptRoot "lib\ui-rich.ps1")
. (Join-Path $PSScriptRoot "lib\common.ps1")
. (Join-Path $PSScriptRoot "lib\ide.ps1")
. (Join-Path $PSScriptRoot "lib\research-pack.ps1")

$null = Refresh-ProcessPath
$failed = @()

function Require([bool]$Condition, [string]$Ok, [string]$Bad) {
    if ($Condition) {
        Write-Status OK $Ok
    } else {
        Write-Status FAIL $Bad
        $script:failed += $Bad
    }
}

Write-Banner
Write-StepHeader -Number 1 -Total 5 -Title "Read-Only Verification" -Subtitle "Core package health without mutations"

$platform = [System.Environment]::OSVersion.Platform
Require ($platform -eq [System.PlatformID]::Win32NT) "Windows detected." "Windows was not detected."

Require (Test-CommandExists "winget") "WinGet detected." "WinGet is missing."

$packageManifest = Get-Content (Join-Path $Root "config\packages.json") -Raw | ConvertFrom-Json
foreach ($pkg in @($packageManifest.packages)) {
    Require (Test-WingetPackageInstalled -Id ([string]$pkg.id)) "$($pkg.name) installed." "$($pkg.name) is missing."
}

Write-StepHeader -Number 2 -Total 5 -Title "IDE Experience" -Subtitle "Extensions and selected appearance"

$ideManifest = Get-Content (Join-Path $Root "config\ide.json") -Raw | ConvertFrom-Json
$ideCli = Get-AntigravityIdeCli
Require ([bool]$ideCli) "Antigravity IDE CLI detected." "Antigravity IDE CLI is missing."

foreach ($ext in @($ideManifest.extensions)) {
    Require (Test-IdeExtensionInstalled -ExtensionId ([string]$ext.id)) "$($ext.name) installed." "$($ext.name) is missing."
}

$ideSettings = Join-Path $env:APPDATA "Antigravity IDE\User\settings.json"
if (Test-Path -LiteralPath $ideSettings) {
    try {
        $obj = Get-Content -LiteralPath $ideSettings -Raw | ConvertFrom-Json
        Require ($obj.'workbench.colorTheme' -eq $ideManifest.settings.'workbench.colorTheme') "Tokyo Night Storm selected." "Expected Tokyo Night Storm is not selected."
        Require ($obj.'workbench.iconTheme' -eq $ideManifest.settings.'workbench.iconTheme') "Material Icon Theme selected." "Expected Material Icon Theme is not selected."
    } catch {
        Write-Status FAIL "IDE settings could not be parsed safely."
        $failed += "IDE settings parse failure"
    }
} else {
    Write-Status FAIL "Antigravity IDE settings file is missing."
    $failed += "IDE settings missing"
}

Write-StepHeader -Number 3 -Total 5 -Title "Safety Defaults" -Subtitle "Sandbox, permission flow, and safe launcher"

$safety = Test-AgySafetyCapabilities
Require $safety.Success "agy safety flags verified." "agy safety capabilities were not verified."

$cliSettings = Join-Path $env:USERPROFILE ".gemini\antigravity-cli\settings.json"
if (Test-Path -LiteralPath $cliSettings) {
    try {
        $cliObj = Get-Content -LiteralPath $cliSettings -Raw | ConvertFrom-Json
        Require ($cliObj.enableTerminalSandbox -eq $true) "Persistent terminal sandbox enabled." "Persistent terminal sandbox is not enabled."
    } catch {
        Write-Status FAIL "Antigravity CLI settings could not be parsed safely."
        $failed += "CLI settings parse failure"
    }
} else {
    Write-Status FAIL "Antigravity CLI settings file is missing."
    $failed += "CLI settings missing"
}

$safePath = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\bin\agy-safe.cmd"
if (Test-Path -LiteralPath $safePath) {
    $safeText = Get-Content -LiteralPath $safePath -Raw
    Require (($safeText -match "agy --sandbox") -and ($safeText -notmatch "dangerously-skip-permissions")) "agy-safe launcher is permission-first." "agy-safe launcher content is unsafe or invalid."
} else {
    Write-Status FAIL "agy-safe launcher is missing."
    $failed += "agy-safe missing"
}

$managedBin = Split-Path -Parent $safePath
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathEntries = @($userPath -split ";" | ForEach-Object { $_.TrimEnd("\") })
Require ($pathEntries -contains $managedBin.TrimEnd("\")) "agy-safe is available on user PATH." "Managed agy-safe bin is not registered on user PATH."

Write-StepHeader -Number 4 -Total 5 -Title "Rafdi Academic Research Pack" -Subtitle "Academic skills and native pack validation"

Require (Test-RafdiAcademicPackInstalled) "Academic pack installed." "Academic pack is not installed."

$packSource = Get-RafdiAcademicPackSource -Root $Root
$valid = Test-RafdiAcademicPackValid -Source $packSource
Require $valid.Success "Bundled academic pack validates natively." "Bundled academic pack validation failed."

Write-StepHeader -Number 5 -Total 5 -Title "Verification Result" -Subtitle "Final readiness decision"

if ($failed.Count -eq 0) {
    Write-Status OK "All required components passed."
    $verificationDetails = @(
        "Antigravity + IDE + CLI verified",
        "Tokyo Night Storm + Material Icon Theme verified",
        "Sandbox + permission-first defaults verified",
        "Rafdi Academic Research Pack verified"
    )
    Write-CompletionCard -Title "Ready for Local Academic Work" -Subtitle "Verification passed. Your research environment is healthy." -Details $verificationDetails -State Success
    exit 0
}

Write-Status FAIL ("Incomplete checks: " + $failed.Count)
foreach ($item in $failed) {
    Write-Host ("    - " + $item) -ForegroundColor Red
}
exit 40
