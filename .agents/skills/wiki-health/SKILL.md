---
name: wiki-health
description: Run fast structural health checks on the LLM Wiki in docs/second-brain — empty or stub pages, index.md out of sync with files, source pages missing from log.md. Use when the user says "health" or at the start of a session before other wiki work.
---

Run structural health checks on the LLM Wiki.

First read docs/second-brain/SCHEMA.md — it defines the wiki's layout, page formats, naming conventions and workflows, and is not loaded automatically.

Input: optional. If the user adds `--save` or asks to save the report, also write it to docs/second-brain/reports/health-YYYY-MM-DD.md (today's date; overwrite if it already exists).

Follow the Health Workflow defined in docs/second-brain/SCHEMA.md. The checks are structural only — do not judge page content.

Scope: every .md file under docs/second-brain/wiki/, excluding index.md and log.md. overview.md is included. N in "Scanned N wiki pages" is the number of files in scope.

Checks:
1. Empty / stub files — strip the YAML frontmatter (the block between the first two `---` lines) from each page, then trim leading and trailing whitespace. The body is what remains. If it is empty the page is 🔴 empty; if it has fewer than 100 characters it is 🟡 stub. In the table, Total Bytes is the size of the whole file and Body Bytes the length of the trimmed body; sort rows by Body Bytes, smallest first.
2. Index sync — collect every markdown link target ending in .md from docs/second-brain/wiki/index.md (paths are relative to docs/second-brain/wiki/). Ignore overview.md on both sides, then report (the issue count is the number of entries in both lists together):
   - Stale index entries: listed in index.md but no file on disk
   - Missing from index: file on disk but not listed in index.md
3. Log coverage — for each page in docs/second-brain/wiki/sources/, look in docs/second-brain/wiki/log.md for a line `## [YYYY-MM-DD] ingest | <Title>`. It counts as logged if <Title> matches (case-insensitive) either the page's frontmatter `title` or its filename without .md with `-` and `_` turned into spaces. Report every source page with no match.

Output a markdown report with this structure:

# Wiki Health Report — <today's date>

Scanned N wiki pages. Checks are purely structural.

## Empty / Stub Files (N found)
A table `| Page | Total Bytes | Body Bytes | Status |`, or "All pages have content beyond frontmatter. ✅"

## Index Sync (N issues)
The two lists above, or "index.md is in sync with disk. ✅"

## Log Coverage (N source pages without log entry)
The list with each page's title, or "All source pages have corresponding log entries. ✅"

If the user asked to save the report (for example with `--save`), write the report to docs/second-brain/reports/health-YYYY-MM-DD.md (today's date; overwrite if it already exists). Do not append to docs/second-brain/wiki/log.md.

If any issues were found, suggest the fix for each (e.g. add the missing index entry, re-ingest an empty source page with wiki-ingest) and ask before changing anything.

---

Provenance: adapted from the wiki workflows of https://github.com/SamurAIGPT/llm-wiki-agent, Copyright (c) 2023 SamurAIGPT, MIT License (full text in this repository's `LICENSE`). This note is not an instruction.
