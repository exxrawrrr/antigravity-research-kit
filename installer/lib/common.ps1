Set-StrictMode -Version Latest

function New-InstallLog {
    $root = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\logs"
    New-Item -ItemType Directory -Force -Path $root | Out-Null
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    return (Join-Path $root "install-$stamp.log")
}

function Add-InstallLog([string]$Path, [string]$Message) {
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Add-Content -LiteralPath $Path -Value $line -Encoding UTF8
}

function Test-CommandExists([string]$Name) {
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Test-WingetPackageInstalled([string]$Id) {
    $text = (& winget list --id $Id --exact --accept-source-agreements --disable-interactivity 2>&1 | Out-String)
    return ($text -match [regex]::Escape($Id))
}

function Install-WingetPackage {
    param(
        [string]$Id,
        [switch]$DryRun
    )

    if ($DryRun) {
        return @{ Success = $true; ExitCode = 0; Output = "DRY-RUN: winget install $Id" }
    }

    $output = (& winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-String)
    $code = $LASTEXITCODE
    return @{ Success = ($code -eq 0); ExitCode = $code; Output = $output.Trim() }
}

function Get-FreeSystemDriveGB {
    $drive = Get-PSDrive -Name $env:SystemDrive.TrimEnd(":") -ErrorAction Stop
    return [Math]::Round(($drive.Free / 1GB), 2)
}
