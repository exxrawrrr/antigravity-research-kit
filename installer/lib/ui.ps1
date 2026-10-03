Set-StrictMode -Version Latest

$script:UiWidth = 128
$script:UiInitialized = $false

function Initialize-TerminalUi {
    if ($script:UiInitialized) { return }

    try {
        $Host.UI.RawUI.WindowTitle = "exxrawrrr - Antigravity Research Installer"
        $Host.UI.RawUI.BackgroundColor = "Black"
        $Host.UI.RawUI.ForegroundColor = "Gray"

        $raw = $Host.UI.RawUI
        $max = $raw.MaxPhysicalWindowSize.Width
        if ($max -gt 0) {
            $target = [Math]::Min(148, [Math]::Max(112, $max))
            if ($raw.BufferSize.Width -lt $target) {
                $buffer = $raw.BufferSize
                $buffer.Width = $target
                $raw.BufferSize = $buffer
            }
            if ($raw.WindowSize.Width -lt $target) {
                $window = $raw.WindowSize
                $window.Width = [Math]::Min($target, $raw.MaxPhysicalWindowSize.Width)
                $raw.WindowSize = $window
            }
            $script:UiWidth = [Math]::Max(96, [Math]::Min(144, $raw.WindowSize.Width - 4))
        }
    } catch {
        $script:UiWidth = 128
    }

    $script:UiInitialized = $true
}

function Get-UiRule {
    param([string]$Char = "-", [int]$Inset = 2)
    $width = [Math]::Max(24, $script:UiWidth - $Inset)
    return ($Char * $width)
}

function Write-BigBrand {
    $brand = @(
        " _______  __   __  __   __  ______    _______  _       _  ______    ______    ______   ",
        "|  _____| \ \ / /  \ \ / / |  __  \  |   _   || |     | ||  __  \  |  __  \  |  __  \  ",
        "| |____    \ V /    \ V /  | |__) | | |_| | || |  _  | || |__) | | |__) | | |__) | ",
        "|  ____|   /   \     > <   |  _  /  |  _  | || | | | | ||  _  /  |  _  /  |  _  /  ",
        "| |_____  / /^\ \   / /^\ \ | | \ \  | | | | || |_| |_| || | \ \  | | \ \  | | \ \  ",
        "|_______|/_/   \_\ /_/   \_\|_|  \_\ |_| |_| | \_______/ |_|  \_\ |_|  \_\ |_|  \_\ "
    )

    foreach ($line in $brand) {
        Write-Host ("  " + $line) -ForegroundColor Yellow
    }
}

function Write-Banner {
    Initialize-TerminalUi
    Clear-Host

    Write-Host ""
    Write-Host ("  +" + (Get-UiRule -Char "=" -Inset 4) + "+") -ForegroundColor DarkYellow
    Write-Host ""
    Write-BigBrand
    Write-Host ""
    Write-Host "  ANTIGRAVITY x RESEARCH SKILL INSTALLER" -ForegroundColor DarkYellow
    Write-Host "  made by Rafdi D. Ulhaq" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  local academic AI setup for skripsi / thesis / dissertation" -ForegroundColor DarkGray
    Write-Host "  Windows  |  local-first  |  permission-first  |  research-ready" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host ("  +" + (Get-UiRule -Char "=" -Inset 4) + "+") -ForegroundColor DarkYellow
    Write-Host ""

    Write-Host "  [!] " -NoNewline -ForegroundColor Yellow
    Write-Host "DO NOT CLOSE THIS WINDOW UNTIL THE PROCESS IS COMPLETE." -ForegroundColor Red
    Write-Host "      Live installer status will continue below." -ForegroundColor Gray
}

function Write-Section([string]$Title) {
    Initialize-TerminalUi
    Write-Host ""
    Write-Host "  >> " -NoNewline -ForegroundColor DarkYellow
    Write-Host $Title.ToUpperInvariant() -NoNewline -ForegroundColor Yellow
    Write-Host " " -NoNewline
    $used = $Title.Length + 7
    Write-Host ("-" * [Math]::Max(12, $script:UiWidth - $used)) -ForegroundColor DarkGray
}

function Write-StepHeader {
    param(
        [int]$Number,
        [int]$Total,
        [string]$Title,
        [string]$Subtitle = ""
    )

    Initialize-TerminalUi
    $percent = [Math]::Min(100, [Math]::Round(($Number / [Math]::Max(1,$Total)) * 100))

    Write-Host ""
    Write-Host "  [" -NoNewline -ForegroundColor DarkGray
    Write-Host ("STEP {0}/{1}" -f $Number,$Total) -NoNewline -ForegroundColor Yellow
    Write-Host "]  " -NoNewline -ForegroundColor DarkGray
    Write-Host $Title.ToUpperInvariant() -ForegroundColor White
    if ($Subtitle) {
        Write-Host ("           " + $Subtitle) -ForegroundColor DarkGray
    }

    $barWidth = 34
    $filled = [Math]::Floor(($percent / 100) * $barWidth)
    $empty = $barWidth - $filled
    Write-Host "  overall  [" -NoNewline -ForegroundColor DarkGray
    if ($filled -gt 0) { Write-Host ("#" * $filled) -NoNewline -ForegroundColor Yellow }
    if ($empty -gt 0) { Write-Host ("." * $empty) -NoNewline -ForegroundColor DarkGray }
    Write-Host ("] {0,3}%" -f $percent) -ForegroundColor DarkYellow
    Write-Host ("  " + (Get-UiRule -Char "-" -Inset 2)) -ForegroundColor DarkGray
}

