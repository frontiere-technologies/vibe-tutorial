# TRL calculator — design

Date: 2026-11-10 · Status: approved

## Intent

A systems engineer on a small satellite project is preparing the end-of-Phase-B review (KDP C). For each component of the product breakdown — e.g. the new attitude-control reaction wheel — they sit with the subsystem lead and answer the NASA TMA questions **in the order of the flowchart**, yes or no, stopping at the first "yes". The library turns those answers into:

1. the component's Technology Readiness Level (TRL);
2. whether it meets the required TRL (usually 6 at KDP C, configurable);
3. if not, how many levels short it is;
4. the question that got the "yes" — the line that goes into the review report.

Why it matters: the number goes in front of a review board. A wrong TRL — above all for a reused component — is the failure this library exists to prevent.

Knowledge comes from the project wiki: `docs/second-brain/wiki/concepts/TechnologyMaturityAssessment.md` (the question sequence, from Figure G.4-2 of the NASA Systems Engineering Handbook, SP-2016-6105 Rev2), `TechnologyReadinessLevel.md`, `HeritageSystems.md`, `KeyDecisionPoint.md`.

## Goals

- Encode the ten TMA questions in flowchart order, each with the TRL a "yes" gives:

  | # | Question (text kept verbatim from the handbook) | Yes → |
  |---|---|---|
  | 1 | Has an identical unit been successfully operated/launched in identical configuration/environment? | 9 |
  | 2 | Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched? | 5 |
  | 3 | Has an identical unit been flight qualified but not yet operated in space or the target environment or launched? | 8 |
  | 4 | Has a prototype unit (or one similar enough to be considered a prototype) been successfully operated in space or the target environment or launched? | 7 |
  | 5 | Has a prototype unit (or one similar enough to be considered a prototype) been demonstrated in a relevant environment? | 6 |
  | 6 | Has a breadboard unit been demonstrated in a relevant environment? | 5 |
  | 7 | Has a breadboard unit been demonstrated in a laboratory environment? | 4 |
  | 8 | Has analytical and experimental proof-of-concept been demonstrated? | 3 |
  | 9 | Has concept or application been formulated? | 2 |
  | 10 | Have basic principles been observed and reported? | 1 |

  If every answer is "no", the outcome is the flowchart's own: **"Rethink position regarding this technology!"** — no TRL.
- Given the answers and a target TRL (default 6), return TRL, target, meets-target, gap, and the deciding question.
- **Heritage case:** an identical unit flown in a different configuration (question 2 = yes) gives **TRL 5**, never 9 or 8. Question 2 comes before question 3 on purpose; the order is the handbook's, not descending TRL. The result for question 2 carries the handbook's caveat: TRL 5 *initially, until differences are evaluated*.
- **Evaluated heritage TRL:** once the team has evaluated the differences, the caller may supply the evaluated TRL for a heritage component — **6 or 7** (or 5 if the evaluation confirms it), as the handbook allows, never 8 or 9. It is accepted only when question 2 was the "yes". The result then reports the evaluated TRL, keeps the flowchart's TRL 5 alongside it, and flags it as evaluated, so a review board can tell the two apart. Target and gap are computed on the reported (evaluated) TRL.
- Usable one component at a time from a Python script.

## Non-goals (for now)

- System-level TRL (lowest TRL across components, integration effects) — wanted later; the design should not make it hard to add.
- AD² (advancement degree of difficulty), technology development plans, cost/schedule.
- Software-specific TRL definitions (NPR 7123.1 — not in the wiki).
- Any CLI, UI, file or report output: the caller formats the report line.
- Translating the questions: the text stays in English, verbatim, since it is copied into the review report.

## Anti-goals (failures even if it "works")

- A reused-in-a-different-configuration component reported as TRL 9 or 8 — by the flowchart or through an evaluated TRL.
- An evaluated TRL that is indistinguishable in the result from a plain flowchart TRL, or accepted for a component that did not answer "yes" to question 2.
- A TRL invented when all ten answers are "no".
- Questions asked or evaluated in any order other than the flowchart's.
- Any dependency outside the Python standard library.

## Constraints (from `AGENTS.md`)

- Python 3.9+, standard library only (so `Optional[int]`, not `int | None`, unless `from __future__ import annotations` is used).
- Package in `sources/libraries/<name>/`, tests in `sources/libraries/<name>/tests/`, both with `__init__.py`.
- Pure functions, type hints everywhere, no I/O in library code.
- `unittest`, tests written before the code (red, then green). Done only when `python3 -m unittest discover -s sources/libraries -t sources/libraries` passes.

## Decided with the user

- Answers are yes/no, in flowchart order, stopping at the first yes.
- Default target TRL is 6 (KDP C), changeable per call.
- Gap is reported in levels when the target is not met.
- The deciding question is part of the result.
- Heritage → TRL 5.
- After the differences are evaluated, a heritage component may be reported at TRL 6 or 7 (answer to the builder check).
- One component at a time; system roll-up later.

## My calls (builder may refine)

- **Package name:** `trl` (`sources/libraries/trl/`).
- **Shape:** an ordered, immutable sequence of question records (number, text, TRL on yes, optional note — only question 2 has one), and one pure function, e.g. `assess(answers, target_trl=6, evaluated_heritage_trl=None) -> Assessment`. `Assessment` is a frozen dataclass with: `trl` (`Optional[int]`, the reported TRL; `None` for "rethink"), `flowchart_trl` (`Optional[int]`, what the flowchart alone gives), `heritage_evaluated` (bool, `True` only when an evaluated heritage TRL was applied), `target_trl`, `meets_target` (bool), `gap` (int), `deciding_question` (the question record, or `None`; stays question 2 for an evaluated heritage TRL), and the outcome text.
- **Evaluated heritage TRL input:** `evaluated_heritage_trl` must be `None` or an integer 5, 6 or 7; any other value, or a value given when the deciding question is not question 2, raises `ValueError`.
- **Answers input:** a sequence of booleans in flowchart order, ending at the first `True`, or ten `False`s. Invalid input raises `ValueError`: answers after the first `True`, fewer answers than needed with no `True`, more than ten answers, non-bool values.
- **Target validation:** integer 1–9, otherwise `ValueError`.
- **Gap:** `max(0, target_trl - trl)`. For "rethink" (no TRL), gap is `target_trl` (as if TRL 0) and `meets_target` is `False`.
- **Tests must cover at least:** each of the ten questions giving its TRL; the heritage case explicitly (question 2 → 5, not 9 or 8); evaluated heritage TRL 6 and 7 accepted, flagged, with `flowchart_trl` still 5 and target/gap on the evaluated value; evaluated TRL 8, 9, 4 rejected; evaluated TRL rejected when question 2 was not the "yes"; all-no → rethink with no TRL; meets/doesn't meet a target, with the right gap; default target 6; each invalid-input case.

## Left to the builder

Internal naming, module split, docstring style, and how the questions are stored, as long as the constraints and the table above hold.
