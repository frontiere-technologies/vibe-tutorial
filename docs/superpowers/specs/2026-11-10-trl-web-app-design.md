# TRL web app — design

Date: 2026-11-10 · Status: approved (decisions delegated to the agent by the user)

## Intent

The same systems engineer as in the [TRL calculator design](2026-11-10-trl-calculator-design.md) now wants the assessment out of the Python script and in front of people: on a laptop at their desk, on a tablet in the review room, on a phone in the integration hall. A small, elegant web app that:

1. walks the NASA TMA questionnaire for one component, one question at a time, in flowchart order, stopping at the first "yes";
2. shows the resulting TRL, whether it meets the project's target, the gap, and the deciding question;
3. keeps the whole product breakdown of a sample project, so the app opens on real-looking content instead of an empty screen;
4. shows the TRL distribution of the project against the target, and the components that need attention before KDP C.

Front end only for now. Every call to a back end goes through one interface and is answered by a **simulated back end** inside the app, which mirrors the contracts of the Python `trl` library (`sources/libraries/trl/`). A real HTTP back end wrapping that library can replace the simulation later without touching the UI.

Knowledge comes from the wiki: `concepts/TechnologyReadinessLevel.md` (the nine levels, TRL 6 threshold, lowest-TRL rule), `concepts/TechnologyMaturityAssessment.md` (question sequence), `concepts/HeritageSystems.md` (TRL 5, then 6 or 7 once evaluated, never 9), `concepts/KeyDecisionPoint.md` (KDP A/B/C products), `concepts/ProductBreakdownStructure.md` (assessment runs on the PBS).

## Goals

- Flutter web app, responsive on phone, tablet and desktop, light and dark themes, visually polished.
- Questionnaire: the ten questions verbatim (English, as in the Python library), one per screen, with "Yes → TRL n" shown on each; undo the last answer; all "no" ends with the flowchart's "Rethink position regarding this technology!".
- Heritage: a "yes" to question 2 shows TRL 5 *initially, until differences are evaluated*, and offers the evaluated TRL 5, 6 or 7 — never 8 or 9.
- Result: reported TRL, flowchart TRL when different, target, meets / below, gap, deciding question, outcome text exactly as the Python library builds it.
- Project view: KPI tiles, TRL distribution chart with the target line, "needs attention" list, the text chart of `render_trl_chart` copyable to the clipboard for a report.
- Project target TRL changeable (1–9, default 6 = KDP C); all results recomputed by the back end.
- Reference page: the nine levels, KDP products, heritage and lowest-TRL rules.
- Seeded sample project (fictional *Lyra Pathfinder* smallsat, 13 components over 7 subsystems) covering every outcome: TRL 1 to 9, heritage provisional, heritage evaluated, rethink, not yet assessed.
- Launchable on its own with one command; no back end, no account, no network beyond what Flutter web itself loads.

## Non-goals (for now)

