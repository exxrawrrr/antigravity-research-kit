Set-StrictMode -Version Latest

$script:AnsiEsc = [char]27
$script:TrueColor = [bool]$env:WT_SESSION

$script:Palette = @{
    Gold       = '#FFD35D'
    Gold2      = '#FFC34A'
    Amber      = '#F6B83C'
    Orange     = '#D87938'
    Bronze     = '#99613A'
    Border     = '#8F5C38'
    Cream      = '#E7E1D7'
    Cream2     = '#EEE8DE'
    Muted      = '#AFA79D'
    Muted2     = '#857E76'
    Green      = '#7DD3A7'
    GreenSkip  = '#9FC48D'
    Red        = '#FF6B7A'
    DarkFill   = '#5D4636'
}

function Convert-HexToRgb {
    param([string]$Hex)
    $h = $Hex.TrimStart('#')
    return @(
        [Convert]::ToInt32($h.Substring(0,2),16),
        [Convert]::ToInt32($h.Substring(2,2),16),
        [Convert]::ToInt32($h.Substring(4,2),16)
    )
}

function Write-Tc {
    param(
        [string]$Text,
        [string]$Hex,
        [string]$Fallback = 'White',
        [switch]$NoNewline
    )

    if ($script:TrueColor) {
        $rgb = Convert-HexToRgb $Hex
        $prefix = "$($script:AnsiEsc)[38;2;$($rgb[0]);$($rgb[1]);$($rgb[2])m"
        $reset = "$($script:AnsiEsc)[0m"
        if ($NoNewline) {
            [Console]::Write($prefix + $Text + $reset)
        } else {
            [Console]::WriteLine($prefix + $Text + $reset)
        }
    } else {
        Write-Host $Text -ForegroundColor $Fallback -NoNewline:$NoNewline
    }
}

function Write-BigBrand {
    $rows = Get-BigBrandLines
    $colors = @(
        $script:Palette.Gold,
        $script:Palette.Gold,
        $script:Palette.Gold2,
        $script:Palette.Amber,
        $script:Palette.Orange
    )
    $fallback = @('Yellow','Yellow','Yellow','DarkYellow','DarkYellow')

    for ($i=0; $i -lt $rows.Count; $i++) {
        Write-Tc -Text ('  ' + $rows[$i]) -Hex $colors[$i] -Fallback $fallback[$i]
    }
}

function Write-Banner {
    Initialize-TerminalUi
    Clear-Host
    Write-Host ''

    Write-BigBrand
    Write-Host ''

    Write-Tc -Text '  ANTIGRAVITY x RESEARCH SKILL INSTALLER' -Hex $script:Palette.Gold2 -Fallback 'Yellow'
    Write-Tc -Text '  made by Rafdi D. Ulhaq' -Hex $script:Palette.Cream -Fallback 'Gray'
    Write-Tc -Text '  local academic AI setup  |  skripsi  |  thesis  |  dissertation' -Hex $script:Palette.Muted -Fallback 'DarkGray'
    Write-Host ''

    $g = Get-RichGlyphs
    $inner = [Math]::Max(76, $script:UiWidth - 8)
    $rule = [string]$g.H * ($inner + 2)
    $session = Get-SessionLabel

    Write-Tc -Text ('  ' + $g.TL + $rule + $g.TR) -Hex $script:Palette.Border -Fallback 'DarkYellow'
    Write-Tc -Text ('  ' + $g.V + ' ') -Hex $script:Palette.Border -Fallback 'DarkYellow' -NoNewline
    Write-Tc -Text (('SESSION  ' + $session).PadRight($inner)) -Hex $script:Palette.Gold -Fallback 'Yellow' -NoNewline
    Write-Tc -Text (' ' + $g.V) -Hex $script:Palette.Border -Fallback 'DarkYellow'

    Write-Tc -Text ('  ' + $g.V + ' ') -Hex $script:Palette.Border -Fallback 'DarkYellow' -NoNewline
    Write-Tc -Text ('DO NOT CLOSE THIS WINDOW UNTIL THE PROCESS IS COMPLETE.'.PadRight($inner)) -Hex $script:Palette.Red -Fallback 'Red' -NoNewline
    Write-Tc -Text (' ' + $g.V) -Hex $script:Palette.Border -Fallback 'DarkYellow'

    Write-Tc -Text ('  ' + $g.V + ' ') -Hex $script:Palette.Border -Fallback 'DarkYellow' -NoNewline
    Write-Tc -Text ('Safety: permission-first  |  sandboxed terminal  |  no credential copying'.PadRight($inner)) -Hex $script:Palette.Muted -Fallback 'Gray' -NoNewline
    Write-Tc -Text (' ' + $g.V) -Hex $script:Palette.Border -Fallback 'DarkYellow'

    Write-Tc -Text ('  ' + $g.BL + $rule + $g.BR) -Hex $script:Palette.Border -Fallback 'DarkYellow'
}

