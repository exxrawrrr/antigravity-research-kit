# Phase 3 Evidence — Rafdi Academic Research Pack

Date: 2026-10-03  
Baseline machine: GROWTH (Windows)

## Gate result
**PASS**

## Architecture lock
The pack is deliberately small and progressively disclosed.

One Antigravity plugin contains **5 skills**:
1. `rafdi-research-agent` — broad academic research role.
2. `rafdi-document-agent` — academic document engineering role.
3. `rafdi-reviewer-agent` — strict review/QA role.
4. `document-style-learning` — derive reusable layout rules from a sample/guideline.
5. `evidence-tracing` — durable claim-to-source ledger.

The three “agents” are implemented as role-skills instead of always-resident subagents. This keeps the model flexible and avoids loading every instruction into context for every task.

## Native Antigravity validation
`agy plugin validate pack/rafdi-academic-research-pack` returned:
- plugin OK;
- skills: 5 processed;
- no MCP/hooks/commands required.

Every `SKILL.md` was checked for:
- required YAML frontmatter;
- name + description;
- **Made by Rafdi D. Ulhaq** attribution.

## Plugin lifecycle test
On GROWTH:
1. confirmed pack absent;
2. installed plugin from local directory using native `agy plugin install`;
3. confirmed `rafdi-academic-research-pack` appeared in `agy plugin list`;
4. uninstalled the plugin;
5. confirmed environment returned to `No imported plugins`.

Result: **PASS / reversible**.

## Persistent sandbox test
The native Antigravity CLI settings file was identified at:
`~/.gemini/antigravity-cli/settings.json`

Verified native key:
`"enableTerminalSandbox": true`

The installer merge routine was tested against an isolated fake USERPROFILE:
- existing unrelated settings survived;
- sandbox changed from false to true;
- timestamped backup was created;
- real GROWTH user settings were not changed by this test.

## Research behavior
- foundational theory defaults toward authoritative books/monographs;
- recent empirical evidence defaults toward peer-reviewed research;
- source priority remains context-sensitive instead of rigid;
- DOI/ISBN/page/quote/data fabrication is explicitly forbidden;
- evidence, synthesis, and model inference must be distinguishable;
- research gaps must be evidence-based.

## Document behavior
The style-learning skill derives a project-local profile for margins, fonts, spacing, paragraphs, headings, captions, tables, footnotes, pagination, and bibliography layout.

Precedence:
official guideline > explicit user instruction > approved sample > derived profile > generic convention.
