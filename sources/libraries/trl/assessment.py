"""Assess a Technology Readiness Level from the answers to the TMA flowchart."""

from dataclasses import dataclass
from typing import Optional, Sequence

from trl.questions import HERITAGE_QUESTION_NUMBER, QUESTIONS, RETHINK, Question

DEFAULT_TARGET_TRL: int = 6


@dataclass(frozen=True)
class Assessment:
    """Result of `assess`.

    Fields: trl, flowchart_trl, heritage_evaluated, target_trl, meets_target,
    gap, deciding_question, outcome.

    `trl` is the reported TRL; it differs from `flowchart_trl` when an
    evaluated heritage TRL was applied (`heritage_evaluated` is True). A
    question-2 ("heritage") result of TRL 5 is provisional until the
    differences are evaluated. For the "rethink" outcome, `trl`,
    `flowchart_trl` and `deciding_question` are None and `gap` equals
    `target_trl` (measured from 0).
    """

    trl: Optional[int]
    flowchart_trl: Optional[int]
    heritage_evaluated: bool
    target_trl: int
    meets_target: bool
    gap: int
    deciding_question: Optional[Question]
    outcome: str


def assess(
    answers: Sequence[bool],
    target_trl: int = DEFAULT_TARGET_TRL,
    evaluated_heritage_trl: Optional[int] = None,
) -> Assessment:
    """Walk the flowchart: answers end at the first True, or are ten False.

    `target_trl` (1-9) is the level to meet; `evaluated_heritage_trl` (5, 6 or 7)
    is allowed only when question 2 is the first yes.
    """
    given = tuple(answers)
    if type(target_trl) is not int or not 1 <= target_trl <= 9:
        raise ValueError("target_trl must be an int from 1 to 9")
    if any(type(a) is not bool for a in given):
        raise ValueError("every answer must be a bool")
    if len(given) > len(QUESTIONS):
        raise ValueError("at most ten answers are allowed")
    if True in given:
        if given.index(True) != len(given) - 1:
            raise ValueError("no answers are allowed after the first True")
    elif len(given) != len(QUESTIONS):
        raise ValueError("without a True, all ten questions must be answered")
    if evaluated_heritage_trl is not None:
        if type(evaluated_heritage_trl) is not int or evaluated_heritage_trl not in (5, 6, 7):
            raise ValueError("evaluated_heritage_trl must be an int: 5, 6 or 7")
        if True not in given or len(given) != HERITAGE_QUESTION_NUMBER:
            raise ValueError("evaluated_heritage_trl applies only when question 2 is the first yes")

    if True not in given:
        return Assessment(
            trl=None,
            flowchart_trl=None,
            heritage_evaluated=False,
            target_trl=target_trl,
            meets_target=False,
            gap=target_trl,
            deciding_question=None,
            outcome=RETHINK,
        )

    question = QUESTIONS[len(given) - 1]
    trl = question.trl_if_yes
    flowchart_trl = trl
    heritage_evaluated = False
    if evaluated_heritage_trl is not None:
        trl = evaluated_heritage_trl
        heritage_evaluated = True
        outcome = f"TRL {trl} (heritage, differences evaluated; flowchart TRL {flowchart_trl})"
    elif question.number == HERITAGE_QUESTION_NUMBER:
        outcome = f"TRL {trl} (initially, until differences are evaluated)"
    else:
        outcome = f"TRL {trl}"
    return Assessment(
        trl=trl,
        flowchart_trl=flowchart_trl,
        heritage_evaluated=heritage_evaluated,
        target_trl=target_trl,
        meets_target=trl >= target_trl,
        gap=max(0, target_trl - trl),
        deciding_question=question,
        outcome=outcome,
    )
