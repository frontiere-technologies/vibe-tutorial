"""Assess a Technology Readiness Level from the answers to the TMA flowchart."""

from dataclasses import dataclass
from typing import Iterable, Optional

from trl.questions import HERITAGE_QUESTION_NUMBER, QUESTIONS, RETHINK, Question

DEFAULT_TARGET_TRL: int = 6


@dataclass(frozen=True)
class Assessment:
    trl: Optional[int]
    flowchart_trl: Optional[int]
    heritage_evaluated: bool
    target_trl: int
    meets_target: bool
    gap: int
    deciding_question: Optional[Question]
    outcome: str


def assess(
    answers: Iterable[bool],
    target_trl: int = DEFAULT_TARGET_TRL,
    evaluated_heritage_trl: Optional[int] = None,
) -> Assessment:
    """Walk the flowchart: answers end at the first True, or are ten False."""
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
        raise NotImplementedError("evaluated_heritage_trl is not supported yet")

    if True not in given:
        return Assessment(None, None, False, target_trl, False, target_trl, None, RETHINK)

    question = QUESTIONS[len(given) - 1]
    trl = question.trl_if_yes
    if question.number == HERITAGE_QUESTION_NUMBER:
        outcome = f"TRL {trl} (initially, until differences are evaluated)"
    else:
        outcome = f"TRL {trl}"
    return Assessment(
        trl=trl,
        flowchart_trl=trl,
        heritage_evaluated=False,
        target_trl=target_trl,
        meets_target=trl >= target_trl,
        gap=max(0, target_trl - trl),
        deciding_question=question,
        outcome=outcome,
    )
