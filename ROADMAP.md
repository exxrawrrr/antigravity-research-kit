# Roadmap

GitHub is the source of truth. GROWTH is only the verified baseline/test machine.

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
- [x] detect / skip / install logic (update remains explicit, not automatic)
- [x] logging and exit codes
- [x] no-destructive-overwrite baseline (Phase 4 extends backup/rollback)

## Phase 2 — Antigravity Parity
- [x] Antigravity app / IDE / CLI
- [x] Tokyo Night extension + Storm selection
- [x] Material Icon Theme
- [x] verified sandbox / permission-first behavior
- [x] verification gate on GROWTH + isolated TEMP profile## Phase 3 — Rafdi Academic Research Pack
- [x] Research role-skill (lazy-loaded)
- [x] Document role-skill (lazy-loaded)
- [x] Reviewer role-skill (lazy-loaded)
- [x] modular helper skills (Document Style Learning + Evidence Tracing)
- [x] evidence/source preservation rules
- [x] document-style learning profile workflow

## Phase 4 — UX, Safety & Repair
- [ ] branded terminal
- [ ] backup + rollback
- [ ] repair mode
- [ ] friendly diagnostics
- [ ] explicit "DO NOT CLOSE THIS WINDOW" state

## Phase 5 — Clean-Machine Acceptance & v0.1
- [ ] fresh Windows VM/sandbox test
- [ ] rerun/idempotency test
- [ ] partial-existing-install test
- [ ] offline/failure recovery test
- [ ] ZIP + SHA256
- [ ] GitHub release v0.1.0

## Baseline observed on GROWTH — 3 Oct 2026
Antigravity 2.19.1 · IDE 2.5.5 · CLI 1.2.14

Installer logic must detect current versions instead of assuming these versions forever.
