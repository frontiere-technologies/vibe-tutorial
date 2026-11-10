# Second Brain — Wiki Schema & Workflows

Rules for maintaining and querying the wiki in `docs/second-brain/`. This file is not loaded automatically: read it before any wiki maintenance request (`ingest <file>`, `query: <question>`, `health`, `lint`, or the same in plain words). `AGENTS.md` and the `wiki-*` skills point here.

---

## Directory Layout

```
docs/second-brain/
  SCHEMA.md       # This file
  raw/            # Immutable source documents — never modify these
  wiki/           # Agent owns this layer entirely
    index.md      # Catalog of all pages — update on every ingest
    log.md        # Append-only chronological record
    overview.md   # Living synthesis across all sources
    sources/      # One summary page per source document
    entities/     # People, companies, projects, products
    concepts/     # Ideas, frameworks, methods, theories
    syntheses/    # Saved query answers
  reports/        # Saved health and lint reports (health-YYYY-MM-DD.md, lint-YYYY-MM-DD.md) — not wiki pages
```

---

## Page Format

Every wiki page uses this frontmatter:

```yaml
---
title: "Page Title"
type: source | entity | concept | synthesis
tags: []
sources: []       # list of source slugs that inform this page
last_updated: YYYY-MM-DD
---
```

Use `[[PageName]]` wikilinks to link to other wiki pages.

---

## Ingest Workflow

Triggered by: *"ingest <file>"*

**Supported formats:** Markdown (`.md`) and other text formats (`.txt`, `.html`, `.csv`, `.tsv`, `.json`, `.xml`, `.yaml`, `.yml`, `.rst`, `.ipynb`) are read directly; so are PDFs. Binary office and media formats (`.docx`, `.pptx`, `.xlsx`, `.epub`, `.rtf`, `.wav`, `.mp3`) must be converted to markdown first: if the [markitdown](https://github.com/microsoft/markitdown) CLI is installed, run `markitdown <file> -o <file>.md` and ingest the result; otherwise ask the user for a markdown or PDF version.

Steps (in order):
1. Read the source document fully (convert first if it is a binary format, see above)
2. Read `docs/second-brain/wiki/index.md` and `docs/second-brain/wiki/overview.md` for current wiki context
3. Write `docs/second-brain/wiki/sources/<slug>.md` — use the source page format below
4. Update `docs/second-brain/wiki/index.md` — add entry under Sources section
5. Update `docs/second-brain/wiki/overview.md` — revise synthesis if warranted
6. Update/create entity pages for key people, companies, projects mentioned
7. Update/create concept pages for key ideas and frameworks discussed
8. Flag any contradictions with existing wiki content
9. Append to `docs/second-brain/wiki/log.md`: `## [YYYY-MM-DD] ingest | <Title>`
10. **Post-ingest validation** — check for broken `[[wikilinks]]`, verify all new pages are in `index.md`, print a change summary

### Source Page Format

```markdown
---
title: "Source Title"
type: source
tags: []
date: YYYY-MM-DD
source_file: docs/second-brain/raw/...
---

## Summary
2–4 sentence summary.

## Key Claims
- Claim 1
- Claim 2

## Key Quotes
> "Quote here" — context

## Connections
- [[EntityName]] — how they relate
- [[ConceptName]] — how it connects

## Contradictions
- Contradicts [[OtherPage]] on: ...
```

### Domain-Specific Templates

If the source falls into a specific domain (e.g., personal diary, meeting notes), the agent should use a specialized template instead of the default generic one above:

#### Diary / Journal Template
```markdown
---
title: "YYYY-MM-DD Diary"
type: source
tags: [diary]
date: YYYY-MM-DD
---
## Event Summary
...
## Key Decisions
...
## Energy & Mood
...
## Connections
...
## Shifts & Contradictions
...
```

#### Meeting Notes Template
```markdown
---
title: "Meeting Title"
type: source
tags: [meeting]
date: YYYY-MM-DD
---
## Goal
...
## Key Discussions
...
## Decisions Made
...
## Action Items
...
```

---

## Query Workflow

Triggered by: *"query: <question>"*

Steps:
1. Read `docs/second-brain/wiki/index.md` to identify relevant pages
2. Read those pages
3. Synthesize an answer with inline citations as `[[PageName]]` wikilinks
4. Ask the user if they want the answer filed as `docs/second-brain/wiki/syntheses/<slug>.md`

---

## Lint Workflow

Triggered by: *"lint"*

Check for:
- **Orphan pages** — wiki pages with no inbound `[[links]]` from other pages
- **Broken links** — `[[WikiLinks]]` pointing to pages that don't exist
- **Contradictions** — claims that conflict across pages
- **Stale summaries** — pages not updated after newer sources
- **Missing entity pages** — entities mentioned in 3+ pages but lacking their own page
- **Sparse pages** — pages with fewer than 2 outbound `[[wikilinks]]` (link density budget)
- **Data gaps** — questions the wiki can't answer; suggest new sources

Output a lint report and ask if the user wants it saved to `docs/second-brain/reports/lint-YYYY-MM-DD.md` (today's date; overwrite if it already exists).

---

## Health Workflow

Triggered by: *"health"*

Fast structural integrity checks — mechanical, no judgment of page content, safe to run every session. Scope: every `.md` file under `docs/second-brain/wiki/` except `index.md` and `log.md`.
- **Empty / stub files** — after removing the YAML frontmatter and trimming whitespace, a page with no body is empty and one under 100 characters is a stub (rate-limit damage)
- **Index sync** — `.md` link targets in `docs/second-brain/wiki/index.md` vs actual files on disk (ignore `overview.md`): stale entries and pages missing from the index
- **Log coverage** — pages in `docs/second-brain/wiki/sources/` with no `## [YYYY-MM-DD] ingest | <Title>` line in `docs/second-brain/wiki/log.md`, where `<Title>` matches (case-insensitive) the frontmatter title or the filename with `-`/`_` turned into spaces

Output a health report. If the user asks to save it, write it to `docs/second-brain/reports/health-YYYY-MM-DD.md` (today's date; overwrite if it already exists).

### Health vs Lint Boundary

| Dimension | `health` | `lint` |
|---|---|---|
| **Scope** | Structural integrity | Content quality |
| **Method** | Mechanical checks on files, index and log | Reading and reasoning over page content |
| **Cost** | Low | Higher (reads and compares pages) |
| **Frequency** | Before wiki work in a session | Every 10-15 ingests |
| **Checks** | Empty files, index sync, log sync | Orphans, broken links, contradictions, gaps |
| **Run order** | First (pre-flight) | After health passes |

> Run `health` first — linting an empty file wastes tokens.

---

## Naming Conventions

- Source slugs: `kebab-case` matching source filename
- Entity pages: `TitleCase.md` (e.g. `OpenAI.md`, `SamAltman.md`)
- Concept pages: `TitleCase.md` (e.g. `ReinforcementLearning.md`, `RAG.md`)

## Index Format

```markdown
# Wiki Index

## Overview
- [Overview](overview.md) — living synthesis

## Sources
- [Source Title](sources/slug.md) — one-line summary

## Entities
- [Entity Name](entities/EntityName.md) — one-line description

## Concepts
- [Concept Name](concepts/ConceptName.md) — one-line description

## Syntheses
- [Analysis Title](syntheses/slug.md) — what question it answers
```

## Log Format

Each entry starts with `## [YYYY-MM-DD] <operation> | <title>` so it's grep-parseable:

```
grep "^## \[" docs/second-brain/wiki/log.md | tail -10
```

Operations: `ingest`, `query`, `health`, `lint`
