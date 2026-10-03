# Antigravity Research Kit

> **Antigravity setup + Rafdi Academic Research Pack**  
> Made by **Rafdi D. Ulhaq** / [@exxrawrrr](https://github.com/exxrawrrr)

A careful Windows installer that prepares Antigravity for local thesis, skripsi, dissertation, and academic-research work.

## What this project installs

- Antigravity 2.x
- Antigravity IDE
- Antigravity CLI (`agy`)
- Tokyo Night extension + **Tokyo Night Storm**
- Material Icon Theme
- Terminal sandbox / safer execution defaults where supported
- Request-review / permission-first defaults where supported
- **Rafdi Research Agent**
- **Rafdi Document Agent**
- **Rafdi Reviewer Agent**
- Modular academic research and document skills

## Design principles

1. **Detect first, install second.** Existing compatible software is skipped.
2. **No blind overwrites.** Back up managed settings before editing.
3. **AI stays flexible.** Only three agents; extra capability lives in on-demand skills.
4. **Reference-preserving research.** Keep academic claims traceable to sources.
5. **Learn formatting from examples.** Derive layout rules from a user-provided reference document.6. **Local-first documents.** Work with local thesis/research files only with user permission.
7. **Visible installation.** Keep the terminal open until verification finishes.

## Install experience

The release will ship a beginner-friendly ZIP:

```
INSTALL.bat
installer/
config/
agents/
skills/
```

`INSTALL.bat` is the launcher. The idempotent engine is PowerShell.

## Project status

**v0.1 development — Phase 0/6**

See [ROADMAP.md](ROADMAP.md).

## Attribution

Every Rafdi-authored agent and skill includes: **Made by Rafdi D. Ulhaq**.

Third-party software keeps its original license and attribution. The kit prefers official package sources and does not bundle proprietary Antigravity binaries unless redistribution is explicitly permitted.
