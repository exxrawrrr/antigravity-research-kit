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

    # Windows machines sometimes have a missing/stale WinGet source cache.
    # A regular source update is safe; never reset a user's configured sources automatically.
    if ($code -eq -1978335217) {
        $refresh = (& winget source update --name winget --disable-interactivity 2>&1 | Out-String)
        $refreshCode = $LASTEXITCODE
        $output += " WinGet source refresh exit=$refreshCode : $refresh"
        if ($refreshCode -eq 0) {
            $retry = (& winget install --id $Id --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Out-String)
            $code = $LASTEXITCODE
            $output += " Retry exit=$code : $retry"
        }
    }
    return @{ Success = ($code -eq 0); ExitCode = $code; Output = $output.Trim() }
}

function Get-FreeSystemDriveGB {
    $drive = Get-PSDrive -Name $env:SystemDrive.TrimEnd(":") -ErrorAction Stop
    return [Math]::Round(($drive.Free / 1GB), 2)
}

function Ensure-UserPathEntry {
    param(
        [string]$Entry,
        [switch]$DryRun
    )

    $full = [System.IO.Path]::GetFullPath($Entry).TrimEnd("\")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($null -eq $userPath) { $userPath = "" }

    $entries = @($userPath -split ";" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $exists = $false
    foreach ($item in $entries) {
        try {
            if ([System.IO.Path]::GetFullPath($item).TrimEnd("\") -ieq $full) {
                $exists = $true
                break
            }
        } catch {}
    }

    if ($exists) {
        return @{ Success = $true; Changed = $false; Backup = $null; Output = "PATH entry already present" }
    }

    if ($DryRun) {
        return @{ Success = $true; Changed = $false; Backup = $null; Output = "DRY-RUN: append user PATH $full" }
    }

    $backupRoot = Join-Path $env:LOCALAPPDATA "Rafdi\AntigravityResearchKit\backups"
    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    $backup = Join-Path $backupRoot ("user-path-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".txt")
    Set-Content -LiteralPath $backup -Value $userPath -Encoding UTF8

    $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $full } else { $userPath.TrimEnd(";") + ";" + $full }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    if (($env:Path -split ";") -notcontains $full) { $env:Path = $env:Path.TrimEnd(";") + ";" + $full }

    return @{ Success = $true; Changed = $true; Backup = $backup; Output = "User PATH updated" }
}


function Refresh-ProcessPath {
    $all = New-Object System.Collections.Generic.List[string]
    $seen = @{}

    foreach ($source in @(
        $env:Path,
        [Environment]::GetEnvironmentVariable("Path", "Machine"),
        [Environment]::GetEnvironmentVariable("Path", "User")
    )) {
        if ([string]::IsNullOrWhiteSpace($source)) { continue }
        foreach ($entry in ($source -split ";")) {
            $trimmed = $entry.Trim()
            if ([string]::IsNullOrWhiteSpace($trimmed)) { continue }
            $key = $trimmed.TrimEnd("\").ToLowerInvariant()
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true
                $all.Add($trimmed)
            }
        }
    }

    $env:Path = ($all -join ";")
    return $env:Path
}
