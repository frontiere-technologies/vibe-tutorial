# Second brain

How to use the project's second brain: a wiki of project knowledge in `docs/second-brain/`, written and maintained by the coding agent. For the rest of the vibe-coding environment (Superpowers, agents, skills, MCP servers, `AGENTS.md`), see [README.md](README.md).

**A coding agent skill.** Drop source documents into `docs/second-brain/raw/` and tell the agent to ingest them — it reads them, extracts knowledge, and builds a persistent interlinked wiki. Every new source makes the wiki richer. You never write it.

> Most knowledge tools make you search your own notes. This one reads everything you've collected and writes a structured wiki that compounds over time — cross-references already built, contradictions already flagged, synthesis already done.

```
ingest docs/second-brain/raw/papers/attention-is-all-you-need.md
```

```
docs/second-brain/
├── SCHEMA.md             wiki rules and workflows — read on demand
├── raw/                  your source documents — drop files here
├── wiki/
│   ├── index.md          catalog of all pages — updated on every ingest
│   ├── log.md            append-only record of every operation
│   ├── overview.md       living synthesis across all sources
│   ├── sources/          one summary page per source document
│   ├── entities/         people, companies, projects — auto-created
│   ├── concepts/         ideas, frameworks, methods — auto-created
│   └── syntheses/        query answers filed back as wiki pages
└── reports/              saved health and lint reports, one file per date
```

## Getting started

