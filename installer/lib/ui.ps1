Set-StrictMode -Version Latest

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkYellow
    Write-Host "   EXXRAWRRR :: ANTIGRAVITY RESEARCH KIT" -ForegroundColor Yellow
    Write-Host "   local academic AI setup for skripsi / thesis / dissertation" -ForegroundColor DarkYellow
    Write-Host "   made by Rafdi D. Ulhaq" -ForegroundColor Gray
    Write-Host "  ================================================================" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "   DO NOT CLOSE THIS WINDOW." -ForegroundColor Red
    Write-Host "   The installer will stop only after verification or a clear error." -ForegroundColor Red
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
