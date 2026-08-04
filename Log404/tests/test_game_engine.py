import unittest

from game.engine import GameEngine
from game.log404_web import GameSession


class GameEngineTest(unittest.TestCase):
    def setUp(self):
        self.game = GameEngine()

    def solve_case(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")
        for doc_id in ["log_badge_gap", "log_auth_midnight"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")

        for doc_id in [
            "chat_jones_argument",
            "log_jones_restricted_badge",
            "note_security_jones_override",
        ]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch2_scene_pressure", "jones_scene_combo")

        for doc_id in [
            "log_jones_calls",
            "note_if_i_disappear",
            "note_john_contingency_map",
        ]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch2_reversal", "panic_cleanup")

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

    def test_chapter_progression_by_tasks_and_clues(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        msg_1 = self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")
        self.assertIn("조사 과제 해결", msg_1)
        self.assertIn("log_badge_gap", self.game.state.unlocked_documents)
        self.assertIn("log_auth_midnight", self.game.state.unlocked_documents)

        for doc_id in ["log_badge_gap", "log_auth_midnight"]:
            self.game.open_document(doc_id)
        msg_2 = self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")
        self.assertIn("단서 확보", msg_2)
        self.assertEqual(self.game.state.current_chapter, 2)
        self.assertIn("log_jones_restricted_badge", self.game.state.unlocked_documents)
        self.assertIn("note_security_jones_override", self.game.state.unlocked_documents)
        self.assertNotIn("log_jones_calls", self.game.state.unlocked_documents)
        self.assertNotIn("note_if_i_disappear", self.game.state.unlocked_documents)
        self.assertNotIn("note_john_contingency_map", self.game.state.unlocked_documents)

        for doc_id in [
            "chat_jones_argument",
            "log_jones_restricted_badge",
            "note_security_jones_override",
        ]:
            self.game.open_document(doc_id)
        task_3 = self.game.submit_task_answer("task_ch2_scene_pressure", "jones_scene_combo")
        self.assertIn("log_jones_calls", self.game.state.unlocked_documents)
        self.assertIn("note_if_i_disappear", self.game.state.unlocked_documents)
        self.assertIn("note_john_contingency_map", self.game.state.unlocked_documents)
        self.assertIn("범인처럼 보입니다", task_3)

        for doc_id in [
            "log_jones_calls",
            "note_if_i_disappear",
            "note_john_contingency_map",
        ]:
            self.game.open_document(doc_id)
        task_4 = self.game.submit_task_answer("task_ch2_reversal", "panic_cleanup")
        self.assertEqual(self.game.state.current_chapter, 3)
        self.assertIn("단서 확보", task_4)
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

    def test_task_submission_requires_opened_documents(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        result = self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")
        self.assertIn("잠겨 있는 조사 과제", result)

        self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")
        result = self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")
        self.assertIn("log_badge_gap", result)
        self.assertIn("log_auth_midnight", result)

    def test_task_submission_blocks_wrong_answer(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        result = self.game.submit_task_answer("task_ch1_resignation_gap", "alice_dm")
        self.assertIn("온도 차이", result)
        self.assertNotIn("task_ch1_resignation_gap", self.game.state.solved_tasks)

    def test_new_story_documents_are_required_for_progression(self):
        self.game.open_document("mail_hr_termination_draft")
        self.game.open_document("mail_john_unsent_fragment")
        self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")
        self.game.open_document("log_badge_gap")
        self.game.open_document("log_auth_midnight")
        self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")

        for doc_id in ["chat_jones_argument", "log_jones_restricted_badge", "note_security_jones_override"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch2_scene_pressure", "jones_scene_combo")

        for doc_id in ["log_jones_calls", "note_if_i_disappear"]:
            self.game.open_document(doc_id)
        result = self.game.submit_task_answer("task_ch2_reversal", "pure_threat")
        self.assertIn("note_john_contingency_map", result)

        self.game.open_document("note_john_contingency_map")
        result = self.game.submit_task_answer("task_ch2_reversal", "pure_threat")
        self.assertIn("분노만으로는 설명되지", result)

    def test_ch2_active_tasks_change_after_first_room(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")
        for doc_id in ["log_badge_gap", "log_auth_midnight"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")

        self.assertEqual(
            [task.task_id for task in self.game.list_active_tasks()],
            ["task_ch2_scene_pressure"],
        )

        for doc_id in ["chat_jones_argument", "log_jones_restricted_badge", "note_security_jones_override"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch2_scene_pressure", "jones_scene_combo")

        self.assertEqual(
            [task.task_id for task in self.game.list_active_tasks()],
            ["task_ch2_reversal"],
        )

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
        self.assertIn("현재 조사 과제", self.game.next_step())
        self.assertIn("남은 정리 대상", self.game.report_guidance())

        self.solve_case()
        self.assertIn("최종 보고", self.game.investigation_stage())
        self.assertIn("누구의 설명을 빌려", self.game.next_step())
        self.assertIn("누구의 말 없이 다시 읽는 일", self.game.report_guidance())
        self.assertIn("mail_alice_unsent_escalation", self.game.report_guidance())

    def test_story_brief_advances_with_progress(self):
        for doc_id in ["mail_hr_termination_draft", "mail_john_unsent_fragment"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")
        for doc_id in ["log_badge_gap", "log_auth_midnight"]:
            self.game.open_document(doc_id)
        self.game.submit_task_answer("task_ch1_midnight_access", "timeline_conflict")

        story_brief = self.game.story_brief()
        self.assertEqual(story_brief["current"]["title"], "도와주는 사람의 손길")
        self.assertEqual(story_brief["roadmap"][0]["title"], "존스는 너무 쉽게 미워진다")
        self.assertIn("안도", story_brief["current"]["emotional_focus"])

    def test_initial_active_task_and_ch1_clue_gate(self):
        tasks = self.game.list_active_tasks()
        self.assertEqual([task.task_id for task in tasks], ["task_ch1_resignation_gap"])
        self.assertEqual(
            self.game.focused_document_ids(),
            {"mail_hr_termination_draft", "mail_john_unsent_fragment"},
        )
        self.assertEqual(
            self.game.archived_document_ids(),
            {"chat_alice_late_help", "chat_jones_argument"},
        )

        self.game.open_document("mail_hr_termination_draft")
        self.game.open_document("mail_john_unsent_fragment")
        infer_result = self.game.infer_clue("clue_empty_resignation")
        self.assertIn("현재 조사 과제", infer_result)

    def test_focus_documents_shift_after_ch1_first_task(self):
        self.game.open_document("mail_hr_termination_draft")
        self.game.open_document("mail_john_unsent_fragment")
        self.game.submit_task_answer("task_ch1_resignation_gap", "unsent_fragment")

        self.assertEqual(
            self.game.focused_document_ids(),
            {"log_badge_gap", "log_auth_midnight"},
        )
        self.assertIn("chat_alice_late_help", self.game.archived_document_ids())

    def test_server_snapshot_hides_meta_story_prompt(self):
        session = GameSession()
        snapshot = session.snapshot()
        self.assertNotIn("story_prompt", snapshot["clues"][0])
        self.assertEqual(
            [doc["doc_id"] for doc in snapshot["documents"]],
            ["mail_hr_termination_draft", "mail_john_unsent_fragment"],
        )
        self.assertEqual(
            [doc["doc_id"] for doc in snapshot["archived_documents"]],
            ["chat_alice_late_help", "chat_jones_argument"],
        )


if __name__ == "__main__":
    unittest.main()
