# Tutorial

Hands-on lessons on vibe coding with this template: each one is a short session with an AI coding CLI, with the prompts to type and what to expect back. Do them in order; each lesson lists what it needs.

The thread running through all of them: let the agent write the code, but keep it inside boundaries you set — project knowledge in the second brain, technical constraints in `AGENTS.md`, plans as checklists, tests as the definition of done.

## Before you start

- Setup steps 0–2 of [`../README.md`](../README.md) done, Superpowers included: the lessons use its workflow for every change
- Claude Code as the reference CLI; other CLIs work with the same prompts (skills are `$wiki-ingest` in Codex, plain `ingest …` anywhere)
- `python3` (3.9 or later) for the lesson code — standard library only, nothing to install

## Run each lesson on a throwaway branch

A lesson changes the repository: it fills the wiki, writes rules into `AGENTS.md`, adds code, specs and plans. None of that belongs to your project, so start every lesson on its own branch and delete the branch at the end:

```bash
git switch -c tutorial/01          # before the lesson, from the branch you build on
# … follow the lesson …
git switch -                       # back to the branch you started from
git branch -D tutorial/01          # throw the lesson away
git worktree prune                 # forget worktrees the lesson left behind, if any
```

Never merge a tutorial branch into your project's branches. When a lesson asks you to merge (e.g. at the end of the Superpowers workflow), the merge target is the tutorial branch itself, so everything is still thrown away with it.

## Sample source

`examples/nasa_systems_engineering_handbook_0_excerpt_TRL.pdf` is a 15-page excerpt of the NASA Systems Engineering Handbook (SP-2016-6105 Rev2), with what the lessons need and nothing more (page numbers of the original PDF):

- pages 1–2 — cover and imprint, to identify the document
- page 8 — Preface: what the handbook is and how it evolved
- pages 11–12 — 1.0 Introduction: purpose and scope
- page 19 — Table 2.2-1, *Project Life Cycle Phases*: the phases the key decision points sit between
- page 205 — Glossary: the definition of TRL, and that a TRL of 6 is typically required
- pages 216–223 — Appendix G, *Technology Assessment/Insertion*: the TRL scale, the TRL questionnaire, how integration and heritage affect a TRL, and the readiness required at each key decision point

Keeping only those pages makes ingesting quick.

`examples/nasa_systems_engineering_handbook_0.pdf` is the full handbook (297 pages), from https://www.nasa.gov/wp-content/uploads/2018/09/nasa_systems_engineering_handbook_0.pdf. It is kept for reference only: the lessons do not ingest it.

Lessons copy the excerpt into `docs/second-brain/raw/` before ingesting it; it is not part of the project knowledge until then.

## Lessons

| # | Lesson | Time | What you learn |
|---|---|---|---|
| 01 | [From a document to tested code](01-from-document-to-code.md) | ~45 min | Ingest a source, query the wiki, set constraints in `AGENTS.md`, then the Superpowers workflow: design, plan, isolated branch, test-first implementation, finish; check the agent stays inside the rules |

Planned:

- 02 — Quality reviews with the reviewer agents (`code-reviewer`, `architect-reviewer`, `ui-ux-tester`)
- 03 — Superpowers in depth: changing an existing feature, systematic debugging, receiving code review, parallel agents
- 04 — Connecting MCP servers (GitHub, documentation, data)
- 05 — Same repository, different CLIs (Claude Code, Codex, Gemini CLI) on the same `AGENTS.md`
- 06 — A complete app: rebuilding a small version of the Mission Readiness Map
