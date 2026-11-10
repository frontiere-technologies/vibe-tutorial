# web-trl — TRL Readiness

A responsive Flutter web app (phone, tablet, desktop; light and dark) that assigns the **Technology Readiness Level** of the components of a project by walking the NASA Technology Maturity Assessment flowchart, one yes/no question at a time.

Front end only: the back end is **simulated** in the app (`lib/mock_backend/`), with the same contracts as the Python library in [`sources/libraries/trl/`](../../libraries/trl/). It opens on a fictional sample project, *Lyra Pathfinder*, with 13 components covering every outcome.

## Run it

Needs Flutter (stable, 3.x) and `python3`.

```bash
./run.sh            # builds, then serves at http://localhost:8080
./run.sh 9000       # another port
```

For development, with hot reload: `flutter run -d chrome`.

The simulated back end lives in memory: reloading the page restores the sample project.

## What is inside

- **Overview** — project header with the target TRL (default 6, KDP C), KPI tiles, TRL distribution with the target line, components that need attention, and the text report of `render_trl_chart` to copy.
- **Components** — the product breakdown grouped by subsystem, filters, detail with the TRL ladder, the deciding question and the answers; add a component.
- **Assessment** — the ten questions verbatim from the handbook, stopping at the first yes; heritage components (question 2) can record an evaluated TRL 5, 6 or 7.
- **TRL guide** — the nine levels, KDP A/B/C products, heritage and lowest-TRL rules.

## Tests

```bash
flutter test        # port of the Python tests, API, state, widget tests at 390/800/1400 px
flutter analyze
```

Rules for changing this app: [`AGENTS.md`](AGENTS.md).
