import unittest

from game.engine import GameEngine


class GameEngineTest(unittest.TestCase):
    def setUp(self):
        self.game = GameEngine()

    def solve_case(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_empty_resignation")

        for doc_id in [
            "chat_jones_argument",
            "log_jones_calls",
            "note_if_i_disappear",
            "note_security_jones_override",
            "note_john_contingency_map",
        ]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_jones_false_face")

        for doc_id in [
            "chat_alice_late_help",
            "log_badge_gap",
            "log_auth_midnight",
            "log_alice_dm_read",
            "log_alice_vpn_rewrite",
            "mail_alice_to_player",
            "mail_alice_unsent_escalation",
        ]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_alice_tampered_truth")

    def test_initial_state(self):
        self.assertEqual(self.game.state.current_chapter, 1)
        self.assertEqual(len(self.game.state.unlocked_documents), 4)
        self.assertFalse(self.game.can_submit())
        self.assertEqual(self.game.state.case_title, "John Kim 실종 사건")
        story_brief = self.game.story_brief()
        self.assertEqual(story_brief["current"]["title"], "아무도 울지 않는 퇴사")
        self.assertEqual(
            [entry["chapter"] for entry in story_brief["roadmap"]],
            [2, 3],
        )

    def test_chapter_progression_by_clues(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        msg_1 = self.game.infer_clue("clue_empty_resignation")
        self.assertIn("단서 확보", msg_1)
        self.assertEqual(self.game.state.current_chapter, 2)
        self.assertIn("log_jones_restricted_badge", self.game.state.unlocked_documents)
        self.assertIn("note_security_jones_override", self.game.state.unlocked_documents)
        self.assertIn("note_john_contingency_map", self.game.state.unlocked_documents)

        for doc_id in [
            "chat_jones_argument",
            "log_jones_calls",
            "note_if_i_disappear",
            "note_security_jones_override",
            "note_john_contingency_map",
        ]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_jones_false_face")
        self.assertEqual(self.game.state.current_chapter, 3)
        self.assertIn("ticket_jones_freeze_request", self.game.state.unlocked_documents)
        self.assertIn("mail_alice_unsent_escalation", self.game.state.unlocked_documents)

        for doc_id in [
            "chat_alice_late_help",
            "log_badge_gap",
            "log_auth_midnight",
            "log_alice_dm_read",
            "log_alice_vpn_rewrite",
            "mail_alice_to_player",
            "mail_alice_unsent_escalation",
        ]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_alice_tampered_truth")
        self.assertTrue(self.game.can_submit())

    def test_new_story_documents_are_required_for_progression(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_empty_resignation")

        for doc_id in ["chat_jones_argument", "log_jones_calls", "note_if_i_disappear"]:
            self.game.open_document(doc_id)
        result = self.game.infer_clue("clue_jones_false_face")

        self.assertIn("note_security_jones_override", result)
        self.assertIn("note_john_contingency_map", result)

    def test_document_filters_and_bookmarks(self):
        mails = self.game.list_documents(source_type="mail")
        self.assertEqual([doc.doc_id for doc in mails], ["mail_hr_termination_draft"])
        self.assertIn("mail", self.game.list_source_types())
        self.assertIn("chat", self.game.list_source_types())

        self.game.toggle_bookmark("mail_hr_termination_draft")
        bookmarked = self.game.list_bookmarks()
        self.assertEqual([doc.doc_id for doc in bookmarked], ["mail_hr_termination_draft"])

        hits = self.game.search_documents("존스 쪽 기록부터")
        self.assertEqual([doc.doc_id for doc in hits], ["chat_alice_late_help"])

    def test_endings(self):
        truth = self.game.ending("앨리스", "존을 보호하려던 은폐와 통제", "로그 조작과 캐시 재작성")
        partial = self.game.ending("존스", "모름", "모름")

        self.assertIn("진실 엔딩", truth)
        self.assertIn("부분 정답 엔딩", partial)
        self.assertIn("재검토 가이드", partial)
        self.assertIn("추천 재열람 문서", partial)

    def test_submit_report_requires_all_clues(self):
        result = self.game.submit_report("앨리스", "은폐", "로그 조작")
        self.assertIn("아직 최종 보고서를 제출할 수 없습니다", result)

    def test_submit_report_requires_all_fields(self):
        self.solve_case()
        result = self.game.submit_report("", "은폐", "로그 조작")
        self.assertIn("모두 입력", result)

    def test_submit_report_truth_after_solving_case(self):
        self.solve_case()
        result = self.game.submit_report("앨리스", "존을 보호하려던 은폐와 죄책감", "타임라인 조작과 캐시 재작성")
        self.assertIn("진실 엔딩", result)

    def test_investigation_guidance_changes_with_progress(self):
        self.assertIn("다음 표적 단서", self.game.next_step())
        self.assertIn("남은 정리 대상", self.game.report_guidance())

        self.solve_case()
        self.assertIn("최종 보고", self.game.investigation_stage())
        self.assertIn("누구의 설명을 빌려", self.game.next_step())
        self.assertIn("누구의 말 없이 다시 읽는 일", self.game.report_guidance())
        self.assertIn("mail_alice_unsent_escalation", self.game.report_guidance())

    def test_story_brief_advances_with_progress(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_empty_resignation")

        story_brief = self.game.story_brief()
        self.assertEqual(story_brief["current"]["title"], "도와주는 사람의 손길")
        self.assertEqual(story_brief["roadmap"][0]["title"], "존스는 너무 쉽게 미워진다")
        self.assertIn("안도", story_brief["current"]["emotional_focus"])


if __name__ == "__main__":
    unittest.main()