function Write-Section {
    param([string]$Title)
    Write-Host ''
    Write-Tc -Text '  >> ' -Hex $script:Palette.Orange -Fallback 'DarkYellow' -NoNewline
    Write-Tc -Text $Title.ToUpperInvariant() -Hex $script:Palette.Gold -Fallback 'Yellow'
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
    $percent = [Math]::Min(100,[Math]::Round((([Math]::Max(0,$Number-1)) / [Math]::Max(1,$Total)) * 100))

    Write-Host ''
    Write-Tc -Text '  STEP ' -Hex $script:Palette.Muted -Fallback 'Gray' -NoNewline
    Write-Tc -Text ('{0:D2}/{1:D2}' -f $Number,$Total) -Hex $script:Palette.Gold -Fallback 'Yellow' -NoNewline
    Write-Tc -Text '  ' -Hex $script:Palette.Muted -Fallback 'Gray' -NoNewline
    Write-Tc -Text $Title.ToUpperInvariant() -Hex $script:Palette.Cream -Fallback 'White'

    if ($Subtitle) {
        Write-Tc -Text ('  ' + $Subtitle) -Hex $script:Palette.Muted -Fallback 'Gray'
    }

    $barWidth = 34
    $filled = [Math]::Floor(($percent / 100) * $barWidth)
    $empty = $barWidth - $filled

    Write-Tc -Text '  overall  [' -Hex $script:Palette.Muted2 -Fallback 'DarkGray' -NoNewline
    if ($filled -gt 0) {
        Write-Tc -Text ([string]$g.Block * $filled) -Hex $script:Palette.Gold2 -Fallback 'Yellow' -NoNewline
    }
    if ($empty -gt 0) {
        Write-Tc -Text ([string]$g.Shade * $empty) -Hex $script:Palette.DarkFill -Fallback 'DarkGray' -NoNewline
    }
    Write-Tc -Text ('] {0,3}%' -f $percent) -Hex $script:Palette.Orange -Fallback 'DarkYellow'

    Write-Tc -Text ('  ' + ([string]$g.H * [Math]::Max(24,$script:UiWidth-2))) -Hex $script:Palette.DarkFill -Fallback 'DarkGray'
}

function Write-Status {
    param(
        [ValidateSet('OK','SKIP','RUN','WARN','FAIL','INFO')]
        [string]$State,
        [string]$Message
    )

    $map = @{
        OK   = @{ Tag='[OK]  '; Hex=$script:Palette.Green;     Fallback='Green' }
        SKIP = @{ Tag='[SKIP]'; Hex=$script:Palette.GreenSkip; Fallback='DarkGreen' }
        RUN  = @{ Tag='[RUN] '; Hex=$script:Palette.Gold2;     Fallback='Yellow' }
        WARN = @{ Tag='[WARN]'; Hex=$script:Palette.Orange;    Fallback='DarkYellow' }
        FAIL = @{ Tag='[FAIL]'; Hex=$script:Palette.Red;       Fallback='Red' }
        INFO = @{ Tag='[INFO]'; Hex=$script:Palette.Muted;     Fallback='Gray' }
    }

    $entry = $map[$State]
    Write-Host '  ' -NoNewline
    Write-Tc -Text $entry.Tag -Hex $entry.Hex -Fallback $entry.Fallback -NoNewline
    Write-Tc -Text ('  ' + $Message) -Hex $script:Palette.Cream2 -Fallback 'White'
}

