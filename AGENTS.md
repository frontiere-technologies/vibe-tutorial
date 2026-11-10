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
  - `sources/libraries/trl/` — Python TRL library (the reference for the TRL rules and contracts).
  - `sources/microservices/web-trl/` — Flutter web app of the TRL calculator; front end only, with a simulated back end. Rules specific to it are in its own `AGENTS.md`.

The `sources/` layout fits service-based systems. For other kinds of project, replace the line above with the real folders, e.g. `app/` + `test/` for a single app or monolith, `lib/` + `test/` + `example/` for a published library, `notebooks/` + `data/` + `pipelines/` for data work, `infra/` + `modules/` for an infrastructure repository.

## Commands

*Fill in per project:* how to install, run, build, lint, format and test, and from which folder.

- Python tests (from the repository root): `python3 -m unittest discover -s sources/libraries -t sources/libraries`
- Flutter web app — from `sources/microservices/web-trl/`:
  - install dependencies: `flutter pub get`
  - run for development (hot reload): `flutter run -d chrome`
  - build and serve on its own at http://localhost:8080: `./run.sh` (port as first argument)
  - lint: `flutter analyze` · format: `dart format lib test`
  - test: `flutter test`
  - build only: `flutter build web --release` (output in `build/web/`)

## Stack

*Fill in per project:* languages and versions, frameworks, runtime and hosting, in one or two lines.

- Python 3.9+ (the version macOS ships), standard library only — libraries in `sources/libraries/`.
- Flutter stable 3.x with Dart 3 (null safety), Material 3, **web target only**, responsive for phone, tablet and desktop browsers — apps in `sources/microservices/web-*/`. No real back end yet: back-end calls are simulated in the app.

## Conventions

*Fill in per project:* architectural rules (layers and allowed dependencies between them), patterns to use or avoid, naming and code style, and the allow-list of approved ("certified") libraries. Do not add a dependency outside the allow-list without asking the user.

Python:

- Library code lives in `sources/libraries/<name>/`, one package per library, with its tests in `sources/libraries/<name>/tests/`. Both folders have an `__init__.py`.
- Pure functions, type hints everywhere, no I/O in library code.
- Approved libraries: the Python standard library. Nothing else.

Flutter:

- One app per folder `sources/microservices/web-<name>/`, created with `flutter create --platforms=web`. Only the `web/` platform folder exists.
- Layers in `lib/`, dependencies one way only: `ui/` → `state/` → `api/`. `api/` is the back-end contract (models with JSON, an abstract client); `mock_backend/` implements it and is imported only by `main.dart` and tests. The UI never computes domain results itself: it asks the API.
- Back-end contracts follow the Python libraries in `sources/libraries/`: same names (camelCase in Dart, snake_case on the wire), same fields, same rules and error messages. A change to a contract changes the Python library first, or is agreed with the user.
- State with `ChangeNotifier` controllers exposed through `InheritedNotifier`; no `setState` for app-wide state. Immutable models (`final` fields, `const` constructors, value equality).
- Responsive breakpoints: compact < 600 px, medium 600–1199 px, expanded ≥ 1200 px. Every screen works at all three.
- Colours, typography and spacing come only from the theme files in `lib/ui/theme/`; no literal colours in widgets.
- `const` constructors wherever possible, `flutter_lints` rules, `dart format` style.
- Approved packages: the Flutter SDK (`flutter`, `flutter_test`) and `flutter_lints`. Nothing else, fonts and icon packs included (use `Icons` from Material).

## Testing

*Fill in per project:* which kinds of test are required (unit, integration, end-to-end), where they live, what must be written test-first, and the checks that must pass before a change counts as done.

- Python: unit tests with `unittest`, written before the code they test (red, then green).
- Flutter: tests in `test/`, mirroring `lib/`, with `flutter_test`, written before the code (red, then green): unit tests for `mock_backend/` (a port of the Python library's tests) and `api/`, controller tests, widget tests of every screen at the three breakpoints (390, 800, 1400 px wide) and of the main user flows.
- A change is done only when every test passes and `flutter analyze` reports no issues.

## Boundaries

*Fill in per project:* files, folders and systems the agent must not change, or only change after asking (generated code, migrations already applied, vendored code, CI/CD, production configuration).

- Flutter: never commit `build/`, `.dart_tool/` or IDE files (they are in the app's `.gitignore`); `pubspec.lock` is committed. Do not add platform folders (`android/`, `ios/`, `macos/`, …) without asking.

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
