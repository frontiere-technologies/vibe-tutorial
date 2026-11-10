# AGENTS.md

This repository holds project code and a **second brain**: a wiki of project knowledge maintained by coding agents. This file is the canonical instructions file for every AI coding assistant; tool-specific files (`CLAUDE.md`, `GEMINI.md`, …) only import it.

Read also the ./README.md file.

The sections marked *Fill in per project* start as "Not defined yet" and are completed for each project. A folder of the code (e.g. a service) can add its own `AGENTS.md` with rules that apply only there; those rules add to this file and win where they are more specific.

## Layout

*Fill in per project.* Always present:

- `docs/second-brain/` — knowledge base: source documents (`raw/`), the wiki (`wiki/`) and saved reports (`reports/`). `docs/second-brain/wiki/sources/` holds summaries of source documents, not code.
- `docs/` — other project documents (specs, plans, reviews, work in progress).

Code layout of this project:

- `sources/` — code and operations: `microservices/`, `libraries/`, `devops/`, `tests/` (e2e). See `sources/README.md` for what goes where.

The `sources/` layout fits service-based systems. For other kinds of project, replace the line above with the real folders, e.g. `app/` + `test/` for a single app or monolith, `lib/` + `test/` + `example/` for a published library, `notebooks/` + `data/` + `pipelines/` for data work, `infra/` + `modules/` for an infrastructure repository.

## Commands

*Fill in per project:* how to install, run, build, lint, format and test, and from which folder.

- Run the tests: `python3 -m unittest discover -s sources/libraries -t sources/libraries`

## Stack

*Fill in per project:* languages and versions, frameworks, runtime and hosting, in one or two lines.

Python 3.9+ (the version macOS ships), standard library only.

## Conventions

*Fill in per project:* architectural rules (layers and allowed dependencies between them), patterns to use or avoid, naming and code style, and the allow-list of approved ("certified") libraries. Do not add a dependency outside the allow-list without asking the user.

- Library code lives in `sources/libraries/<name>/`, one package per library, with its tests in `sources/libraries/<name>/tests/`. Both folders have an `__init__.py`.
- Pure functions, type hints everywhere, no I/O in library code.
- Approved libraries: the Python standard library. Nothing else.

## Testing

*Fill in per project:* which kinds of test are required (unit, integration, end-to-end), where they live, what must be written test-first, and the checks that must pass before a change counts as done.

- Unit tests with `unittest`, written before the code they test (red, then green).
- A change is done only when every test passes.

## Boundaries

*Fill in per project:* files, folders and systems the agent must not change, or only change after asking (generated code, migrations already applied, vendored code, CI/CD, production configuration).

Always, in every project:

- Never commit secrets: commit only templates (`*.example`, `.env.template`) and keep real values in ignored files.
- Do not change other projects or shared infrastructure from this repository.

## Using the second brain

When a task needs project or domain context (designing, coding, reviewing, answering questions):
1. Read `docs/second-brain/wiki/index.md` to find the relevant pages
2. Read only those pages, following their `[[wikilinks]]` as needed (`[[Name]]` is the file `Name.md` under `docs/second-brain/wiki/`)
3. Mention which wiki pages you relied on

Do not modify anything under `docs/second-brain/` while doing other work unless the user asks. If the wiki looks wrong or is missing something, tell the user.

Wiki maintenance requests — `ingest <file>`, `query: <question>`, `health`, `lint`, or the same in plain words — follow `docs/second-brain/SCHEMA.md`. Read that file first; it is not loaded automatically. The same workflows are Agent Skills in `.agents/skills/` (`wiki-ingest`, `wiki-query`, `wiki-health`, `wiki-lint`). Codex, Antigravity and OpenCode read that folder directly; `.claude/skills` is a symlink to it for Claude Code. In Claude Code and Antigravity they are slash commands (`/wiki-ingest`, …); in Codex mention them with `$wiki-ingest`.

## Commit AI-tooling folders to Git

Folders that AI workflow plugins create under `docs/` (e.g. `docs/superpowers/` when Superpowers is used, containing plans and other workflow artifacts) must be committed to Git, not left untracked or gitignored. They are part of the project's traceable history of AI-assisted work.

The same applies to `.agents/skills/` (the shared skills), to the `agents/` and `skills/` folders inside `.claude/`, and to the equivalent folders inside any other AI coding CLI's config directory (`.github/`, `.codex/`, `.gemini/`, `.opencode/`, etc. — the config-dir table in `vibe/README.md` lists them, when that folder is present). These contain the agent and skill definitions the project standardizes on and must be tracked so every contributor and every AI assistant gets the same setup.
