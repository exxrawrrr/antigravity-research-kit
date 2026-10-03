# Phase 1 Evidence — Installer Engine

Date: 2026-10-03  
Baseline machine: GROWTH (Windows)

## Gate result

**PASS**

## Verified behavior

- Windows platform detection works through .NET PlatformID.
- WinGet presence is checked before package operations.
- System-drive free space is reported.
- Package manifest loads from JSON.
- Existing Antigravity packages are detected and skipped.
- Progress reaches 100% without reinstalling existing software.
- Dry-run mode performs no package installation.
- Installer writes a timestamped local log.
- PowerShell files parse successfully.
- JSON manifest parses successfully.
- Dry-run install primitive returns success without executing WinGet install.

## Observed dry-run

- Antigravity / Google.Antigravity -> SKIP
- Antigravity IDE / Google.AntigravityIDE -> SKIP
- Antigravity CLI / Google.AntigravityCLI -> SKIP
- Exit code -> 0
- Local working tree remained clean

## Bug caught during gate

The first draft used `$env:OS` to detect Windows. On the remote shell this was not reliable and caused a false non-Windows result. The branch was patched to use `[System.Environment]::OSVersion.Platform` and the full gate was rerun successfully.

This is why release gates run before merge.

## Re-audit after Phase 0 lock — 2026-10-03

Re-audited against `origin/main` at `f9db9cf00ff02dd473fb72bbfee2347b69f14e58` from an isolated temporary Git worktree on GROWTH. The active development checkout was not switched or modified.

Additional gate results:
- All PowerShell installer files parse successfully.
- Package and IDE JSON manifests parse successfully.
- Dry-run #1 exit: `0`.
- Dry-run #2 exit: `0`.
- Existing Antigravity / IDE / CLI packages were skipped on both runs.
- A temporary fake missing package exercised the install-action path in dry-run without installing anything; exit: `0`.
- Temporarily hiding `config/packages.json` produced the expected fail-closed exit code `22`.
- Installed package snapshot remained Antigravity 2.19.1 / IDE 2.5.5 / CLI 1.2.14 after the gate.
- Latest GitHub Actions validation for `main` completed successfully after the Phase 0 evidence commit.

No Phase 1 engine patch was required by this re-audit.

**Re-audit verdict: PASS / LOCKED.**
