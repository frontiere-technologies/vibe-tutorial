# AGENTS.md — web-trl

Rules for the TRL web app. They add to the repository's [`AGENTS.md`](../../../AGENTS.md) and win where they are more specific. Design: [`docs/superpowers/specs/2026-11-10-trl-web-app-design.md`](../../../docs/superpowers/specs/2026-11-10-trl-web-app-design.md).

## Commands (from this folder)

- `./run.sh [port]` — build and serve on its own at http://localhost:8080
- `flutter run -d chrome` — development with hot reload
- `flutter test` · `flutter analyze` · `dart format lib test` (page width 100, set in `analysis_options.yaml`)

## Layout

```
lib/
├── main.dart          the only file that knows the back end is simulated
├── api/               contract: models with JSON (snake_case keys) + abstract TrlApi
├── mock_backend/      simulated back end
│   ├── trl/           Dart port of sources/libraries/trl — the only place with TRL rules
│   ├── seed.dart      sample project shown at start-up
│   └── mock_trl_api.dart
├── state/             ChangeNotifier controllers, AppScope (InheritedNotifier)
└── ui/                theme/, content/, widgets/, screens/, app_shell.dart, app.dart
test/                  mirrors lib/
```

## Rules

- `mock_backend/trl/` stays a faithful port of `sources/libraries/trl/`: when the Python library changes, port the change and its tests in the same piece of work. Question texts and outcome strings stay verbatim (English, handbook wording).
- The UI shows what the API returns; it never calls `mock_backend/` and never derives a TRL itself. Counting and sorting results for display is fine.
- Every simulated endpoint goes through JSON in `MockTrlApi._call`, with the latency set in `main.dart` (300 ms) and zero in tests.
- Seed content is fictional and covers every outcome (TRL 1–9, heritage provisional and evaluated, rethink, not assessed). Tests rely on its counts: change them together.
- Reference text in `ui/content/` comes from the wiki pages it names; cite the handbook, do not invent definitions.
- Widget keys used by tests (`answer-yes`, `answer-no`, `undo-answer`, `save-assessment`, `heritage-5/6/7`, `start-assessment`, `filter-<name>`, `component-<id>`, `target-menu`, `target-<n>`) are part of the test contract: keep them stable.
- Local, short-lived UI state (selected tab, filter, form fields, one questionnaire walk) may use `StatefulWidget`; anything shared goes through `AppController`.
