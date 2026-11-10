import unittest

from trl import assess, render_trl_chart, trl_distribution


def at_question(n):
    """Assessment whose first yes is question n (1-10)."""
    return assess([False] * (n - 1) + [True])


TRL9 = at_question(1)
TRL7 = at_question(4)
TRL6 = at_question(5)
TRL4 = at_question(7)
HERITAGE = assess([False, True])
HERITAGE_EVALUATED_6 = assess([False, True], evaluated_heritage_trl=6)
RETHINK_RESULT = assess([False] * 10)


class TrlDistributionTest(unittest.TestCase):
    def test_all_levels_and_rethink_present_in_chart_order(self):
        counts = trl_distribution([])
        self.assertEqual(list(counts), [9, 8, 7, 6, 5, 4, 3, 2, 1, None])
        self.assertEqual(set(counts.values()), {0})

    def test_counts_each_level(self):
        counts = trl_distribution([TRL6, TRL9, TRL6, TRL4, RETHINK_RESULT])
        self.assertEqual(counts[9], 1)
        self.assertEqual(counts[6], 2)
        self.assertEqual(counts[4], 1)
        self.assertEqual(counts[None], 1)
        self.assertEqual(sum(counts.values()), 5)

    def test_heritage_counts_reported_trl(self):
        counts = trl_distribution([HERITAGE, HERITAGE_EVALUATED_6])
        self.assertEqual(counts[5], 1)
        self.assertEqual(counts[6], 1)


class RenderTrlChartTest(unittest.TestCase):
    def test_approved_layout(self):
        chart = render_trl_chart([TRL9, TRL7] + [TRL6] * 10)
        self.assertEqual(
            chart,
            "\n".join(
                [
                    "TRL distribution — 12 components, target TRL 6",
                    "TRL 9    |  1 █",
                    "TRL 8    |  0",
                    "TRL 7    |  1 █",
                    "TRL 6    | 10 ██████████",
                    "---------- target TRL 6 ----------",
                    "TRL 5    |  0",
                    "TRL 4    |  0",
                    "TRL 3    |  0",
                    "TRL 2    |  0",
                    "TRL 1    |  0",
                    "Rethink  |  0",
                    "Below target: 0 of 12",
                ]
            ),
        )

    def test_below_target_counts_rethink(self):
        chart = render_trl_chart([TRL4, RETHINK_RESULT, TRL6])
        self.assertTrue(chart.endswith("Below target: 2 of 3"))
        self.assertIn("Rethink  | 1 █", chart.splitlines())

    def test_target_line_follows_target_row(self):
        lines = render_trl_chart([TRL7], target_trl=8).splitlines()
        target_line = lines.index("---------- target TRL 8 ----------")
        self.assertEqual(lines[target_line - 1], "TRL 8    | 0")
        self.assertEqual(lines[0], "TRL distribution — 1 component, target TRL 8")
        self.assertEqual(lines[-1], "Below target: 1 of 1")

    def test_target_one_puts_line_below_trl_1(self):
        lines = render_trl_chart([], target_trl=1).splitlines()
        self.assertEqual(lines[lines.index("TRL 1    | 0") + 1], "---------- target TRL 1 ----------")

    def test_empty_list(self):
        lines = render_trl_chart([]).splitlines()
        self.assertEqual(lines[0], "TRL distribution — 0 components, target TRL 6")
        self.assertEqual(lines[-1], "Below target: 0 of 0")
        self.assertEqual(len(lines), 13)

    def test_bars_scaled_to_forty_characters(self):
        lines = render_trl_chart([TRL6] * 80 + [TRL9]).splitlines()
        self.assertEqual(lines[1], "TRL 9    |  1 █")
        self.assertEqual(lines[4], "TRL 6    | 80 " + "█" * 40)

    def test_scaled_bar_keeps_at_least_one_character(self):
        lines = render_trl_chart([TRL6] * 200 + [TRL9]).splitlines()
        self.assertEqual(lines[1], "TRL 9    |   1 █")

    def test_forty_or_fewer_are_not_scaled(self):
        lines = render_trl_chart([TRL6] * 40).splitlines()
        self.assertEqual(lines[4], "TRL 6    | 40 " + "█" * 40)

    def test_rejects_bad_target(self):
        for target in (0, 10, True, 6.0, "6"):
            with self.subTest(target=target):
                with self.assertRaises(ValueError):
                    render_trl_chart([TRL6], target_trl=target)


if __name__ == "__main__":
    unittest.main()
