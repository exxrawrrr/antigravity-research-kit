# GROWTH Baseline

Read-only inspection of the working GROWTH machine on **2026-10-03**.

## Installed packages
- `Google.Antigravity` — 2.19.1
- `Google.AntigravityIDE` — 2.5.5
- `Google.AntigravityCLI` — 1.2.14

## Observed locations
- Antigravity: `%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe`
- Antigravity IDE: `%LOCALAPPDATA%\Programs\Antigravity IDE\Antigravity IDE.exe`
- Antigravity CLI: WinGet package path, command `agy.exe`
- Antigravity profile: `%APPDATA%\Antigravity`
- Antigravity IDE profile: `%APPDATA%\Antigravity IDE`
- IDE settings: `%APPDATA%\Antigravity IDE\User\settings.json`

## Important finding
The current GROWTH IDE setting reports `Solarized Dark`. The kit must **not** blindly clone all current user settings.

The kit owns only an explicit desired subset: Tokyo Night extension, Tokyo Night Storm selection, Material Icon Theme, research-pack assets, and safety settings after their exact supported keys are verified.

## WinGet strategy
Prefer official exact IDs: `Google.Antigravity`, `Google.AntigravityIDE`, and `Google.AntigravityCLI`.

Behavior: detect -> compare -> install/update only when required -> verify.
