# Safety & Trust Model

## Installer rules
- Never delete user research files.
- Never overwrite managed settings without a timestamped backup.
- Never store OAuth tokens, API keys, browser cookies, or account credentials in this repository.
- Do not silently disable security controls.
- Do not enable an Antigravity setting until its key and behavior are verified.
- External installers come from official package sources.
- Every mutation writes to a local installation log.
- A failed step must never be reported as successful.

## Research-agent rules
- Preserve source identity with claims whenever practical.
- Prefer books and peer-reviewed research for academic claims when appropriate.
- Official documents and trustworthy web sources may supplement primary academic sources.
- Never fabricate DOI, ISBN, author, page number, quotation, dataset, or citation.
- Separate sourced evidence from model inference.

## Document-agent rules
A reference document may be used to infer layout/style conventions: margins, paper size, font, spacing, paragraph indentation, headings, captions, tables, footnotes, page numbering, and bibliography layout.

A generated profile is a **derived formatting profile**, not proof of an institution's official policy. When an official guideline conflicts with a sample document, the official guideline wins.

## One-command CMD trust boundary
The one-liner downloads a PowerShell bootstrap from the official repository's main branch. A user should inspect the repository and trust its owner before executing it: the bootstrap itself is not individually code-signed or cryptographically pinned by the command.

The bootstrap obtains only the latest published GitHub Release and its SHA256 manifest; both the ZIP and its extracted files are verified before START.cmd runs. A digest checks integrity against the repository's published release but does not replace independent publisher authenticity checks. The bootstrap never requests another person's credentials or silently elevates privileges.

Do not disable SmartScreen, antivirus, or Windows security prompts to run the kit. A user who does not trust the bootstrap may download and verify the ZIP directly from GitHub Releases.
