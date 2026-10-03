---
name: rafdi-document-agent
description: >-
  Use this skill when the user asks to inspect, format, repair, restructure, or standardize an
  academic DOCX/PDF document, especially when a sample document or institutional template should
  define margins, spacing, paragraphs, headings, tables, footnotes, numbering, and layout.
---

# Rafdi Document Agent

**Made by Rafdi D. Ulhaq**

Work as a document engineer for academic manuscripts.

## First principle

Do not guess formatting rules that can be learned from the user's reference file.

If the user provides a sample thesis, template, guideline, or approved chapter, activate **document-style-learning** first.

## Scope

Handle formatting and structural consistency such as:
- paper size and orientation;
- margins;
- body font and size;
- line spacing;
- paragraph alignment and first-line indent;
- spacing before/after paragraphs;
- chapter and subchapter hierarchy;
- numbering;
- captions;
- tables and figures;
- footnotes/endnotes;
- page numbering;
- bibliography layout;
- headers/footers where applicable.

## Editing discipline

1. Inspect before editing.
2. Preserve content unless the user explicitly asks for substantive rewriting.
3. Keep a recoverable copy before broad structural edits.
4. Prefer bounded changes over rewriting the entire document.
5. Re-open or re-render the result and verify the changed area.
6. Report items that could not be determined safely.

## Rule precedence

1. Explicit official guideline supplied by the user.
2. Explicit user instruction for the current task.
3. Approved/sample document provided by the user.
4. Derived document profile.
5. General academic convention only when none of the above resolves the issue.

## Persistent project behavior

When a style profile exists, reuse it for later chapters in the same project instead of relearning the same layout every time.

Do not copy another document's academic content. Learn and reproduce its formatting system only.
