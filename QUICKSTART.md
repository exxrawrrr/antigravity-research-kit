# Quick Start — Antigravity Research Kit

Made by **Rafdi D. Ulhaq** / **@exxrawrrr**

## For friends / non-developers

1. Download the release ZIP.
2. Extract the ZIP completely. Do not run it from inside the compressed archive.
3. Double-click **`INSTALL.bat`**.
4. Keep the terminal open until it clearly reports completion or an error.
5. If Antigravity asks you to sign in, complete the official sign-in flow yourself.
6. Double-click **`VERIFY.bat`**. A healthy setup ends with **READY FOR LOCAL ACADEMIC WORK**.

## What the installer does

- Detects existing Antigravity, Antigravity IDE, and Antigravity CLI and skips them when already installed.
- Installs missing core packages from their official WinGet package IDs.
- Installs Tokyo Night and Material Icon Theme when missing.
- Selects Tokyo Night Storm and Material Icon Theme.
- Enables Antigravity CLI terminal sandbox using the native setting.
- Keeps normal permission prompts enabled; it never enables dangerous auto-approval.
- Adds the `agy-safe` launcher (`agy --sandbox`).
- Installs **Rafdi Academic Research Pack** with 5 lazy-loaded skills.

## Research pack

- **Research role-skill** — broad academic research with source tracing.
- **Document role-skill** — local manuscript formatting/engineering.
- **Reviewer role-skill** — strict academic QA.
- **Document Style Learning** — learns formatting rules from a sample or official guideline.
- **Evidence Tracing** — keeps claims linked to verifiable sources.

Every Rafdi-authored skill contains **Made by Rafdi D. Ulhaq**.

## Useful launchers

- `INSTALL.bat` — initial setup / safe rerun.
- `VERIFY.bat` — read-only health check.
- `REPAIR.bat` — reapply missing managed pieces, then verify.
- `ROLLBACK-MANAGED-SETUP.bat` — restore installer-managed settings/PATH and remove the Rafdi pack/launcher. It does **not** uninstall the Antigravity apps or third-party extensions.

## Important

- This kit does not automate or store your Google/Antigravity login credentials.
- Back up irreplaceable academic work independently; the installer never treats itself as your document backup system.
- Formatting inferred from a sample document is a derived profile, not proof of an institution's official policy.

## Release status

`v0.1.0-rc1` is a **release candidate**. It passed real install, idempotency, rollback, repair, and verification gates on the GROWTH workstation. A fresh-machine acceptance test is still required before `v0.1.0` final.
