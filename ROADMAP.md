# Roadmap

GitHub is the source of truth. GROWTH is only the previously verified baseline/test machine; current repository maintenance can be performed entirely through GitHub.

## Phase 0 — Baseline & Repository
- [x] Public repository established
- [x] Scope locked: Antigravity Research Kit, not a general ResearchOS
- [x] GROWTH baseline versions captured
- [x] Baseline paths/settings documented
- [x] Safety model drafted

## Phase 1 — Installer Engine
- [x] `INSTALL.bat` launcher
- [x] PowerShell engine
- [x] terminal UI / progress output
- [x] detect / skip / install logic
- [x] logging and exit codes
- [x] no-destructive-overwrite baseline

## Phase 2 — Antigravity Parity
- [x] Antigravity app / IDE / CLI
- [x] Tokyo Night extension + Storm selection
- [x] Material Icon Theme
- [x] verified sandbox / permission-first behavior
- [x] verification gate on GROWTH + isolated TEMP profile

## Phase 3 — Rafdi Academic Research Pack
- [x] Research role-skill (lazy-loaded)
- [x] Document role-skill (lazy-loaded)
- [x] Reviewer role-skill (lazy-loaded)
- [x] modular helper skills: Document Style Learning + Evidence Tracing
- [x] evidence/source preservation rules
- [x] document-style learning profile workflow

## Phase 4 — UX, Safety & Repair
- [x] branded terminal
- [x] backup + conservative managed rollback
- [x] repair mode
- [x] read-only verifier + friendly diagnostics
- [x] explicit "DO NOT CLOSE THIS WINDOW" state

## Phase 5 — Clean-Machine Acceptance
- [x] clean Windows runner acceptance workflow
- [x] real rerun / idempotency gate on GROWTH
- [x] partial-existing-install behavior covered by detect/skip logic
- [x] failure-path gate
- [x] standalone ZIP + internal manifest + external SHA256
- [x] release candidate artifact path

## Phase 6 — Publish v0.1.0
- [x] final version metadata
- [x] beginner QUICKSTART
- [x] release notes
- [x] tag-driven GitHub Release workflow
- [x] merge final release branch
- [x] tag `v0.1.0`
- [x] publish GitHub Release assets

## Post-v0.1.2 — Mainline Hardening
- [x] final premium terminal screenshot promoted to the README hero
- [x] installer / verifier / repair wrappers delegate directly to the premium renderer
- [x] `STATUS.cmd` added as a beginner-friendly read-only verification alias
- [x] standalone release builder includes `STATUS.cmd` and README assets
- [x] clean-Windows acceptance follows `main` and pull requests instead of only the old release-candidate branch
- [x] acceptance archive version derives from `VERSION` instead of a hard-coded v0.1.0 RC
- [x] static validation covers release scripts, launchers, VERSION metadata, and the README hero asset

## Baseline observed on GROWTH — 3 Oct 2026
Antigravity 2.19.1 · IDE 2.5.5 · CLI 1.2.14.

Installer logic detects current state instead of assuming these versions forever.
