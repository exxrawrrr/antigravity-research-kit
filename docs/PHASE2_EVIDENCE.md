# Phase 2 Evidence — Antigravity Parity

Date: 2026-10-03  
Baseline machine: GROWTH (Windows)

## Gate result
**PASS**

## Verified installed baseline
- Antigravity 2.19.1
- Antigravity IDE 2.5.5
- Antigravity CLI 1.2.14
- Tokyo Night extension `enkia.tokyo-night@1.1.2`
- Material Icon Theme `pkief.material-icon-theme@5.39.0`

## Desired kit experience
- Color theme: **Tokyo Night Storm**
- Icon theme: **material-icon-theme**

The installer does not clone every GROWTH preference. It manages only the explicit kit-owned settings.

## Safety behavior
`agy --help` confirms:
- `--sandbox` enables terminal restrictions.
- `--dangerously-skip-permissions` disables normal permission prompts.

The kit therefore creates an `agy-safe.cmd` launcher that calls `agy --sandbox` and never adds the dangerous auto-approval flag.

## Isolated write test
A temporary fake APPDATA/LOCALAPPDATA profile was created and removed after testing.

Verified:
- settings JSON was backed up before modification;
- existing unrelated setting `editor.fontSize` survived;
- Tokyo Night Storm was applied;
- Material Icon Theme was applied;
- backup file existed;
- generated `agy-safe.cmd` contained `agy --sandbox`;
- generated launcher did not contain `--dangerously-skip-permissions`;
- real GROWTH IDE settings were not modified by the gate.

## Bugs caught
1. IDE CLI extension listing can emit internal warnings/crash after useful output, so installed-extension detection uses the actual extension directory for reliable verification.
2. `agy --help` writes help text to stderr; capability detection was adjusted to capture it safely rather than treating help text as an installer failure.