**Requires:** [Claude Code](https://claude.ai/code), [Codex](https://openai.com/codex), [Antigravity](https://antigravity.google), [OpenCode](https://opencode.ai), [Gemini CLI](https://github.com/google-gemini/gemini-cli), or any agent that reads a config file. To set up the repository, follow step 0 of [README.md](README.md).

Open the repository root in your agent — no API key or Python setup needed (wiki rules are in `docs/second-brain/SCHEMA.md`, read on demand):

```bash
claude      # reads CLAUDE.md (→ AGENTS.md) + .claude/skills (→ .agents/skills)
codex       # reads AGENTS.md + .agents/skills
agy         # reads AGENTS.md + .agents/skills
opencode    # reads AGENTS.md + .agents/skills
gemini      # reads GEMINI.md (→ AGENTS.md)
```

## Usage

All agents understand natural language and shorthand triggers:

```
ingest docs/second-brain/raw/papers/my-paper.md              # ingest a markdown source
ingest report.pdf                          # PDFs are read directly
query: what are the main themes?           # synthesize answer from wiki pages
health                                     # fast structural check (empty pages, index, log)
lint                                       # find orphans, contradictions, gaps
```

Plain English works too:
```
"Ingest this paper: docs/second-brain/raw/papers/llama2.md"
"What does the wiki say about attention mechanisms?"
"Check for contradictions across sources"
```

The workflows are also packaged as [Agent Skills](https://agentskills.io) in `.agents/skills/` — one folder shared by every agent (`.claude/skills` is a symlink to it):

| Agent | How to invoke |
|---|---|
| Claude Code | `/wiki-ingest`, `/wiki-query`, `/wiki-health`, `/wiki-lint` |
| Antigravity (`agy`) | same slash commands |
| Codex | `$wiki-ingest` (or pick from `/skills`) |
| OpenCode | ask in natural language — the agent loads the matching skill |

Every agent can also pick a skill on its own when your request matches it, and the natural language triggers above always work. The `/wiki-…` examples below use the slash form.

> On Windows, `.claude/skills` must be a real symlink: see [Symlinks on Windows](README.md#symlinks-on-windows).

Works with markdown, PDF and other text formats directly. Office and media files (DOCX, PPTX, XLSX, EPUB, audio) need a markdown version first — see [Multi-Format Ingest](#multi-format-ingest).

## What You Get

**Persistent wiki** — structured markdown pages that accumulate across sessions. Unlike chat, nothing is lost.

**Entity pages** — auto-created for every person, company, or project mentioned across sources. Updated each time a new source references them.

**Concept pages** — auto-created for every key idea or framework. Cross-referenced to every source that discusses them.

**Living overview** — `docs/second-brain/wiki/overview.md` is revised on every ingest to reflect the current synthesis across everything you've read.

**Contradiction flags** — when a new source contradicts an existing claim, it's flagged at ingest time, not buried until query time.

**Lint reports** — orphan pages, broken links, missing entity pages, data gaps with suggested sources to fill them.

## Use Cases

### Research

Going deep on a topic over weeks — reading papers, articles, reports.

```
/wiki-ingest docs/second-brain/raw/papers/attention-is-all-you-need.md
/wiki-ingest docs/second-brain/raw/papers/llama2.md
/wiki-ingest docs/second-brain/raw/papers/rag-survey.md

# Wiki builds entity pages (Meta AI, Google Brain) and
# concept pages (Attention, RLHF, Context Window) automatically.

/wiki-query "What are the main approaches to reducing hallucination?"
/wiki-query "How has context window size evolved across models?"

/wiki-lint
# → "No sources on mixture-of-experts — consider the Mixtral paper"
```

By the end you have a structured, interlinked reference — not a folder of PDFs you'll never reopen.

---

### Reading a Book

File each chapter as you go. Build out pages for characters, themes, arguments.

```
/wiki-ingest docs/second-brain/raw/book/chapter-01.md
/wiki-ingest docs/second-brain/raw/book/chapter-02.md

# Wiki creates entity and theme pages automatically.

/wiki-query "How has the protagonist's motivation evolved?"
/wiki-query "What contradictions exist in the author's argument so far?"
```

Think fan wikis like Tolkien Gateway — built as you read, with the agent doing all the cross-referencing.

---

### Personal Knowledge Base

Track goals, health, habits, self-improvement — file journal entries, articles, podcast notes.

```
/wiki-ingest docs/second-brain/raw/journal/2026-01-week1.md
/wiki-ingest docs/second-brain/raw/articles/huberman-sleep-protocol.md
/wiki-ingest docs/second-brain/raw/articles/atomic-habits-summary.md

/wiki-query "What patterns show up in my journal entries about energy?"
/wiki-query "What habits have I tried and what was the outcome?"
```

The wiki builds a structured picture over time. Concepts like "Sleep", "Exercise", "Deep Work" accumulate evidence from every source filed.

---

### Business / Team Intelligence

Feed in meeting transcripts, project docs, customer calls.

```
/wiki-ingest docs/second-brain/raw/meetings/q1-planning-transcript.md
/wiki-ingest docs/second-brain/raw/docs/product-roadmap-2026.md
/wiki-ingest docs/second-brain/raw/calls/customer-interview-acme.md

/wiki-query "What feature requests have come up most across customer calls?"
/wiki-query "What decisions were made in Q1 and what was the rationale?"

/wiki-lint
# → "Project X mentioned in 5 pages but no dedicated page"
# → "Roadmap contradicts customer interview on priority of feature Y"
```

The wiki stays current because the agent does the maintenance no one wants to do.

---

### Competitive Analysis

Track a company, market, or technology over time.

```
/wiki-ingest docs/second-brain/raw/competitors/openai-announcements.md
/wiki-ingest docs/second-brain/raw/market/ai-funding-report-q1.md

/wiki-query "How do OpenAI and Anthropic differ on safety approach?"
/wiki-query "Which companies announced multimodal models in the last 6 months?"
/wiki-query "Competitive landscape summary as of today"
# → agent shows the answer, then asks if you want to save it as a synthesis page
```

## AGENTS.md and SCHEMA.md

The instructions are split so that agents only load what they need:

- **`AGENTS.md`** — loaded on every interaction. Short: the repository layout, how to use the wiki as knowledge while coding (read `docs/second-brain/wiki/index.md`, then only the relevant pages), and where the maintenance rules are. `CLAUDE.md` and `GEMINI.md` contain only `@AGENTS.md`, which Claude Code and Gemini CLI resolve as an import.
- **`docs/second-brain/SCHEMA.md`** — read only for wiki work (ingest, query, health, lint): directory layout, page formats, templates, workflows, naming conventions, index and log format. This is the file to edit to customize the wiki for your domain. It is deliberately not named `AGENTS.md`/`CLAUDE.md`, so no agent loads it automatically when reading wiki files.

| Agent | Always reads | Reads for wiki work |
|---|---|---|
| Claude Code | `CLAUDE.md` → `AGENTS.md` | skills → `SCHEMA.md` |
| Codex / OpenCode / Antigravity | `AGENTS.md` | skills → `SCHEMA.md` |
| Gemini CLI | `GEMINI.md` → `AGENTS.md` | `SCHEMA.md` (as `AGENTS.md` instructs) |

## What Makes This Different from RAG

| RAG | Second brain |
|---|---|
| Re-derives knowledge every query | Compiles once, keeps current |
| Raw chunks as retrieval unit | Structured wiki pages |
| No cross-references | Cross-references pre-built |
| Contradictions surface at query time (maybe) | Flagged at ingest time |
| No accumulation | Every source makes the wiki richer |

## Obsidian Integration

The wiki is designed to be browsed seamlessly in [Obsidian](https://obsidian.md). Since the agent maintains consistent `[[wikilinks]]`, you get a naturally growing knowledge graph in your vault.

### Vault Symlink Pattern
If you want to keep this repository separate from your main personal vault, use symlinks:
1. Keep your working agent repository at e.g., `~/vibe`
2. Create a symlink from your main Obsidian vault:
   ```bash
   ln -sfn ~/vibe/docs/second-brain/wiki ~/your-obsidian-vault/wiki
   ```
3. Use the [Obsidian Web Clipper](https://obsidian.md/clipper) or write directly to `docs/second-brain/raw/` in the agent repo to queue items for ingestion.

> **Note:** If you ever move your local repo directory, remember to update the symlink, otherwise the `docs/second-brain/wiki/` directory will appear missing in Obsidian.

### Recommended .obsidian Config
- **Graph View:** Filter out `index.md` and `log.md` (e.g. `-file:index.md -file:log.md`) to avoid them becoming gravity wells in your Obsidian graph.
- **Dataview:** Use the community plugin [Dataview](https://blacksmithgu.github.io/obsidian-dataview/) to query the YAML frontmatter the agent automatically injects (e.g., `type: source`, `tags: [diary]`).

## Multi-Format Ingest

The agent reads these directly:
`.md` `.pdf` `.txt` `.html` `.htm` `.csv` `.tsv` `.json` `.xml` `.yaml` `.yml` `.rst` `.ipynb`

```
ingest report.pdf
ingest page.html
```

Binary office and media formats (`.docx`, `.pptx`, `.xlsx`, `.xls`, `.epub`, `.rtf`, `.wav`, `.mp3`) must be converted to markdown first. If [markitdown](https://github.com/microsoft/markitdown) is installed (`pip install 'markitdown[all]'`), the agent converts them for you:

```bash
markitdown docs/second-brain/raw/meeting-notes.docx -o docs/second-brain/raw/meeting-notes.md
```

Otherwise, export the file to markdown or PDF yourself and ingest that.

## Tips

- Just drop files (markdown, PDF, text) into `docs/second-brain/raw/` and `ingest` them
- Query answers are shown first — the agent then asks if you want to file them as synthesis pages. Your explorations compound just like ingested sources
- The wiki is a git repo — version history for free

## Tech Stack

Your coding agent (Claude Code, Codex, Gemini CLI, …) plus plain markdown files. No scripts, no server, no database.

## Related

- [Vannevar Bush's Memex (1945)](https://en.wikipedia.org/wiki/Memex) — the original vision this resembles
