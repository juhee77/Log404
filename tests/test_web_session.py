import unittest

from game.log404_web import GameSession


class GameSessionTest(unittest.TestCase):
    def test_snapshot_exposes_detective_ui_state(self):
        session = GameSession()

        initial = session.snapshot()
        self.assertEqual(len(initial["suspects"]), 3)
        self.assertTrue(initial["activity_log"])
        self.assertFalse(initial["report_presets"])
        self.assertEqual(initial["clues"][0]["opened_required_count"], 0)

        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            session.engine.open_document(doc_id)
        session.engine.infer_clue("clue_empty_resignation")

        progressed = session.snapshot()
        self.assertGreaterEqual(progressed["clues"][0]["opened_required_count"], 2)
        self.assertIn("강요된 퇴사 서사", progressed["suspects"][2]["status"])

    def test_report_presets_unlock_after_case_solution(self):
        session = GameSession()

        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            session.engine.open_document(doc_id)
        session.engine.infer_clue("clue_empty_resignation")

        for doc_id in ["chat_jones_argument", "log_jones_calls", "note_if_i_disappear"]:
            session.engine.open_document(doc_id)
        session.engine.infer_clue("clue_jones_false_face")

        for doc_id in [
            "chat_alice_late_help",
            "log_badge_gap",
            "log_auth_midnight",
            "log_alice_dm_read",
            "log_alice_vpn_rewrite",
            "mail_alice_to_player",
        ]:
            session.engine.open_document(doc_id)
        session.engine.infer_clue("clue_alice_tampered_truth")

        solved = session.snapshot()
        self.assertEqual(len(solved["report_presets"]), 3)
        self.assertEqual(solved["report_presets"][0]["field"], "culprit")


if __name__ == "__main__":
    unittest.main()