function Write-Status {
    param(
        [ValidateSet("OK","SKIP","RUN","WARN","FAIL","INFO")]
        [string]$State,
        [string]$Message
    )

    $map = @{
        OK   = @{ Tag = "[ OK ]"; Color = "Green" }
        SKIP = @{ Tag = "[SKIP]"; Color = "DarkGreen" }
        RUN  = @{ Tag = "[RUN ]"; Color = "Yellow" }
        WARN = @{ Tag = "[WARN]"; Color = "DarkYellow" }
        FAIL = @{ Tag = "[FAIL]"; Color = "Red" }
        INFO = @{ Tag = "[INFO]"; Color = "Gray" }
    }

    $entry = $map[$State]
    Write-Host "  " -NoNewline
    Write-Host $entry.Tag -NoNewline -ForegroundColor $entry.Color
    Write-Host "  " -NoNewline
    Write-Host $Message -ForegroundColor White
}

function Write-ProgressLine([int]$Done, [int]$Total) {
    if ($Total -le 0) { return }

    $percent = [Math]::Min(100, [Math]::Round(($Done / $Total) * 100))
    $width = 30
    $filled = [Math]::Floor(($percent / 100) * $width)
    $empty = $width - $filled

    Write-Host "  package  [" -NoNewline -ForegroundColor DarkGray
    if ($filled -gt 0) { Write-Host ("#" * $filled) -NoNewline -ForegroundColor Yellow }
    if ($empty -gt 0) { Write-Host ("." * $empty) -NoNewline -ForegroundColor DarkGray }
    Write-Host ("] {0,3}%  ({1}/{2})" -f $percent,$Done,$Total) -ForegroundColor DarkYellow
}

function Write-CompletionCard {
    param(
        [string]$Title,
        [string]$Subtitle,
        [string[]]$Details = @(),
        [ValidateSet("Success","Warning","Failure")]
        [string]$State = "Success"
    )

    Initialize-TerminalUi
    $color = switch ($State) {
        "Success" { "Green" }
        "Warning" { "DarkYellow" }
        "Failure" { "Red" }
    }

    $inner = [Math]::Max(76, $script:UiWidth - 8)
    $rule = "=" * $inner

    Write-Host ""
    Write-Host ("  +" + $rule + "+") -ForegroundColor DarkYellow
    Write-Host "  |" -NoNewline -ForegroundColor DarkYellow
    Write-Host ("  " + $Title.ToUpperInvariant()).PadRight($inner) -NoNewline -ForegroundColor $color
    Write-Host "|" -ForegroundColor DarkYellow
    Write-Host "  |" -NoNewline -ForegroundColor DarkYellow
    Write-Host ("  " + $Subtitle).PadRight($inner) -NoNewline -ForegroundColor White
    Write-Host "|" -ForegroundColor DarkYellow
    foreach ($detail in $Details) {
        Write-Host "  |" -NoNewline -ForegroundColor DarkYellow
        Write-Host ("  " + $detail).PadRight($inner) -NoNewline -ForegroundColor Gray
        Write-Host "|" -ForegroundColor DarkYellow
    }
    Write-Host "  |" -NoNewline -ForegroundColor DarkYellow
    Write-Host ("  made by Rafdi D. Ulhaq").PadRight($inner) -NoNewline -ForegroundColor DarkYellow
    Write-Host "|" -ForegroundColor DarkYellow
    Write-Host ("  +" + $rule + "+") -ForegroundColor DarkYellow
}

function Write-ActionPanel {
    param(
        [string]$Title,
        [string[]]$Items
    )

    Initialize-TerminalUi
    $inner = [Math]::Max(76, $script:UiWidth - 8)
    $rule = "-" * $inner

    Write-Host ""
    Write-Host ("  +" + $rule + "+") -ForegroundColor DarkYellow
    Write-Host "  |" -NoNewline -ForegroundColor DarkYellow
    Write-Host ("  " + $Title.ToUpperInvariant()).PadRight($inner) -NoNewline -ForegroundColor Yellow
    Write-Host "|" -ForegroundColor DarkYellow
    foreach ($item in $Items) {
        Write-Host "  |" -NoNewline -ForegroundColor DarkYellow
        Write-Host ("  " + $item).PadRight($inner) -NoNewline -ForegroundColor White
        Write-Host "|" -ForegroundColor DarkYellow
    }
    Write-Host ("  +" + $rule + "+") -ForegroundColor DarkYellow
}
