"""The ten TMA questions of the NASA SE Handbook flowchart, in flowchart order."""

from dataclasses import dataclass
from typing import Optional, Tuple


@dataclass(frozen=True)
class Question:
    number: int
    text: str
    trl_if_yes: int
    note: Optional[str] = None


HERITAGE_QUESTION_NUMBER: int = 2

RETHINK: str = "Rethink position regarding this technology!"

QUESTIONS: Tuple[Question, ...] = (
    Question(1, "Has an identical unit been successfully operated/launched in identical configuration/environment?", 9),
    Question(
        2,
        "Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched?",
        5,
        "TRL 5 initially, until differences are evaluated.",
    ),
    Question(3, "Has an identical unit been flight qualified but not yet operated in space or the target environment or launched?", 8),
    Question(4, "Has a prototype unit (or one similar enough to be considered a prototype) been successfully operated in space or the target environment or launched?", 7),
    Question(5, "Has a prototype unit (or one similar enough to be considered a prototype) been demonstrated in a relevant environment?", 6),
    Question(6, "Has a breadboard unit been demonstrated in a relevant environment?", 5),
    Question(7, "Has a breadboard unit been demonstrated in a laboratory environment?", 4),
    Question(8, "Has analytical and experimental proof-of-concept been demonstrated?", 3),
    Question(9, "Has concept or application been formulated?", 2),
    Question(10, "Have basic principles been observed and reported?", 1),
)
