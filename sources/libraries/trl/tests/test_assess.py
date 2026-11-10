import dataclasses
import unittest

from trl import assess


def yes_at(n):
    return [False] * (n - 1) + [True]


class AssessTest(unittest.TestCase):
    def test_each_question_gives_its_trl(self):
        for n, expected in zip(range(1, 11), [9, 5, 8, 7, 6, 5, 4, 3, 2, 1]):
            with self.subTest(question=n):
                r = assess(yes_at(n))
                self.assertEqual(r.trl, expected)
                self.assertEqual(r.flowchart_trl, expected)
                self.assertEqual(r.deciding_question.number, n)
                self.assertIs(r.heritage_evaluated, False)

    def test_heritage_is_five_not_nine_or_eight(self):
        r = assess([False, True])
        self.assertEqual(r.trl, 5)
        self.assertEqual(r.deciding_question.number, 2)
        self.assertEqual(r.outcome, "TRL 5 (initially, until differences are evaluated)")
        self.assertIs(r.meets_target, False)
        self.assertEqual(r.gap, 1)

    def test_all_no_rethinks(self):
        r = assess([False] * 10)
        self.assertIsNone(r.trl)
        self.assertIsNone(r.flowchart_trl)
        self.assertIsNone(r.deciding_question)
        self.assertEqual(r.outcome, "Rethink position regarding this technology!")
        self.assertIs(r.meets_target, False)
        self.assertEqual(r.gap, 6)

    def test_default_target_is_six(self):
        r = assess(yes_at(5))
        self.assertEqual(r.target_trl, 6)
        self.assertIs(r.meets_target, True)
        self.assertEqual(r.gap, 0)
        self.assertEqual(r.outcome, "TRL 6")

    def test_below_target_gap(self):
        r = assess(yes_at(7))
        self.assertIs(r.meets_target, False)
        self.assertEqual(r.gap, 2)
        r = assess(yes_at(7), target_trl=4)
        self.assertIs(r.meets_target, True)
        self.assertEqual(r.gap, 0)
        self.assertIs(assess(yes_at(1), target_trl=9).meets_target, True)

    def test_rejects_bad_answer_sequences(self):
        for bad in ([], [False] * 3, [False] * 11, [True, False], [False, True, True]):
            with self.subTest(answers=bad):
                with self.assertRaises(ValueError):
                    assess(bad)

    def test_rejects_non_bool_answers(self):
        for bad in ([1], [0] * 10, ["yes"], [False, None]):
            with self.subTest(answers=bad):
                with self.assertRaises(ValueError):
                    assess(bad)

    def test_rejects_bad_target(self):
        for bad in (0, 10, True, 6.0, "6"):
            with self.subTest(target=bad):
                with self.assertRaises(ValueError):
                    assess(yes_at(5), target_trl=bad)

    def test_accepts_tuple_answers(self):
        self.assertEqual(assess((False, False, False, False, True)), assess(yes_at(5)))

    def test_assessment_is_frozen(self):
        r = assess(yes_at(5))
        with self.assertRaises(dataclasses.FrozenInstanceError):
            r.trl = 9


if __name__ == "__main__":
    unittest.main()
