import dataclasses
import unittest

from trl import HERITAGE_QUESTION_NUMBER, QUESTIONS, RETHINK, Question

TEXTS = [
    "Has an identical unit been successfully operated/launched in identical configuration/environment?",
    "Has an identical unit in a different configuration/system architecture been successfully operated in space or the target environment or launched?",
    "Has an identical unit been flight qualified but not yet operated in space or the target environment or launched?",
    "Has a prototype unit (or one similar enough to be considered a prototype) been successfully operated in space or the target environment or launched?",
    "Has a prototype unit (or one similar enough to be considered a prototype) been demonstrated in a relevant environment?",
    "Has a breadboard unit been demonstrated in a relevant environment?",
    "Has a breadboard unit been demonstrated in a laboratory environment?",
    "Has analytical and experimental proof-of-concept been demonstrated?",
    "Has concept or application been formulated?",
    "Have basic principles been observed and reported?",
]


class QuestionsTest(unittest.TestCase):
    def test_ten_questions_in_order(self):
        self.assertEqual([q.number for q in QUESTIONS], list(range(1, 11)))

    def test_trl_for_each_question(self):
        self.assertEqual(
            [q.trl_if_yes for q in QUESTIONS], [9, 5, 8, 7, 6, 5, 4, 3, 2, 1]
        )

    def test_texts_verbatim(self):
        self.assertEqual([q.text for q in QUESTIONS], TEXTS)

    def test_only_heritage_question_has_note(self):
        self.assertEqual(
            QUESTIONS[1].note, "TRL 5 initially, until differences are evaluated."
        )
        self.assertTrue(all(q.note is None for i, q in enumerate(QUESTIONS) if i != 1))
        self.assertEqual(HERITAGE_QUESTION_NUMBER, 2)

    def test_rethink_text(self):
        self.assertEqual(RETHINK, "Rethink position regarding this technology!")

    def test_questions_are_immutable(self):
        self.assertIsInstance(QUESTIONS, tuple)
        self.assertIsInstance(QUESTIONS[0], Question)
        with self.assertRaises(dataclasses.FrozenInstanceError):
            QUESTIONS[0].trl_if_yes = 1


if __name__ == "__main__":
    unittest.main()
