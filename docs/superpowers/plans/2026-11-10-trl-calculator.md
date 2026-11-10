# TRL Calculator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A pure-Python library that turns the NASA TMA yes/no answers for one component into its TRL, checks it against a target TRL, and handles the heritage (reused component) case, including an evaluated TRL 5–7.

**Architecture:** Package `trl` in `sources/libraries/trl/`. `questions.py` holds the ten question records in flowchart order (data only); `assessment.py` holds the `Assessment` result and the pure function `assess()`. `__init__.py` re-exports the public names.

**Tech Stack:** Python 3.9+, standard library only (`dataclasses`, `typing`), `unittest`.

**Spec:** `docs/superpowers/specs/2026-11-10-trl-calculator-design.md`

## Global Constraints

- Python 3.9+ (the version macOS ships), standard library only — no `int | None` syntax at runtime; use `typing.Optional`.
- Library code in `sources/libraries/trl/`, tests in `sources/libraries/trl/tests/`, both folders with an `__init__.py`.
- Pure functions, type hints everywhere, no I/O in library code.
- Approved libraries: the Python standard library. Nothing else.
- Unit tests with `unittest`, written before the code they test (red, then green).
- Done only when `python3 -m unittest discover -s sources/libraries -t sources/libraries` passes (run from the repository root).
- Question texts verbatim from the spec's table (English, handbook wording). Rethink text verbatim: `Rethink position regarding this technology!`
- A heritage component (question 2 = yes) is never reported as TRL 8 or 9.

## Review Focus

1. Truthy non-bool answers (`1`, `0`, `"yes"`, `None`) → `ValueError`, never silently read as yes/no. Test: Task 2, `test_rejects_non_bool_answers`.
2. `target_trl` given as `True`, `6.0` or `"6"` → `ValueError` (`bool` is a subclass of `int`). Test: Task 2, `test_rejects_bad_target`.
3. Answers passed as a tuple instead of a list → same result. Test: Task 2, `test_accepts_tuple_answers`.
4. Evaluated heritage TRL equal to 5 → accepted, flagged as evaluated, still short of target 6 by 1. Test: Task 3, `test_evaluated_five_is_flagged_and_short`.
5. Caller tries to mutate the question list or a result → impossible (tuple, frozen dataclasses). Tests: Task 1, `test_questions_are_immutable`; Task 2, `test_assessment_is_frozen`.

---

### Task 1: Question records

**Files:**
- Create: `sources/libraries/trl/__init__.py`, `sources/libraries/trl/questions.py`
- Create: `sources/libraries/trl/tests/__init__.py` (empty)
- Test: `sources/libraries/trl/tests/test_questions.py`

**Interfaces:**
- Produces: `Question` — frozen dataclass with `number: int`, `text: str`, `trl_if_yes: int`, `note: Optional[str] = None`. `QUESTIONS: Tuple[Question, ...]` in flowchart order. `HERITAGE_QUESTION_NUMBER: int = 2`. `RETHINK: str = "Rethink position regarding this technology!"`. All re-exported from `trl`.

- [ ] **Step 1: Write the failing tests** in `test_questions.py` (`import unittest`, `from trl import QUESTIONS, Question, RETHINK, HERITAGE_QUESTION_NUMBER`):
  - `test_ten_questions_in_order`: `[q.number for q in QUESTIONS] == list(range(1, 11))`.
  - `test_trl_for_each_question`: `[q.trl_if_yes for q in QUESTIONS] == [9, 5, 8, 7, 6, 5, 4, 3, 2, 1]`.
  - `test_texts_verbatim`: compares each `q.text` to the ten strings of the spec's table, copied exactly (e.g. question 2: `"Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched?"`).
  - `test_only_heritage_question_has_note`: `QUESTIONS[1].note == "TRL 5 initially, until differences are evaluated."`, every other note is `None`, and `HERITAGE_QUESTION_NUMBER == 2`.
  - `test_rethink_text`: `RETHINK == "Rethink position regarding this technology!"`.
  - `test_questions_are_immutable`: `isinstance(QUESTIONS, tuple)`; assigning `QUESTIONS[0].trl_if_yes = 1` raises `dataclasses.FrozenInstanceError`.

- [ ] **Step 2: Run to verify it fails**
  Run: `python3 -m unittest discover -s sources/libraries -t sources/libraries -p 'test_questions.py' -v`
  Expected: ERROR, `ModuleNotFoundError`/`ImportError` for `trl`.

