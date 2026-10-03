# Phase 0 Evidence — Baseline & Repository Lock

Phase 0 is the baseline contract for the Antigravity Research Kit. GitHub is the source of truth; GROWTH is a reference/test machine only.

## Repository
- Repository: `exxrawrrr/antigravity-research-kit`
- Visibility: public
- Default branch: `main`
- Scope: Antigravity local academic setup + Rafdi Academic Research Pack
- Out of scope: general-purpose ResearchOS, unrelated AI stacks, silent credential/login automation

## GROWTH package baseline — 2026-10-03
Read-only package inspection observed:
- `Google.Antigravity` — 2.19.1
- `Google.AntigravityIDE` — 2.5.5
- `Google.AntigravityCLI` — 1.2.14
- WinGet reported CLI 1.2.15 as available, so installer logic must detect versions dynamically rather than pinning forever.

## Observed locations
- Antigravity app: `%LOCALAPPDATA%\Programs\antigravity\Antigravity.exe`
- Antigravity IDE: `%LOCALAPPDATA%\Programs\Antigravity IDE\Antigravity IDE.exe`
- Antigravity CLI: WinGet package path, command `agy.exe`
- Antigravity profile: `%APPDATA%\Antigravity`
- IDE profile: `%APPDATA%\Antigravity IDE`
- IDE settings: `%APPDATA%\Antigravity IDE\User\settings.json`

## IDE / UX contract
Desired managed subset:
- extension `enkia.tokyo-night`
- theme `Tokyo Night Storm`
- extension `pkief.material-icon-theme`
- icon theme `material-icon-theme`

Observed versions recorded in config:
- Tokyo Night 1.1.2
- Material Icon Theme 5.39.0

Important: the current GROWTH user profile was observed with `workbench.colorTheme = Solarized Dark`. Therefore the kit must never clone the full user profile. It may manage only explicitly owned keys, after backup.

## Safety contract
- Detect first; install second.
- Existing compatible packages are skipped.
- No credential, cookie, OAuth token, API key, or login state is copied from GROWTH.
- No blind overwrite of user settings.
- Back up managed settings before mutation.
- Terminal sandbox is preferred where supported.
- Permission/review prompts stay enabled.
- `--dangerously-skip-permissions` is explicitly forbidden in managed safe launchers.
- Third-party binaries are obtained from official package sources rather than bundled unless redistribution is explicitly permitted.

## Academic-pack design contract
Keep the AI flexible:
- maximum three role-oriented capabilities: Research, Document, Reviewer
- additional capability is modular/on-demand
- research preserves source provenance
- document formatting is learned from a user-supplied example rather than hard-coded to one campus
- every Rafdi-authored skill/agent carries `Made by Rafdi D. Ulhaq`

## Phase 0 gate
PASS when:
1. repository exists and is usable as source of truth;
2. real package IDs/versions/paths are captured;
3. desired managed subset is separated from current personal settings;
4. safety boundaries are documented;
5. future phases can build from manifests instead of memory.

**Verdict: PASS / LOCKED.**