function Write-ProgressLine {
    param([int]$Done,[int]$Total)
    if ($Total -le 0) { return }

    $g = Get-RichGlyphs
    $percent = [Math]::Min(100,[Math]::Round(($Done / $Total) * 100))
    $width = 30
    $filled = [Math]::Floor(($percent / 100) * $width)
    $empty = $width - $filled

    Write-Tc -Text '  package  [' -Hex $script:Palette.Muted2 -Fallback 'DarkGray' -NoNewline
    if ($filled -gt 0) {
        Write-Tc -Text ([string]$g.Block * $filled) -Hex $script:Palette.Gold2 -Fallback 'Yellow' -NoNewline
    }
    if ($empty -gt 0) {
        Write-Tc -Text ([string]$g.Shade * $empty) -Hex $script:Palette.DarkFill -Fallback 'DarkGray' -NoNewline
    }
    Write-Tc -Text ('] {0,3}%  {1}/{2}' -f $percent,$Done,$Total) -Hex $script:Palette.Orange -Fallback 'DarkYellow'
}

function Write-ColorBox {
    param(
        [string]$Title,
        [string[]]$Lines,
        [string]$TitleHex,
        [string]$TitleFallback = 'Yellow'
    )

    $g = Get-RichGlyphs
    $inner = [Math]::Max(76,$script:UiWidth-8)
    $rule = [string]$g.H * ($inner + 2)

    Write-Tc -Text ('  ' + $g.TL + $rule + $g.TR) -Hex $script:Palette.Border -Fallback 'DarkYellow'
    Write-Tc -Text ('  ' + $g.V + ' ') -Hex $script:Palette.Border -Fallback 'DarkYellow' -NoNewline
    Write-Tc -Text $Title.ToUpperInvariant().PadRight($inner) -Hex $TitleHex -Fallback $TitleFallback -NoNewline
    Write-Tc -Text (' ' + $g.V) -Hex $script:Palette.Border -Fallback 'DarkYellow'

    foreach ($line in $Lines) {
        Write-Tc -Text ('  ' + $g.V + ' ') -Hex $script:Palette.Border -Fallback 'DarkYellow' -NoNewline
        Write-Tc -Text $line.PadRight($inner) -Hex $script:Palette.Cream2 -Fallback 'White' -NoNewline
        Write-Tc -Text (' ' + $g.V) -Hex $script:Palette.Border -Fallback 'DarkYellow'
    }

    Write-Tc -Text ('  ' + $g.BL + $rule + $g.BR) -Hex $script:Palette.Border -Fallback 'DarkYellow'
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
    Write-Tc -Text '  overall  [' -Hex $script:Palette.Muted2 -Fallback 'DarkGray' -NoNewline
    Write-Tc -Text ([string]$g.Block * 34) -Hex $script:Palette.Gold2 -Fallback 'Yellow' -NoNewline
    Write-Tc -Text '] 100%' -Hex $script:Palette.Orange -Fallback 'DarkYellow'

    $titleHex = switch ($State) {
        'Success' { $script:Palette.Gold }
        'Warning' { $script:Palette.Orange }
        'Failure' { $script:Palette.Red }
    }
    $fallback = switch ($State) {
        'Success' { 'Yellow' }
        'Warning' { 'DarkYellow' }
        'Failure' { 'Red' }
    }

    Write-Host ''
    Write-ColorBox -Title $Title -Lines (@($Subtitle) + $Details + @('made by Rafdi D. Ulhaq')) -TitleHex $titleHex -TitleFallback $fallback
}

function Write-ActionPanel {
    param(
        [string]$Title,
        [string[]]$Items
    )

    Write-Host ''
    Write-ColorBox -Title $Title -Lines $Items -TitleHex $script:Palette.Gold -TitleFallback 'Yellow'
}