- [ ] **Step 3: Implement** `Question`, `QUESTIONS`, `HERITAGE_QUESTION_NUMBER`, `RETHINK` in `questions.py` with the spec's table texts; re-export them in `__init__.py` with `__all__`.

- [ ] **Step 4: Run to verify it passes** (same command). Expected: 6 tests OK.

- [ ] **Step 5: Commit**
```bash
git add sources/libraries/trl
git commit -m "feat(trl): add TMA question records"
```

### Task 2: `assess()` on the flowchart

**Files:**
- Create: `sources/libraries/trl/assessment.py`
- Modify: `sources/libraries/trl/__init__.py` (re-export `Assessment`, `assess`, `DEFAULT_TARGET_TRL`)
- Test: `sources/libraries/trl/tests/test_assess.py`

**Interfaces:**
- Consumes: `Question`, `QUESTIONS`, `RETHINK`, `HERITAGE_QUESTION_NUMBER` from Task 1.
- Produces: `DEFAULT_TARGET_TRL: int = 6`. `Assessment` — frozen dataclass with `trl: Optional[int]`, `flowchart_trl: Optional[int]`, `heritage_evaluated: bool`, `target_trl: int`, `meets_target: bool`, `gap: int`, `deciding_question: Optional[Question]`, `outcome: str`. `assess(answers: Iterable[bool], target_trl: int = DEFAULT_TARGET_TRL, evaluated_heritage_trl: Optional[int] = None) -> Assessment` — in this task `evaluated_heritage_trl` must be accepted as a parameter; any non-`None` value may raise `NotImplementedError` until Task 3.

Rules this task pins (from the spec):
- `answers` is read once into a tuple. Valid: ends at the first `True`, or exactly ten `False`. `ValueError` for: any element whose `type` is not `bool`; more than ten answers; answers after the first `True`; no `True` and fewer than ten answers (including empty).
- `target_trl`: `type(target_trl) is int` and `1 <= target_trl <= 9`, else `ValueError`.
- First `True` at index `i` → `deciding_question = QUESTIONS[i]`, `trl = flowchart_trl = QUESTIONS[i].trl_if_yes`, `heritage_evaluated = False`.
- Ten `False` → `trl = flowchart_trl = None`, `deciding_question = None`, `outcome = RETHINK`, `meets_target = False`, `gap = target_trl`.
- Otherwise `meets_target = trl >= target_trl`, `gap = max(0, target_trl - trl)`.
- `outcome`: `f"TRL {trl}"`; for question 2 (not evaluated): `"TRL 5 (initially, until differences are evaluated)"`.

- [ ] **Step 1: Write the failing tests** in `test_assess.py`. Helper: `def yes_at(n): return [False] * (n - 1) + [True]` (n = question number).
  - `test_each_question_gives_its_trl`: for `n, expected` in `zip(range(1, 11), [9, 5, 8, 7, 6, 5, 4, 3, 2, 1])`: `assess(yes_at(n)).trl == expected`, `.flowchart_trl == expected`, `.deciding_question.number == n`, `.heritage_evaluated is False`.
  - `test_heritage_is_five_not_nine_or_eight`: `r = assess([False, True])`; `r.trl == 5`; `r.deciding_question.number == 2`; `r.outcome == "TRL 5 (initially, until differences are evaluated)"`; `r.meets_target is False`; `r.gap == 1`.
  - `test_all_no_rethinks`: `r = assess([False] * 10)`; `r.trl is None`, `r.flowchart_trl is None`, `r.deciding_question is None`, `r.outcome == "Rethink position regarding this technology!"`, `r.meets_target is False`, `r.gap == 6`.
  - `test_default_target_is_six`: `assess(yes_at(5)).target_trl == 6` and `.meets_target is True`, `.gap == 0`, `.outcome == "TRL 6"`.
  - `test_below_target_gap`: `assess(yes_at(7))` (TRL 4) → `meets_target is False`, `gap == 2`; `assess(yes_at(7), target_trl=4)` → `meets_target is True`, `gap == 0`; `assess(yes_at(1), target_trl=9)` → `meets_target is True`.
  - `test_rejects_bad_answer_sequences`: `ValueError` for `[]`, `[False] * 3`, `[False] * 11`, `[True, False]`, `[False, True, True]`.
  - `test_rejects_non_bool_answers`: `ValueError` for `[1]`, `[0] * 10`, `["yes"]`, `[False, None]`.
  - `test_rejects_bad_target`: `ValueError` for `target_trl` in `0, 10, True, 6.0, "6"`.
  - `test_accepts_tuple_answers`: `assess((False, False, False, False, True)) == assess(yes_at(5))`.
  - `test_assessment_is_frozen`: assigning `.trl = 9` on a result raises `dataclasses.FrozenInstanceError`.

