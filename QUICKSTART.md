# Quick Start — Antigravity Research Kit

Made by **Rafdi D. Ulhaq** / **@exxrawrrr**

## For friends / non-developers — CMD first

Open normal Windows CMD, paste this one line, then press Enter:

```bat
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p=Join-Path $env:TEMP 'EXXRAWRRR-GET.ps1'; iwr -UseBasicParsing 'https://raw.githubusercontent.com/exxrawrrr/antigravity-research-kit/main/GET-EXXRAWRRR.ps1' -OutFile $p -ErrorAction Stop; & $p"
```

You should see the EXXRAWRRR amber/gold banner, real progress milestones, SHA256 checks, and then the full terminal installer. Sign in directly to Google/Antigravity when prompted; this kit does not transfer credentials. Use only the official repository. An internet connection and compatible Windows App Installer/WinGet are required.

### ZIP fallback

1. Open the latest release: https://github.com/exxrawrrr/antigravity-research-kit/releases/latest
2. Download **`Antigravity-Research-Kit-v0.1.3.zip`**.
3. Extract the ZIP completely. Do not run it from inside the compressed archive.
4. Double-click **`START.cmd`**. Windows Terminal opens maximized + focus mode when available; otherwise the launcher falls back safely.
5. Keep the terminal open until it clearly reports completion or an error.
6. If Antigravity asks you to sign in, complete the official sign-in flow yourself.
7. Double-click **`VERIFY.bat`**. A healthy setup ends with **READY FOR LOCAL ACADEMIC WORK**.

The current `main` branch also provides **`STATUS.cmd`** as a beginner-friendly alias for the same read-only check. It is included by the current release builder and will appear in the next tagged archive.

For a three-step Indonesian guide and ready-to-copy skripsi, tesis, or disertasi prompts, open **[FRIENDS-START.md](FRIENDS-START.md)**. The installer menu also has **[H] Quick Guide**.

## What the installer does

- Detects existing Antigravity, Antigravity IDE, and Antigravity CLI and skips them when already installed.
- Installs missing core packages from their official WinGet package IDs.
- Installs Tokyo Night and Material Icon Theme when missing.
- Selects Tokyo Night Storm and Material Icon Theme.
- Enables Antigravity CLI terminal sandbox using the native setting.
- Keeps normal permission prompts enabled; it never enables dangerous auto-approval.
- Adds the `agy-safe` launcher (`agy --sandbox`).
- Installs **Rafdi Academic Research Pack** with 5 lazy-loaded skills.
- Runs a final gate before reporting the environment ready.

## Research pack

- **Research role-skill** — broad academic research with source tracing.
- **Document role-skill** — local manuscript formatting/engineering.
- **Reviewer role-skill** — strict academic QA.
- **Document Style Learning** — learns formatting rules from a sample or official guideline.
- **Evidence Tracing** — keeps claims linked to verifiable sources.

Every Rafdi-authored skill contains **Made by Rafdi D. Ulhaq**.

## Useful launchers

- **`START.cmd`** — recommended premium launcher.
- **`INSTALL.bat`** — initial setup / safe rerun.
- **`STATUS.cmd`** — current-main convenience alias for read-only verification.
- **`VERIFY.bat`** — read-only health check.
- **`REPAIR.bat`** — reapplies missing managed pieces, then verifies.
- **`ROLLBACK-MANAGED-SETUP.bat`** — restores installer-managed settings/PATH and removes the Rafdi pack/launcher. It does **not** uninstall the Antigravity apps or third-party extensions.

The root launchers hand off directly to the premium PowerShell renderer, so the user sees one coherent terminal UI rather than a legacy ASCII banner stacked above it.

## Important

- This kit does not automate or store your Google/Antigravity login credentials.
- Back up irreplaceable academic work independently; the installer never treats itself as your document backup system.
- Formatting inferred from a sample document is a derived profile, not proof of an institution's official policy.
- If a campus provides an official formatting guide, use that as the highest-priority reference.
- `VERIFY.bat` and `STATUS.cmd` are read-only; use `REPAIR.bat` only when you actually want the managed setup reapplied.

## Release status

**v0.1.3** is the latest packaged stable release. Current `main` contains post-v0.1.3 UX and CI hardening without falsely bumping the public version before a real tagged release exists.
