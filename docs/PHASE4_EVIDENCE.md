# Phase 4 Evidence — UX, Safety & Repair

Date: 2026-10-03  
Baseline machine: GROWTH (Windows)

## Gate result
**PASS**

## UX
- Branded terminal identifies EXXRAWRRR / Antigravity Research Kit / Rafdi D. Ulhaq.
- Installer explicitly warns not to close the terminal.
- Progress, SKIP, OK, WARN, FAIL, and INFO states are visible.
- `VERIFY.bat`, `REPAIR.bat`, and `ROLLBACK-MANAGED-SETUP.bat` provide beginner-facing entry points.

## Real partial-existing-machine install
GROWTH already had all three core Antigravity packages and both IDE extensions.

Observed behavior:
- Antigravity / IDE / CLI -> SKIP;
- Tokyo Night + Material Icon extensions -> SKIP;
- desired Tokyo Night Storm setting applied with backup;
- persistent terminal sandbox applied safely;
- permission prompts remained enabled; dangerous auto-approval was never configured;
- `agy-safe` created and registered on User PATH;
- Rafdi Academic Research Pack installed.

Read-only verifier then returned **READY FOR LOCAL ACADEMIC WORK** with every required check passing.

## Idempotency gate
Installer was rerun on an already-healthy installation.

Result:
- core packages -> SKIP;
- extensions -> SKIP;
- theme/icon settings -> SKIP;
- persistent sandbox -> SKIP;
- `agy-safe` -> SKIP;
- managed PATH -> SKIP;
- academic pack -> SKIP.

Backup counts before and after rerun remained unchanged:
- IDE settings backups: 1 -> 1
- CLI settings backups: 1 -> 1
- PATH backups: 1 -> 1

## Managed rollback gate
`installer/rollback.ps1 -ConfirmRollback` was executed on GROWTH.

Verified after rollback:
- IDE setting returned to pre-kit `Solarized Dark`;
- User PATH no longer contained the managed bin;
- `agy-safe` was removed;
- Rafdi Academic Research Pack was uninstalled;
- Antigravity, Antigravity IDE, and Antigravity CLI all remained installed;
- third-party extensions were not uninstalled.

Rollback intentionally manages only installer-owned customization; it does not guess whether core apps/extensions predated the kit.

## Repair gate
After rollback, the installer was run again, followed by the read-only verifier.

Result: **PASS** — the managed configuration, PATH entry, launcher, and academic pack were restored and all verification checks returned green.

## Recovery artifacts
Before managed mutations, timestamped recoverable backups are written for:
- IDE settings;
- Antigravity CLI settings;
- User PATH.

This gives the user both explicit rollback and repair paths without deleting research files.
