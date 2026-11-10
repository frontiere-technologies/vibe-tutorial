# Contract of the `trl` Python library (result of lesson 01)

Lesson 02 builds a web app whose back-end calls follow the contracts of the small Python library built in lesson 01 (`sources/libraries/trl/`). Lessons run on throwaway branches, so that library may not exist any more when you start lesson 02: this file describes it, so lesson 02 can start from scratch. If you still have the library, the code wins over this file.

Knowledge source: NASA Systems Engineering Handbook, NASA/SP-2016-6105 Rev2, Appendix G (Figure G.4-2, the TMA flowchart).

## Questions — `trl.questions`

```python
@dataclass(frozen=True)
class Question:
    number: int          # 1..10, flowchart order
    text: str            # verbatim from the handbook, English
    trl_if_yes: int      # TRL given by a "yes"
    note: Optional[str] = None   # only question 2 has one

HERITAGE_QUESTION_NUMBER: int = 2
RETHINK: str = "Rethink position regarding this technology!"
QUESTIONS: Tuple[Question, ...]   # the ten questions below, in this order
```

| # | Question | Yes → |
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

Question 2's note: `"TRL 5 initially, until differences are evaluated."`

## Assessment — `trl.assessment`

```python
DEFAULT_TARGET_TRL: int = 6   # expected at KDP C

@dataclass(frozen=True)
class Assessment:
    trl: Optional[int]               # reported TRL; None for "rethink"
    flowchart_trl: Optional[int]     # what the flowchart alone gives
    heritage_evaluated: bool         # True only when an evaluated heritage TRL was applied
    target_trl: int
    meets_target: bool               # trl >= target_trl (False for "rethink")
    gap: int                         # max(0, target_trl - trl); target_trl for "rethink"
    deciding_question: Optional[Question]   # the "yes"; None for "rethink"
    outcome: str

def assess(answers: Sequence[bool],
           target_trl: int = DEFAULT_TARGET_TRL,
           evaluated_heritage_trl: Optional[int] = None) -> Assessment
```

Rules:

- `answers` are in flowchart order and end at the first `True`, or are ten `False` (→ "rethink": no TRL).
- A `True` at question 2 (heritage: identical unit, different configuration) gives TRL 5, never 9 or 8.
- `evaluated_heritage_trl` (5, 6 or 7) is accepted only when question 2 is the first yes; the result reports it as `trl`, keeps `flowchart_trl = 5` and sets `heritage_evaluated = True`.
- `outcome` texts:
  - `"TRL n"`
  - `"TRL 5 (initially, until differences are evaluated)"` — question 2, not evaluated
  - `"TRL n (heritage, differences evaluated; flowchart TRL 5)"`
  - `"Rethink position regarding this technology!"`

Errors (`ValueError`, exact messages):

| Input | Message |
|---|---|
| target not an int 1–9 | `target_trl must be an int from 1 to 9` |
| an answer is not a bool | `every answer must be a bool` |
| more than ten answers | `at most ten answers are allowed` |
| answers after the first `True` | `no answers are allowed after the first True` |
| no `True` and fewer than ten answers | `without a True, all ten questions must be answered` |
| evaluated TRL not 5, 6 or 7 | `evaluated_heritage_trl must be an int: 5, 6 or 7` |
| evaluated TRL without question 2 as first yes | `evaluated_heritage_trl applies only when question 2 is the first yes` |

## Chart — `trl.chart`

```python
def trl_distribution(assessments: Sequence[Assessment]) -> Dict[Optional[int], int]
    # keys 9, 8, …, 1, then None ("rethink"), every key present; counts by reported TRL

def render_trl_chart(assessments: Sequence[Assessment], target_trl: int = DEFAULT_TARGET_TRL) -> str
```

`render_trl_chart` output (no trailing newline), e.g. for one TRL 9, one TRL 7 and ten TRL 6:

```
TRL distribution — 12 components, target TRL 6
TRL 9    |  1 █
TRL 8    |  0
TRL 7    |  1 █
TRL 6    | 10 ██████████
---------- target TRL 6 ----------
TRL 5    |  0
TRL 4    |  0
TRL 3    |  0
TRL 2    |  0
TRL 1    |  0
Rethink  |  0
Below target: 0 of 12
```

Labels are padded to 8 characters, counts right-aligned to the widest count, one `█` per component, scaled with Python's `round()` to at most 40 characters when the largest count is bigger (a non-zero count keeps at least one). The target line follows the target row; "rethink" counts as below target. Same `ValueError` as `assess` for a bad target.
