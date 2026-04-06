import unittest

from game.engine import GameEngine


class GameEngineTest(unittest.TestCase):
    def setUp(self):
        self.game = GameEngine()

    def test_initial_state(self):
        self.assertEqual(self.game.state.current_chapter, 1)
        self.assertEqual(len(self.game.state.unlocked_documents), 4)
        self.assertFalse(self.game.can_submit())

    def test_chapter_progression_by_clues(self):
        for doc_id in ["auth_log_001", "badge_log_001"]:
            self.game.open_document(doc_id)
        msg_1 = self.game.infer_clue("clue_auth_mismatch")
        self.assertIn("단서 확보", msg_1)
        self.assertEqual(self.game.state.current_chapter, 2)

        for doc_id in ["deploy_log_001", "db_log_001", "mail_002"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_deleted_deploy")
        self.assertEqual(self.game.state.current_chapter, 3)

        for doc_id in ["mail_003", "chat_002", "cctv_report_001"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_fake_alibi")
        self.assertTrue(self.game.can_submit())

    def test_document_filters_and_bookmarks(self):
        mails = self.game.list_documents(source_type="mail")
        self.assertEqual([doc.doc_id for doc in mails], ["mail_001"])
        self.assertIn("mail", self.game.list_source_types())

        self.game.toggle_bookmark("mail_001")
        bookmarked = self.game.list_bookmarks()
        self.assertEqual([doc.doc_id for doc in bookmarked], ["mail_001"])

        hits = self.game.search_documents("퇴사 공지")
        self.assertEqual([doc.doc_id for doc in hits], ["mail_001"])

    def test_endings(self):
        truth = self.game.ending("yoon", "데이터 조작 은폐", "배포 로그 삭제")
        partial = self.game.ending("unknown", "모름", "모름")

        self.assertIn("진실 엔딩", truth)
        self.assertIn("부분 정답 엔딩", partial)

    def test_submit_report_requires_all_clues(self):
        result = self.game.submit_report("yoon", "은폐", "배포 로그 삭제")
        self.assertIn("아직 최종 보고서를 제출할 수 없습니다", result)

    def test_submit_report_requires_all_fields(self):
        for doc_id in ["auth_log_001", "badge_log_001"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_auth_mismatch")
        for doc_id in ["deploy_log_001", "db_log_001", "mail_002"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_deleted_deploy")
        for doc_id in ["mail_003", "chat_002", "cctv_report_001"]:
            self.game.open_document(doc_id)
        self.game.infer_clue("clue_fake_alibi")

        result = self.game.submit_report("", "은폐", "배포 로그 삭제")
        self.assertIn("모두 입력", result)


if __name__ == "__main__":
    unittest.main()
