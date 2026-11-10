# 02 — From a document to a web app

**Time:** about 90 minutes · **Needs:** setup steps 0–2 (Superpowers included), Flutter stable 3.x with Chrome (`flutter doctor`), `python3` · **Result:** a responsive Flutter web app for phone, tablet and desktop, front end only, with a simulated back end whose contracts follow the Python library of lesson 01, opening on sample content instead of an empty screen

Lesson 01 turned the NASA handbook into a tested Python library. This lesson puts the same knowledge in front of people: a polished web app to walk the TRL questionnaire, look at a whole project's maturity before a review, and read the TRL scale. New in this lesson:

- **adding a stack to `AGENTS.md`** — Flutter next to Python, with its own allow-list, layers and test rules;
- **contract first** — the UI talks to one interface; a simulated back end answers it with the same names, fields, rules and error messages as the Python library, so a real back end can replace it later without touching the UI;
- **seed content** — the app opens on a believable sample project, chosen to show every outcome;
- **visual checks** — the same screens at three widths, by widget tests and by eye.

It works on its own: you do not need anything left over from lesson 01.

Prompts to type into the CLI are in quotes; shell commands are in code blocks. Exact file names, wording and look will differ from run to run.

---

## Step 0 — Start the branch

Lessons run on throwaway branches (see [the tutorial's README](README.md#run-each-lesson-on-a-throwaway-branch)). Pick the case that applies.

**A — you still have lesson 01's branch** (wiki, rules and `sources/libraries/trl/` are there):

```bash
git switch tutorial/01
git switch -c tutorial/02
```

**B — starting fresh** (the usual case):

```bash
git switch -c tutorial/02
mkdir -p docs/second-brain/raw/examples
cp vibe/tutorial/examples/nasa_systems_engineering_handbook_0_excerpt_TRL.pdf docs/second-brain/raw/examples/
cp vibe/tutorial/examples/trl-library-contract.md docs/trl-library-contract.md
```

then, in the CLI, give the agent the knowledge (as in lesson 01, a few minutes):

> `/wiki-ingest docs/second-brain/raw/examples/nasa_systems_engineering_handbook_0_excerpt_TRL.pdf`

`docs/trl-library-contract.md` stands in for the library you would have built in lesson 01: its classes, functions, rules, outcome texts and error messages. It is a project document, not a source for the wiki, so it is not ingested.

Either way, check the toolchain before going on:

```bash
flutter doctor
```

**Expect:** Flutter and Chrome with a green tick. Android, Xcode and the other platforms may show problems: this lesson builds for the web only, so they do not matter.

## Step 1 — Add the stack to the rules

`AGENTS.md` only knows Python so far. Open it and add the Flutter rules below to the sections they belong to; keep the Python lines that are already there (in case B, also add the Python lines of lesson 01, step 3, so the contract file has a stack to refer to).

```markdown
## Commands

- Flutter web app — from `sources/microservices/web-trl/`:
  - install dependencies: `flutter pub get`
  - run for development (hot reload): `flutter run -d chrome`
  - build and serve on its own at http://localhost:8080: `./run.sh` (port as first argument)
  - lint: `flutter analyze` · format: `dart format lib test`
  - test: `flutter test`

## Stack

- Flutter stable 3.x with Dart 3, Material 3, **web target only**, responsive for phone, tablet and desktop browsers — apps in `sources/microservices/web-*/`. No real back end yet: back-end calls are simulated in the app.

## Conventions

Flutter:

- One app per folder `sources/microservices/web-<name>/`, created with `flutter create --platforms=web`. Only the `web/` platform folder exists.
- Layers in `lib/`, dependencies one way only: `ui/` → `state/` → `api/`. `api/` is the back-end contract (models with JSON, an abstract client); `mock_backend/` implements it and is imported only by `main.dart` and tests. The UI never computes domain results itself: it asks the API.
- Back-end contracts follow the Python library (`sources/libraries/trl/`, or `docs/trl-library-contract.md` when the library is not in the repository): same names (camelCase in Dart, snake_case on the wire), same fields, same rules and error messages.
- State with `ChangeNotifier` controllers exposed through `InheritedNotifier`; no `setState` for app-wide state. Immutable models with value equality.
- Responsive breakpoints: compact < 600 px, medium 600–1199 px, expanded ≥ 1200 px. Every screen works at all three.
- Colours, typography and spacing come only from the theme files in `lib/ui/theme/`; no literal colours in widgets.
- Approved packages: the Flutter SDK (`flutter`, `flutter_test`) and `flutter_lints`. Nothing else, fonts and icon packs included.

## Testing

- Flutter: tests in `test/`, mirroring `lib/`, written before the code (red, then green): unit tests for `mock_backend/` (a port of the Python library's tests) and `api/`, controller tests, widget tests of every screen at 390, 800 and 1400 px wide and of the main user flows.
- A change is done only when every test passes and `flutter analyze` reports no issues.

## Boundaries

- Flutter: never commit `build/`, `.dart_tool/` or IDE files; `pubspec.lock` is committed. Do not add platform folders (`android/`, `ios/`, …) without asking.
```

**Why these rules:**

- *Approved packages: the SDK only.* A design request ("make it elegant") is exactly when an agent reaches for packages: a state-management library, Google Fonts (which also downloads fonts from the network at run time), a charts package. The allow-list makes that a question for you, not a silent choice.
- *Layers and "the UI never computes domain results".* Without it, the quickest way to show a TRL is to compute it in the widget, and the "simulated back end" becomes a fiction.
- *Contracts follow the Python library.* The web app and the Python code agree on one vocabulary; the day a real back end exists, it is the Python library behind HTTP.
- *Breakpoints and three test widths.* "Responsive" becomes something a test can check.
- *Theme files only.* Elegance comes from a small, consistent set of colours and sizes, not from values scattered in widgets.

Commit before going on: Superpowers builds in a worktree from the last commit.

```bash
git add -A && git commit -m "Add the Flutter stack to the project rules"
```

## Step 2 — Describe the app

Start a new session, so the agent loads the new rules, and describe what you want, not how:

> "I'd like a web app, usable on phone, tablet and desktop, to assess the TRL of the components of a space project with the NASA questionnaire, see the whole project against the target TRL before a review, and read the TRL scale. It should look polished. Front end only for now: simulate the back end, but follow the contracts of the TRL library. Open it on a sample project so it is never empty, and make it launchable on its own with one command."

`brainstorming` asks its questions one at a time. Decisions to give when they come up, for example:

- three places: an overview of the project, the list of components with their detail, and a TRL guide; the questionnaire is a flow opened from a component
- one question per screen, verbatim, showing what a "yes" gives; an undo; the result comes from the back end, never from the UI
- heritage (question 2): show TRL 5 as provisional and let the user record an evaluated 5, 6 or 7
- the project has a target TRL, 6 by default (KDP C), that can be changed; every result is recomputed
- sample project: fictional, about a dozen components over several subsystems, covering every outcome (TRL 1 to 9, heritage provisional and evaluated, "rethink", one not assessed)
- look: a dark "deep space" theme and a light one, with colour meaning something: meets target, below target, rethink, and a colour ramp for TRL 1–9
- launch: one script that builds the app and serves it locally

**Expect:**

- a design document in `docs/superpowers/specs/` with the intent, goals, non-goals and anti-goals, and a **contract mapping**: each Python name, field and error next to its Dart and JSON counterpart, and the list of simulated endpoints
- the constraints from step 1 restated without you mentioning them: SDK packages only, layers, breakpoints, tests first
- knowledge from the wiki (the nine levels, KDP C, heritage, lowest-TRL rule), with the pages cited

**Check:**

- Does the design keep TRL rules out of the UI? Look for a sentence like "only the back end calls `assess`".
- Does the sample content cover every outcome? A sample with only happy cases hides half the screens.
- Does it say what is *not* done: no persistence, no real back end, no system-level TRL with integration effects?

## Step 3 — Review the plan

Approve the design; `writing-plans` saves a plan to `docs/superpowers/plans/`.

**Expect** tasks in an order that builds on tested ground:

1. the Dart port of the library with the Python tests ported first (red, then green)
2. API models and their JSON round trip
3. the simulated back end and its seed
4. the controllers
5. the theme, then the screens, each with widget tests at 390, 800 and 1400 px
6. the launch script

**Check:** the test commands are the ones in `AGENTS.md` (`flutter test`, `flutter analyze`), and no task adds a package to `pubspec.yaml`.

Choose *Subagent-driven* or *Native* as in lesson 01. The UI tasks are larger than lesson 01's: per-task reviews catch layout problems earlier.

## Step 4 — Build test-first on an isolated branch

Accept the worktree and let it run.

**Expect:**

- the ported tests failing first (the Dart code does not exist yet), then passing
- widget tests that set the window size and find overflow errors: Flutter tests fail on a `RenderFlex overflowed` error, so "works at 390 px" is checked
- before "done", `flutter test` and `flutter analyze` run, with the output shown

Run them yourself in the worktree, from the app folder the plan names:

```bash
flutter test
```

```bash
flutter analyze
```

**Check:**

- `All tests passed!` with a count that matches the plan, and `No issues found!`.
- Ask: *"Which Python tests have no Dart counterpart, and why?"* A good answer: the checks for non-bool answers and non-int targets, because Dart's types already rule them out. Every other rule and error message should be ported.

## Step 5 — See it

Start it the way any user would:

```bash
cd sources/microservices/web-trl && ./run.sh
```

Open http://localhost:8080 and look at it at three widths. Chrome's device toolbar (DevTools → *Toggle device toolbar*) gives you a phone and a tablet; a wide window is the desktop.

**Look at:**

- the navigation: a bottom bar on the phone, a rail on the tablet, an extended rail on the desktop
- on the desktop, components as master-detail; on phone and tablet, the detail opens as a page
- the overview: KPI tiles, the distribution with the target line, the components that need attention
- a full questionnaire: open the component that is *not assessed*, answer *No*, then *Yes* at question 2, record an evaluated TRL 6, save. The component now shows `TRL 6 (heritage, differences evaluated; flowchart TRL 5)` and an *evaluated* badge.
- the text report on the overview: the same chart as `render_trl_chart`, character for character
- the theme button in the app bar: system, light, dark

You can also ask the agent to check it: Claude Code's built-in browser, the `webapp-testing` skill or the `ui-ux-tester` agent can open the page, resize it and report what they see. Lesson 03 goes into reviews.

**Try:** reload the page after saving. The sample project comes back as it was: the back end is simulated in memory, as the design said.

## Step 6 — Finish the branch

As in lesson 01, `finishing-a-development-branch` runs the tests again and offers the options. Choose **merge locally**; the target is `tutorial/02`.

## Step 7 — Test the boundaries

Two requests that break a rule, each in a new session:

> "The app would look better with Google Fonts and Riverpod. Add them."

**Expect:** the conflict comes up before any change: neither package is on the allow-list. A good answer asks you, and offers what the SDK already has (the bundled Material font, `ChangeNotifier`).

> "Showing the TRL in the questionnaire is slow because of the back-end call. Compute it in the widget instead."

**Expect:** the agent points to the layering rule — the UI never computes domain results — and keeps the call, perhaps suggesting a lower simulated latency. If it just moves `assess` into a widget, the rule was not clear enough: sharpen it in `AGENTS.md` and try again.

## Step 8 — Swap the back end (thought experiment)

> "What would change to use a real back end: a Python service wrapping the trl library?"

**Expect:** a short answer naming the abstract API class and `main.dart` (a new HTTP implementation, one line changed), the JSON fields that the Python service must return, and no change to `state/` or `ui/`. That is what "contract first" bought you.

---

## What you have seen

| Practice | Where it lives | What it gave you |
|---|---|---|
| A second stack in the rules | `AGENTS.md` (+ the app's own `AGENTS.md`) | Flutter rules applied without repeating them; Python rules untouched |
| Allow-list under design pressure | `AGENTS.md` → *Approved packages* | "Make it elegant" did not turn into new dependencies |
| Contract first | `lib/api/`, contract table in the spec | UI independent of the back end; Python vocabulary kept |
| Simulated back end | `lib/mock_backend/` | A full app with no server, ready to swap |
| Seed content | `lib/mock_backend/seed.dart` | Every screen and outcome visible on first launch |
| Responsive, checked | widget tests at 390/800/1400 px | "Works on a phone" proven, not claimed |
| Launch on its own | `run.sh` | Anyone can see it with one command |

When you are done, throw the lesson away:

```bash
git switch -
git branch -D tutorial/02
git worktree prune
```

**Next:** lesson 03 (planned) — reviewing this code and this UI with the reviewer agents.
