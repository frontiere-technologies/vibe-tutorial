"""Text bar chart of the TRL distribution of a list of assessed components."""

from typing import Dict, List, Optional, Sequence

from trl.assessment import DEFAULT_TARGET_TRL, Assessment

BAR_CHAR: str = "█"
MAX_BAR_WIDTH: int = 40
LABEL_WIDTH: int = 8


def trl_distribution(assessments: Sequence[Assessment]) -> Dict[Optional[int], int]:
    """Count components per reported TRL, from 9 down to 1, then None for "rethink".

    Every level is present, with 0 when no component is at it. A heritage
    component counts at its reported TRL (the evaluated one, if any).
    """
    counts: Dict[Optional[int], int] = {level: 0 for level in range(9, 0, -1)}
    counts[None] = 0
    for assessment in assessments:
        counts[assessment.trl] += 1
    return counts


def render_trl_chart(
    assessments: Sequence[Assessment],
    target_trl: int = DEFAULT_TARGET_TRL,
) -> str:
    """Return the TRL distribution as a text bar chart (no trailing newline).

    Counts are right-aligned before the bars so every bar starts in the same
    column. A line marks the target TRL; "rethink" outcomes count as below it.
    Bars are one character per component, scaled to MAX_BAR_WIDTH when the
    largest count is bigger; a non-zero count always shows at least one character.
    """
    if type(target_trl) is not int or not 1 <= target_trl <= 9:
        raise ValueError("target_trl must be an int from 1 to 9")

    counts = trl_distribution(assessments)
    total = sum(counts.values())
    largest = max(counts.values())
    count_width = len(str(largest))
    below = sum(n for level, n in counts.items() if level is None or level < target_trl)

    noun = "component" if total == 1 else "components"
    lines: List[str] = [f"TRL distribution — {total} {noun}, target TRL {target_trl}"]
    for level, n in counts.items():
        label = "Rethink" if level is None else f"TRL {level}"
        row = f"{label:<{LABEL_WIDTH}} | {n:>{count_width}}"
        bar = _bar_length(n, largest)
        if bar:
            row += " " + BAR_CHAR * bar
        lines.append(row)
        if level == target_trl:
            lines.append(f"---------- target TRL {target_trl} ----------")
    lines.append(f"Below target: {below} of {total}")
    return "\n".join(lines)


def _bar_length(count: int, largest: int) -> int:
    if count == 0:
        return 0
    if largest <= MAX_BAR_WIDTH:
        return count
    return max(1, round(count * MAX_BAR_WIDTH / largest))
