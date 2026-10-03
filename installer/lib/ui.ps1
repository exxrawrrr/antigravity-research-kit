Set-StrictMode -Version Latest

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  EXXRAWRRR" -ForegroundColor Yellow
    Write-Host "  ANTIGRAVITY x RESEARCH SKILL INSTALLER" -ForegroundColor Yellow
    Write-Host "  made by Rafdi D. Ulhaq" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor DarkGray
    Write-Host "  DO NOT CLOSE THIS WINDOW UNTIL INSTALLATION IS COMPLETE." -ForegroundColor Red
    Write-Host "  ============================================================" -ForegroundColor DarkGray
    Write-Host ""
}

function Write-Section([string]$Title) {
    Write-Host ""
    Write-Host ("  " + $Title.ToUpperInvariant()) -ForegroundColor Cyan
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
}

function Write-Status {
    param(
        [ValidateSet("OK","SKIP","RUN","WARN","FAIL","INFO")]
        [string]$State,
        [string]$Message
    )

    $map = @{
        OK   = @{ Tag = "[OK]  "; Color = "Green" }
        SKIP = @{ Tag = "[SKIP]"; Color = "DarkGreen" }
        RUN  = @{ Tag = "[RUN] "; Color = "Yellow" }
        WARN = @{ Tag = "[WARN]"; Color = "DarkYellow" }
        FAIL = @{ Tag = "[FAIL]"; Color = "Red" }
        INFO = @{ Tag = "[INFO]"; Color = "Gray" }
    }

    $entry = $map[$State]
    Write-Host ("  " + $entry.Tag + " ") -NoNewline -ForegroundColor $entry.Color
    Write-Host $Message
}

function Write-ProgressLine([int]$Done, [int]$Total) {
    if ($Total -le 0) { return }
    $percent = [Math]::Min(100, [Math]::Round(($Done / $Total) * 100))
    $width = 32
    $filled = [Math]::Floor(($percent / 100) * $width)
    $bar = ("#" * $filled) + ("-" * ($width - $filled))
    Write-Host ("  Progress: [{0}] {1,3}%" -f $bar, $percent) -ForegroundColor DarkCyan
}
