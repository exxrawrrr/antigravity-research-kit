Set-StrictMode -Version Latest

try {
    [Console]::InputEncoding = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
    $global:OutputEncoding = [Console]::OutputEncoding
    & chcp.com 65001 | Out-Null
} catch {}

function Get-RichGlyphs {
    return @{
        Block = [char]0x2588
        Shade = [char]0x2591
        H     = [char]0x2500
        V     = [char]0x2502
        TL    = [char]0x256D
        TR    = [char]0x256E
        BL    = [char]0x2570
        BR    = [char]0x256F
    }
}

function Get-SessionLabel {
    $stack = (Get-PSCallStack | Out-String)
    if ($stack -match 'verify\.ps1') { return 'VERIFY' }
    if ($stack -match 'install\.ps1') { return 'INSTALL' }
    return 'SESSION'
}

function Get-BigBrandLines {
    $g = Get-RichGlyphs
    $B = [string]$g.Block
    $font = @{
        'E' = @('######','##    ','##### ','##    ','######')
        'X' = @('##  ##',' #### ','  ##  ',' #### ','##  ##')
        'R' = @('##### ','##  ##','##### ','## ## ','##  ##')
        'A' = @(' #### ','##  ##','######','##  ##','##  ##')
        'W' = @('##   ##','##   ##','## # ##','#######',' ## ## ')
    }

    $rows = @('','','','','')
    foreach ($row in 0..4) {
        $parts = @()
        foreach ($letter in 'EXXRAWRRR'.ToCharArray()) {
            $parts += $font[[string]$letter][$row].Replace('#',$B)
        }
        $rows[$row] = ($parts -join '  ')
    }
    return $rows
}

function Write-BigBrand {
    $rows = Get-BigBrandLines
    for ($i=0; $i -lt $rows.Count; $i++) {
        $color = if ($i -lt 3) { 'Yellow' } else { 'DarkYellow' }
        Write-Host ('  ' + $rows[$i]) -ForegroundColor $color
    }
}

function Write-RichBox {
    param(
        [string]$Title,
        [string[]]$Lines,
        [string]$TitleColor = 'Yellow'
    )

    Initialize-TerminalUi
    $g = Get-RichGlyphs
    $inner = [Math]::Max(76, $script:UiWidth - 8)
    $rule = [string]$g.H * ($inner + 2)

    Write-Host ('  ' + $g.TL + $rule + $g.TR) -ForegroundColor DarkYellow
    if ($Title) {
        Write-Host ('  ' + $g.V + ' ') -NoNewline -ForegroundColor DarkYellow
        Write-Host $Title.ToUpperInvariant().PadRight($inner) -NoNewline -ForegroundColor $TitleColor
        Write-Host (' ' + $g.V) -ForegroundColor DarkYellow
    }
    foreach ($line in $Lines) {
        Write-Host ('  ' + $g.V + ' ') -NoNewline -ForegroundColor DarkYellow
        Write-Host $line.PadRight($inner) -NoNewline -ForegroundColor White
        Write-Host (' ' + $g.V) -ForegroundColor DarkYellow
    }
    Write-Host ('  ' + $g.BL + $rule + $g.BR) -ForegroundColor DarkYellow
}

function Write-Banner {
    Initialize-TerminalUi
    Clear-Host
    Write-Host ''
    Write-BigBrand
    Write-Host ''
    Write-Host '  ANTIGRAVITY x RESEARCH SKILL INSTALLER' -ForegroundColor Yellow
    Write-Host '  made by Rafdi D. Ulhaq' -ForegroundColor DarkYellow
    Write-Host '  local academic AI setup  |  skripsi  |  thesis  |  dissertation' -ForegroundColor Gray
    Write-Host ''

    $session = Get-SessionLabel
    Write-RichBox -Title ('SESSION  ' + $session) -Lines @(
        'DO NOT CLOSE THIS WINDOW UNTIL THE PROCESS IS COMPLETE.',
        'Safety: permission-first  |  sandboxed terminal  |  no credential copying'
    )
}

function Write-StepHeader {
    param(
        [int]$Number,
        [int]$Total,
        [string]$Title,
        [string]$Subtitle = ''
    )

    Initialize-TerminalUi
    $g = Get-RichGlyphs
    $percent = [Math]::Min(100, [Math]::Round((([Math]::Max(0,$Number-1)) / [Math]::Max(1,$Total)) * 100))

    Write-Host ''
    Write-Host '  ' -NoNewline
    Write-Host ('STEP {0:D2}/{1:D2}' -f $Number,$Total) -NoNewline -ForegroundColor Yellow
    Write-Host '  ' -NoNewline
    Write-Host $Title.ToUpperInvariant() -ForegroundColor White
    if ($Subtitle) { Write-Host ('  ' + $Subtitle) -ForegroundColor Gray }

    $barWidth = 34
    $filled = [Math]::Floor(($percent / 100) * $barWidth)
    $empty = $barWidth - $filled
    Write-Host '  overall  [' -NoNewline -ForegroundColor DarkGray
    if ($filled -gt 0) { Write-Host ([string]$g.Block * $filled) -NoNewline -ForegroundColor Yellow }
    if ($empty -gt 0) { Write-Host ([string]$g.Shade * $empty) -NoNewline -ForegroundColor DarkGray }
    Write-Host ('] {0,3}%' -f $percent) -ForegroundColor DarkYellow
    Write-Host ('  ' + ([string]$g.H * [Math]::Max(24,$script:UiWidth-2))) -ForegroundColor DarkGray
}

function Write-ProgressLine {
    param([int]$Done,[int]$Total)
    if ($Total -le 0) { return }

    $g = Get-RichGlyphs
    $percent = [Math]::Min(100,[Math]::Round(($Done / $Total) * 100))
    $width = 30
    $filled = [Math]::Floor(($percent / 100) * $width)
    $empty = $width - $filled

    Write-Host '  package  [' -NoNewline -ForegroundColor DarkGray
    if ($filled -gt 0) { Write-Host ([string]$g.Block * $filled) -NoNewline -ForegroundColor Yellow }
    if ($empty -gt 0) { Write-Host ([string]$g.Shade * $empty) -NoNewline -ForegroundColor DarkGray }
    Write-Host ('] {0,3}%  ({1}/{2})' -f $percent,$Done,$Total) -ForegroundColor DarkYellow
}

function Write-CompletionCard {
    param(
        [string]$Title,
        [string]$Subtitle,
        [string[]]$Details = @(),
        [ValidateSet('Success','Warning','Failure')]
        [string]$State = 'Success'
    )

    $g = Get-RichGlyphs
    Write-Host '  overall  [' -NoNewline -ForegroundColor DarkGray
    Write-Host ([string]$g.Block * 34) -NoNewline -ForegroundColor Yellow
    Write-Host '] 100%' -ForegroundColor DarkYellow

    $titleColor = switch ($State) {
        'Success' { 'Green' }
        'Warning' { 'DarkYellow' }
        'Failure' { 'Red' }
    }
    Write-Host ''
    Write-RichBox -Title $Title -Lines (@($Subtitle) + $Details + @('made by Rafdi D. Ulhaq')) -TitleColor $titleColor
}

function Write-ActionPanel {
    param(
        [string]$Title,
        [string[]]$Items
    )
    Write-Host ''
    Write-RichBox -Title $Title -Lines $Items
}