- A real back end, persistence across reloads (the simulated back end is in memory and reseeds on reload), authentication, multiple projects.
- System-level TRL roll-up with integration effects. The overview shows the *lowest component TRL* (the wiki's lowest-TRL rule) and says explicitly that integration is not assessed.
- AD², technology development plans, cost and schedule.
- Translating the questions: they stay verbatim in English. The rest of the UI is in English too, for consistency.
- Native mobile builds (iOS, Android, desktop): web only; phones and tablets use it in the browser.

## Anti-goals

- The UI computing a TRL itself: only the back end (simulated today) calls `assess`.
- A heritage component shown as TRL 8 or 9, or an evaluated TRL that looks like a plain flowchart TRL.
- A TRL shown for an all-"no" questionnaire.
- Any package outside the allow-list in `AGENTS.md`.

## Constraints (from `AGENTS.md`, as updated for this change)

- Flutter stable 3.x, Dart 3, web target only; Flutter SDK packages only (`flutter`, `flutter_test`, `flutter_lints`).
- App in `sources/microservices/web-trl/`, layers `api/` → `mock_backend/`, `state/`, `ui/` with one-way dependencies.
- Tests first; `flutter analyze` clean and `flutter test` green before a change is done.

## Architecture

```
lib/
├── main.dart                  wires MockTrlApi → AppController → TrlApp
├── api/                       the contract the UI depends on
│   ├── models.dart            Question, Assessment, Component, Project (+ JSON, snake_case keys)
│   ├── trl_api.dart           abstract TrlApi, TrlApiException
├── mock_backend/              the simulated server — the only code that knows the TRL rules
│   ├── trl/                   Dart port of the Python `trl` package
│   │   ├── questions.dart     Question, questions, heritageQuestionNumber, rethink
│   │   ├── assessment.dart    Assessment, assess(), defaultTargetTrl
│   │   └── chart.dart         trlDistribution(), renderTrlChart()
│   ├── seed.dart              the Lyra Pathfinder sample project
│   └── mock_trl_api.dart      implements TrlApi: latency, JSON round trip, errors
├── state/                     ChangeNotifier controllers (no UI imports)
└── ui/                        theme, responsive shell, screens, widgets
```

Dependencies go one way: `ui` → `state` → `api`; `main.dart` is the only place that knows `mock_backend`. The mock back end converts its results to JSON and the API layer parses them back, so the wire format is exercised on every call, as it will be with HTTP.

### Contract mapping

| Python (`trl`) | Dart port (`mock_backend/trl`) | Wire / API (`api/`) |
|---|---|---|
| `Question(number, text, trl_if_yes, note)` | `Question(number, text, trlIfYes, note)` | `{"number", "text", "trl_if_yes", "note"}` |
| `QUESTIONS`, `HERITAGE_QUESTION_NUMBER`, `RETHINK` | `questions`, `heritageQuestionNumber`, `rethink` | `GET /questions` |
| `assess(answers, target_trl=6, evaluated_heritage_trl=None) -> Assessment` | `assess(answers, {targetTrl = 6, evaluatedHeritageTrl})` | `POST /assess` |
| `Assessment` fields `trl, flowchart_trl, heritage_evaluated, target_trl, meets_target, gap, deciding_question, outcome` | same, camelCase | same, snake_case |
| `ValueError(message)` | `ArgumentError(message)`, same messages | `TrlApiException(400, message)` |
| `trl_distribution(assessments)` (9…1, then None) | `trlDistribution(...)` (9…1, then null) | `GET /project/distribution` → `[{"trl": 9, "count": n}, …, {"trl": null, …}]` |
| `render_trl_chart(assessments, target_trl=6)` | `renderTrlChart(...)` | `GET /project/chart` → text |

Dart's type system already rules out non-bool answers and non-int targets, so those Python checks have no Dart counterpart; every other validation and message is kept.

### `TrlApi` (simulated endpoints)

| Method | Simulates | Notes |
|---|---|---|
| `fetchQuestions()` | `GET /questions` | |
| `assess(answers, targetTrl, evaluatedHeritageTrl)` | `POST /assess` | preview, nothing saved |
| `fetchProject()` | `GET /project` | project with target and components, each with its saved answers and assessment (null if not assessed) |
| `saveAssessment(componentId, answers, evaluatedHeritageTrl)` | `PUT /components/{id}/assessment` | recomputed with the project target |
| `addComponent(name, subsystem, description)` | `POST /components` | not assessed yet |
| `setTargetTrl(targetTrl)` | `PUT /project/target` | every assessment recomputed |
| `fetchDistribution()` | `GET /project/distribution` | |
| `fetchTextChart()` | `GET /project/chart` | |

Latency is simulated (default 300 ms, zero in tests).

## UI

- **Shell:** compact (< 600 px) bottom `NavigationBar`; medium (600–1199) `NavigationRail`; expanded (≥ 1200) extended rail. Destinations: *Overview*, *Components*, *TRL guide*. A theme toggle (system / light / dark).
- **Overview:** project header (name, phase, target selector with the KDP hint), four KPI tiles (assessed, meet target, below target, lowest TRL), distribution chart with target line, "needs attention" list sorted by gap, "Copy text report" button.
- **Components:** grouped by subsystem, filter chips (All, Below target, Heritage, Not assessed). Selecting one opens its detail beside the list (expanded) or as a page (compact, medium). Detail: TRL ladder 1–9 with the component's level and the target marked, outcome, deciding question, answers trail, heritage badge, *Assess* / *Reassess* button. A button adds a component.
- **Assessment flow:** full-screen page, progress *Question n of 10*, the question, "Yes → TRL n", large Yes / No buttons, undo; on the first "yes" (or ten "no") the back end's preview result; for question 2 a segmented choice *Not evaluated yet · 5 · 6 · 7*; *Save*.
- **TRL guide:** the nine levels as a ladder, KDP A/B/C table, heritage and lowest-TRL rules, with the handbook reference.
- **Look:** Material 3, deep-space palette (indigo/navy surfaces, teal for "meets target", amber for "below", rose for "rethink"), TRL badges coloured by maturity band (research 1–3, development 4–5, demonstration 6–7, flight 8–9), generous spacing, rounded cards with hairline borders, subtle animations. Colours only from the theme file.

## Testing

- Port of every Python test for questions, `assess`, distribution and text chart.
- JSON round trip of the API models; `MockTrlApi` behaviour (seed, save, target change, validation error → `TrlApiException`).
- Controller tests with the mock at zero latency.
- Widget tests: the shell at 390, 800 and 1400 px wide; overview content from the seed; the full assessment flow (heritage: No, Yes, evaluate 6, Save → component shows TRL 6 and the "evaluated" badge).

## Running

`./run.sh` in `sources/microservices/web-trl/` builds the web app and serves it at http://localhost:8080 (no Chrome device needed); `flutter run -d chrome` for development with hot reload.
