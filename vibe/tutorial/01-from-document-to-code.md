# 01 — From a document to tested code

**Time:** about 45 minutes · **Needs:** setup steps 0–2 (Superpowers included), `python3` · **Result:** a small Python library, designed, planned and built test-first through the Superpowers workflow, from knowledge the agent extracted itself, inside rules you wrote

You will ingest a short excerpt of the NASA Systems Engineering Handbook, focused on TRL, ask the wiki about Technology Readiness Levels (TRL), then have the agent build a tiny TRL calculator through the Superpowers workflow: design, plan, isolated branch, test-driven implementation, finish. The calculator is not the point: the point is watching where the agent takes its knowledge from, how Superpowers keeps you in charge of every decision, and whether the agent respects your constraints.

Prompts to type into the CLI are in quotes; shell commands are in code blocks. Exact wiki page names and wording will differ from run to run.

Everything this lesson creates is thrown away at the end, so start on a throwaway branch (see [the tutorial's README](README.md#run-each-lesson-on-a-throwaway-branch)):

```bash
git switch -c tutorial/01
```

---

## Step 1 — Give the agent some knowledge

Copy the sample source into the second brain:

```bash
mkdir -p docs/second-brain/raw/examples
cp vibe/tutorial/examples/nasa_systems_engineering_handbook_0_excerpt_TRL.pdf docs/second-brain/raw/examples/
```

Start the CLI from the repository root and ingest it:

> `/wiki-ingest docs/second-brain/raw/examples/nasa_systems_engineering_handbook_0_excerpt_TRL.pdf`

The excerpt has 15 pages (an overview of the handbook plus its TRL glossary entry and appendix), so this takes a few minutes at most. Then check the result:

> `/wiki-health`

**Expect:** a summary page in `docs/second-brain/wiki/sources/`, a handful of pages in `entities/` and `concepts/` (one of them on TRL), `index.md` and `log.md` updated, and a health report with no errors.

**Look at:** open `docs/second-brain/wiki/index.md` and one concept page. This is now the project's memory: any later session reads it instead of the PDF.

## Step 2 — Ask the wiki

> "query: what are the nine TRL levels, and what has to be demonstrated to reach TRL 6?"

**Expect:** an answer built from wiki pages, with the pages it used cited by name. The answer should mention a model or prototype demonstrated in a relevant environment for TRL 6.

**Try:** ask something the handbook does not cover, e.g. "query: what is the TRL of the James Webb telescope mirror?". A good answer says the wiki does not know, instead of inventing it.

## Step 3 — Set the rules

Open `AGENTS.md` and replace the *Not defined yet* lines of four sections with these rules:

```markdown
## Commands

- Run the tests: `python3 -m unittest discover -s sources/libraries -t sources/libraries`

## Stack

Python 3.9+ (the version macOS ships), standard library only.

## Conventions

- Library code lives in `sources/libraries/<name>/`, one package per library, with its tests in `sources/libraries/<name>/tests/`. Both folders have an `__init__.py`.
- Pure functions, type hints everywhere, no I/O in library code.
- Approved libraries: the Python standard library. Nothing else.

## Testing

- Unit tests with `unittest`, written before the code they test (red, then green).
- A change is done only when every test passes.
```

**Why:** this is the part that turns vibe coding into controlled coding. The agent reads `AGENTS.md` on every interaction, so these rules apply to everything that follows, without repeating them in each prompt.

Commit the wiki and the rules before going on:

```bash
git add -A && git commit -m "Ingest the NASA SE Handbook and set the project rules"
```

Superpowers builds on a separate branch, usually in a git worktree created from the last commit: anything left uncommitted here (the wiki, the new rules) would not be there.

## Step 4 — Describe what you want, not how to build it

Start a new session, so the agent loads the rules you just wrote, and describe the feature in plain words:

> "I'd like a small library that tells me the Technology Readiness Level of a component from a short yes/no questionnaire, and whether it meets a target TRL. Use what the wiki says about TRL."

Superpowers starts its `brainstorming` skill. It does not write code: it asks questions, one at a time, to find out what you actually want. It also tells you that you can skip the questions; don't, the conversation is the point of this step.

Answer with your decisions as they come up, for example:

- the questions go from TRL 9 down to TRL 2; the first yes gives the TRL, all no gives TRL 1
- an incomplete questionnaire gives no result rather than a guess
- the target defaults to TRL 6, the level NASA typically expects at the preliminary design review

**Expect:**

- a design document in `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`: intent, goals and non-goals, constraints, your decisions, and what is left to the builder
- a fresh subagent reviewing it before you see it, and at most one round of follow-up questions
- no code until you approve the document: that is a hard gate in the skill

**Check:** the TRL definitions must match the wiki, and the agent should say which wiki pages it used. The constraints must include the rules from `AGENTS.md` (standard library only, tests first) without you mentioning them. If something is wrong, say so: the document changes before anything is built.

## Step 5 — Review the plan

Approve the design. Superpowers moves on to `writing-plans` and saves an implementation plan to `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`.

**Expect:** a list of the files to create, then small tasks; each task has checkbox steps — write the failing test, run it and see it fail, implement, run it and see it pass, commit. File locations and the test command should come from your `AGENTS.md` (`sources/libraries/trl/`, `__init__.py` in both folders, `python3 -m unittest …`).

The agent then asks you to review the plan and choose how to run it:

- **Subagent-driven** — a fresh subagent implements each task and a fresh reviewer checks it before the next one
- **Native** — the agent implements every task itself, with one review of the whole branch at the end

Both work for a plan this size. Pick *Subagent-driven* to watch the per-task reviews, *Native* to go faster.

## Step 6 — Build test-first on an isolated branch

Before touching code, the `using-git-worktrees` skill asks whether to work in an isolated worktree. Say yes: the work happens on its own branch and your checkout stays untouched until you decide.

Then let it run. Answer when it asks, and interrupt if it drifts from the plan.

**Expect:**

- for every task, a test written and run **before** the code, shown failing (red), then passing (green), then a commit
- the plan's checkboxes ticked as each step is done
- with *Subagent-driven*, a short review after each task, and the agent fixing what the reviewer found
- before saying it is done, the agent runs the tests and shows you the output (`verification-before-completion`): evidence, not claims

Run the tests yourself, from the worktree folder the agent reports:

```bash
python3 -m unittest discover -s sources/libraries -t sources/libraries
```

**Check:** the output must say `Ran N tests` with N greater than zero. `Ran 0 tests … OK` means `unittest` found nothing, usually because an `__init__.py` is missing: a green result that proves nothing, and a good thing to point out to the agent.

## Step 7 — Finish the branch

When all tasks are done, `finishing-a-development-branch` runs the whole test suite again and asks what to do with the branch: merge it back locally, push it and open a pull request, or keep it as it is for later. Discarding the work is never offered: it happens only if you ask for it explicitly.

For this lesson choose **merge locally**. The merge target is `tutorial/01`, the branch the worktree started from, not your project's branch. The agent merges, re-runs the tests on the merged result, and cleans up the worktree.

**Look at:** `git log --oneline` shows one small commit per task, and `docs/superpowers/` holds the design and the plan. Both are committed: they are the record of why the code is the way it is (see *Commit AI-tooling folders to Git* in `AGENTS.md`).

## Step 8 — Test the boundaries

Now ask for something that breaks a rule:

> "Add a bar chart of the TRL distribution of a list of components, using matplotlib."

**Expect:** Superpowers starts brainstorming again, and the conflict should come up there, before any code: matplotlib is not an approved library, so the agent should point it out and ask, or propose a standard-library alternative (for example a text bar chart). If the design document lists matplotlib without comment, the rule was not clear enough: make the *Conventions* wording stronger and try again in a new session.

This is the habit to keep: when the agent breaks a rule, fix the rule, not only the code.

---

## What you have seen

| Practice | Where it lives | What it gave you |
|---|---|---|
| Project knowledge | `docs/second-brain/` | Answers grounded in a source, with citations |
| Technical constraints | `AGENTS.md` | Stack, layout, approved libraries, test policy applied without repeating them |
| Design before code | `docs/superpowers/specs/` | Your decisions written down and approved before anything was built |
| Plan as a checklist | `docs/superpowers/plans/` | Small, verifiable tasks, and visible progress |
| Isolated branch | git worktree | Work you could merge, open as a PR, or throw away |
| Tests as definition of done | `sources/libraries/trl/tests/` | Proof, shown before every "done" |

When you are done, throw the lesson away and go back to a clean project:

```bash
git switch -
git branch -D tutorial/01
git worktree prune
```

To run the lesson again, start a new `tutorial/01` branch.

**Next:** lesson 02 (planned) — reviewing this code with the reviewer agents.