- [ ] **Step 2: Run to verify it fails**
  Run: `python3 -m unittest discover -s sources/libraries -t sources/libraries -p 'test_assess.py' -v`
  Expected: ERROR, `ImportError` for `assess`.

- [ ] **Step 3: Implement** `DEFAULT_TARGET_TRL`, `Assessment` and `assess(...)` in `assessment.py` per the rules above; re-export in `__init__.py`.

- [ ] **Step 4: Run the whole suite**
  Run: `python3 -m unittest discover -s sources/libraries -t sources/libraries -v`
  Expected: all tests OK (Task 1 + Task 2).

- [ ] **Step 5: Commit**
```bash
git add sources/libraries/trl
git commit -m "feat(trl): assess TRL from TMA answers against a target"
```

### Task 3: Evaluated heritage TRL

**Files:**
- Modify: `sources/libraries/trl/assessment.py` (`assess`)
- Test: `sources/libraries/trl/tests/test_assess.py` (new test class `EvaluatedHeritageTest`)

**Interfaces:**
- Consumes: `assess`, `Assessment`, `HERITAGE_QUESTION_NUMBER` from Tasks 1–2.
- Produces: no new names; `assess(..., evaluated_heritage_trl=...)` becomes functional.

Rules this task pins:
- `evaluated_heritage_trl` is `None` or an `int` (by `type`, not `bool`) in `{5, 6, 7}`; otherwise `ValueError`.
- Given a non-`None` value when the deciding question is not question 2 (any other question, or all-no) → `ValueError`.
- When applied: `trl = evaluated_heritage_trl`, `flowchart_trl = 5`, `heritage_evaluated = True`, `deciding_question` stays question 2, target and gap computed on `trl`, `outcome = f"TRL {trl} (heritage, differences evaluated; flowchart TRL 5)"`.
- Validation order: answers, then target, then evaluated TRL.

- [ ] **Step 1: Write the failing tests** in `EvaluatedHeritageTest`:
  - `test_evaluated_six_meets_kdp_c`: `r = assess([False, True], evaluated_heritage_trl=6)`; `r.trl == 6`, `r.flowchart_trl == 5`, `r.heritage_evaluated is True`, `r.deciding_question.number == 2`, `r.meets_target is True`, `r.gap == 0`, `r.outcome == "TRL 6 (heritage, differences evaluated; flowchart TRL 5)"`.
  - `test_evaluated_seven_against_target_eight`: `assess([False, True], target_trl=8, evaluated_heritage_trl=7)` → `trl == 7`, `meets_target is False`, `gap == 1`.
  - `test_evaluated_five_is_flagged_and_short`: `assess([False, True], evaluated_heritage_trl=5)` → `trl == 5`, `heritage_evaluated is True`, `meets_target is False`, `gap == 1`.
  - `test_rejects_out_of_range_evaluated_trl`: `ValueError` for `evaluated_heritage_trl` in `4, 8, 9, True, 6.0`.
  - `test_rejects_evaluated_trl_without_heritage_yes`: `ValueError` for `assess([True], evaluated_heritage_trl=6)`, `assess([False, False, False, False, True], evaluated_heritage_trl=6)`, `assess([False] * 10, evaluated_heritage_trl=6)`.
  - `test_unevaluated_heritage_unchanged`: `assess([False, True], evaluated_heritage_trl=None).heritage_evaluated is False` and `.trl == 5`.

- [ ] **Step 2: Run to verify it fails**
  Run: `python3 -m unittest discover -s sources/libraries -t sources/libraries -p 'test_assess.py' -v`
  Expected: the new tests FAIL/ERROR (`NotImplementedError` or wrong values); Task 2 tests still pass.

- [ ] **Step 3: Implement** the evaluated-heritage branch in `assess` per the rules above.

- [ ] **Step 4: Run the whole suite**
  Run: `python3 -m unittest discover -s sources/libraries -t sources/libraries -v`
  Expected: all tests OK.

- [ ] **Step 5: Commit**
```bash
git add sources/libraries/trl
git commit -m "feat(trl): accept an evaluated TRL 5-7 for heritage components"
```
