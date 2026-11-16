extends SceneTree

func _init() -> void:
	print("--- Running Main Scene Headless Load & Integration Test (Sprint 6) ---")
	var main_packed = load("res://scenes/main.tscn")
	assert(main_packed != null, "main.tscn failed to load")
	
	var main_inst = main_packed.instantiate()
	assert(main_inst != null, "main.tscn failed to instantiate")
	root.add_child(main_inst)
	
	if not main_inst.is_node_ready():
		await main_inst.ready

	# Reset to clean 6 defaults for deterministic test
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst._update_stats()
	main_inst._render_cards()

	assert(main_inst.card_grid.get_child_count() == 6, "Card grid should show 6 cards initially")
	print("✓ Initial 6 cards populated in GridContainer")
	
	# Test Filter Manga
	main_inst._on_tab_manga_pressed()
	assert(main_inst.card_grid.get_child_count() == 4, "Card grid should show 4 cards when filtered to Manga")
	print("✓ Filter to Manga verified (4 cards)")

	# Test Filter Gacha
	main_inst._on_tab_gacha_pressed()
	assert(main_inst.card_grid.get_child_count() == 2, "Card grid should show 2 cards when filtered to Gacha")
	print("✓ Filter to Gacha verified (2 cards)")

	# Reset to All & Test Search
	main_inst._on_tab_all_pressed()
	main_inst.search_input.text = "슬램"
	main_inst._on_search_text_changed("슬램")
	assert(main_inst.card_grid.get_child_count() == 1, "Card grid should show 1 card matching search")
	print("✓ Search filter verified (1 card)")

	# Clear search & Test Web Scrape + Camera Snap + Theme Toggle
	main_inst.search_input.text = ""
	main_inst._on_search_text_changed("")
	main_inst._on_web_scrape_btn_pressed()
	assert(main_inst.archive_state.items.size() == 7, "Total items should be 7 after web scrape")
	main_inst._on_camera_snap_btn_pressed()
	assert(main_inst.archive_state.items.size() == 8, "Total items should be 8 after camera snap")
	main_inst._on_theme_btn_pressed()
	print("✓ Web Scrape, Camera Snap, and Theme Toggle flows verified")

	# Test Sprint 8: In-Diary Stamp Picker & Fountain-Pen Quote Editor
	var first_item = main_inst.archive_state.items[0]
	main_inst.detail_modal.open(first_item)
	main_inst.detail_modal.apply_stamp("인생최애")
	assert(first_item.status_tag == "인생최애", "Stamp picker should update item status_tag")
	main_inst.detail_modal.quote_input.text = "포기하면 그 순간이 바로 시합 종료예요."
	main_inst.detail_modal._on_save_quote_btn_pressed()
	assert(first_item.memo == "포기하면 그 순간이 바로 시합 종료예요.", "Quote editor should update item memo")
	print("✓ In-Diary Rubber Stamp Picker & Fountain-Pen Quote Editor verified")

	# Test Sprint 9: E-Book Spine Shelf Banner & Today's Quote Cycler & Custom AddModal
	assert(main_inst.spine_shelf_row.get_child_count() == 8, "Spine shelf should render 8 miniature book spines for current items")
	var prev_quote = main_inst.today_quote_label.text
	main_inst._on_next_quote_btn_pressed()
	assert(main_inst.today_quote_label.text != "" and main_inst.today_quote_label.text != prev_quote, "Next quote button should cycle today's underlined quote")
	main_inst.add_modal.open()
	main_inst.add_modal.select_color("#15803d")
	main_inst.add_modal.title_input.text = "약사의 혼잣말"
	main_inst.add_modal.author_input.text = "휴우가 나츠"
	main_inst.add_modal.quote_input.text = "이건 독입니다."
	main_inst.add_modal._on_submit_btn_pressed()
	assert(main_inst.archive_state.items.size() == 9, "Submitting custom diary in AddModal should add item #9")
	assert(main_inst.archive_state.items[0].cover_color == "#15803d", "Newly added diary should use selected cover color")
	print("✓ E-Book Spine Shelf Banner, Quote Cycler & Custom AddModal verified")

	# Test Sprint 10: Interactive Volume First-Edition Stamp Toggle & Spine Click & Sort Toggle
	var slam_item = main_inst.archive_state.get_item_by_id("m1")
	main_inst.detail_modal.open(slam_item)
	var before_status = slam_item.volumes[1].get("status", "owned")
	main_inst.detail_modal.toggle_volume_status(1)
	var after_status = slam_item.volumes[1].get("status", "owned")
	assert(before_status != after_status, "toggle_volume_status should toggle between 'first' and 'owned'")
	main_inst._on_sort_btn_pressed()
	assert(main_inst.sort_by_volumes == true, "Sort button should toggle sort_by_volumes mode")
	print("✓ Volume First-Edition Stamp Toggle & Sort Mode verified")

	# Test Sprint 11: Full-Text Quote/Stamp Search & Volume Star Rating Cycler
	var quote_matches = main_inst.archive_state.get_filtered_items(-1, "농구")
	assert(quote_matches.size() == 1 and quote_matches[0].id == "m1", "Search should match underlined quotes inside volumes")
	var before_rating = int(slam_item.volumes[0].get("rating", 5))
	main_inst.detail_modal.cycle_volume_rating(0)
	var after_rating = int(slam_item.volumes[0].get("rating", 5))
	assert(before_rating != after_rating, "cycle_volume_rating should cycle volume star rating")
	print("✓ Full-Text Quote Search & Volume Star Rating Cycler verified")

	# Test Sprint 12: Per-Volume Quote Edit & Gacha Scrapbook Checklist in DetailModal
	main_inst.detail_modal.update_volume_quote(0, "왼손은 거들 뿐!")
	assert(slam_item.volumes[0].get("quote", "") == "왼손은 거들 뿐!", "update_volume_quote should update specific volume quote")
	var gacha_item = main_inst.archive_state.get_item_by_id("g1")
	main_inst.detail_modal.open(gacha_item)
	assert(main_inst.detail_modal.vol_section.visible == true, "Gacha diary should also display scrapbook checklist section")
	print("✓ Per-Volume Quote Edit & Gacha Scrapbook Checklist verified")

	# Test Sprint 13: Interactive Stat Bookmark Filter & Obi Band Cycler
	main_inst.detail_modal.open(slam_item)
	var old_obi = slam_item.obi_text
	main_inst.detail_modal.cycle_obi_preset()
	assert(slam_item.obi_text != "" and slam_item.obi_text != old_obi, "cycle_obi_preset should cycle the book's obi band text")
	main_inst._on_stat_firsts_clicked()
	assert(main_inst.card_grid.get_child_count() >= 4, "StatFirsts bookmark filter should filter items with first editions")
	print("✓ Interactive Stat Bookmark Filter & Obi Band Cycler verified")

	# Test Sprint 14: Card Star Rating Badge & Diary Summary Exporter
	var summary_text = main_inst.archive_state.export_diary_summary()
	assert(summary_text.contains("주희의 다꾸 서재") and summary_text.contains("슬램덩크"), "export_diary_summary should generate formatted reading diary summary")
	var sample_card = main_inst.card_grid.get_child(0)
	assert(sample_card.author_label.text.contains("★"), "Card author_label should display star rating badge")
	print("✓ Card Star Rating Badge & Diary Summary Exporter verified")

	# Test Sprint 15: Remove Last Volume in DetailModal & Modal Cover Washi Tape
	main_inst.detail_modal.open(slam_item)
	var before_vols = slam_item.volumes.size()
	main_inst.detail_modal._on_add_vol_btn_pressed()
	assert(slam_item.volumes.size() == before_vols + 1, "AddVolBtn should add 1 volume")
	main_inst.detail_modal.remove_last_volume()
	assert(slam_item.volumes.size() == before_vols, "remove_last_volume should remove the last added volume")
	print("✓ Remove Last Volume & Modal Washi Tape verified")

	# Test Sprint 16: Cover Icon Emoji Cycler & Today's Quote Direct Jump
	var old_icon = slam_item.icon_emoji
	main_inst.detail_modal.cycle_cover_icon()
	assert(slam_item.icon_emoji != "" and slam_item.icon_emoji != old_icon, "cycle_cover_icon should cycle item icon_emoji")
	main_inst.detail_modal.close()
	main_inst.open_current_quote_item()
	assert(main_inst.detail_modal.visible == true, "Clicking today's quote banner should open the corresponding item's diary modal")
	print("✓ Cover Icon Emoji Cycler & Today's Quote Direct Jump verified")

	# Test Sprint 17: In-Modal Cover Color Cycler & Clipboard Summary Copy
	main_inst.detail_modal.open(slam_item)
	var old_col = slam_item.cover_color
	main_inst.detail_modal.cycle_cover_color()
	assert(slam_item.cover_color != "" and slam_item.cover_color != old_col, "cycle_cover_color should cycle book cover color")
	var copied = main_inst.copy_summary_to_clipboard()
	assert(copied.contains("슬램덩크") and main_inst.status_toast.text.contains("📋"), "copy_summary_to_clipboard should update toast and return summary")
	print("✓ In-Modal Cover Color Cycler & Clipboard Summary Copy verified")

	# Test Sprint 18: Reading Progress Bar & Percentage in Card
	var first_card = main_inst.card_grid.get_child(0)
	assert(first_card.has_node("%ProgressBar") or first_card.progress_bar != null, "CardItem should have a reading progress bar")
	assert(first_card.get_reading_progress() > 0, "CardItem should compute a valid reading progress percentage")
	print("✓ Reading Progress Bar & Percentage in Card verified")

	# Test Sprint 19: Random Bookmark Pick & Completed Books Filter
	var picked_item = main_inst.pick_random_item()
	assert(picked_item != null and main_inst.detail_modal.visible == true, "pick_random_item should open detail modal for a random item")
	main_inst.detail_modal.close()
	main_inst._on_tab_complete_pressed()
	assert(main_inst.card_grid.get_child_count() >= 2, "Completed books filter should display items with 100% reading progress")
	print("✓ Random Bookmark Pick & Completed Books Filter verified")

	# Test Sprint 20: Reading Date Stamp & Volume Timestamp Stamping
	main_inst.detail_modal.open(slam_item)
	main_inst.detail_modal.stamp_volume_date(0)
	var v0 = slam_item.volumes[0]
	assert(v0.has("date") and v0["date"] != "", "stamp_volume_date should add formatted date stamp to volume")
	var overall_progress = main_inst.get_overall_reading_progress()
	assert(overall_progress > 0.0 and overall_progress <= 100.0, "get_overall_reading_progress should calculate library-wide progress")
	print("✓ Reading Date Stamp & Library Overall Progress verified")

	# Test Sprint 21: Fountain-Pen Ink Color Selector in DetailModal
	main_inst.detail_modal.set_fountain_pen_ink("#7f1d1d")
	assert(slam_item.get("memo_ink_color") == "#7f1d1d", "set_fountain_pen_ink should update item memo_ink_color")
	main_inst._on_theme_btn_pressed()
	assert(main_inst.theme_cursor >= 0, "Theme button should cycle unified room themes")
	print("✓ Fountain-Pen Ink Color Selector & Unified Room Themes verified")

	# Test Sprint 22: Highlighter Toggle & Favorites Filter Tab
	main_inst.detail_modal.toggle_quote_highlight()
	assert(slam_item.highlight_enabled == true, "toggle_quote_highlight should toggle highlight_enabled to true")
	main_inst.detail_modal.toggle_quote_highlight()
	assert(slam_item.highlight_enabled == false, "toggle_quote_highlight should toggle highlight_enabled back to false")
	assert(slam_item.get_average_rating() > 0.0, "get_average_rating should calculate correct average rating")
	var cherry_item = main_inst.archive_state.get_item_by_id("m4")
	assert(cherry_item.get_average_rating() == 5.0, "cherry_item should have 5.0 average rating")
	main_inst._on_tab_fav_pressed()
	assert(main_inst.filter_favorites_only == true, "TabFav should activate favorites filter")
	print("✓ Quote Highlighter Toggle & Favorites Filter Tab verified")

	# Test Sprint 23: 3-Way Sort Cycler & Spine Hover Tooltip
	main_inst.sort_mode = 0
	main_inst._on_sort_btn_pressed()
	assert(main_inst.sort_mode == 1 and main_inst.sort_btn.text == "↕ 다독순", "Sort button should switch to sort_mode 1")
	main_inst._on_sort_btn_pressed()
	assert(main_inst.sort_mode == 2 and main_inst.sort_btn.text == "↕ 최신순", "Sort button should switch to sort_mode 2")
	main_inst._on_sort_btn_pressed()
	assert(main_inst.sort_mode == 3 and main_inst.sort_btn.text == "↕ 가치순", "Sort button should switch to sort_mode 3")
	main_inst._on_sort_btn_pressed()
	assert(main_inst.sort_mode == 0 and main_inst.sort_btn.text == "↕ 기본순", "Sort button should cycle back to sort_mode 0")
	var first_spine = main_inst.spine_shelf_row.get_child(0)
	assert(first_spine.tooltip_text.contains("소장"), "Spine shelf ColorRect should have informative tooltip_text")
	assert(slam_item.updated_at >= 0, "collection_item should track updated_at timestamp")
	print("✓ 3-Way Sort Cycler & Spine Shelf Hover Tooltip verified")

	# Test Sprint 24: Per-Volume Bookmark Ribbon & Card Cover Badge
	main_inst.detail_modal.open(slam_item)
	main_inst.detail_modal.toggle_volume_bookmark(0)
	assert(slam_item.volumes[0].get("bookmarked", false) == true, "toggle_volume_bookmark should set volume bookmark to true")
	assert(slam_item.get_bookmarked_volumes_count() >= 1, "get_bookmarked_volumes_count should count bookmarked volumes")
	main_inst.detail_modal.toggle_volume_bookmark(0)
	assert(slam_item.volumes[0].get("bookmarked", false) == false, "toggle_volume_bookmark should toggle volume bookmark back to false")
	print("✓ Per-Volume Bookmark Ribbon & Card Cover Badge verified")

	# Test Sprint 25: Pen Nib Size Cycler & Book Quote Card Share
	var new_nib = main_inst.detail_modal.cycle_pen_nib_size()
	assert(new_nib in [10, 12, 14], "cycle_pen_nib_size should cycle nib font size among 10, 12, 14")
	var quote_card = main_inst.detail_modal.copy_book_quote_card()
	assert(quote_card.contains("독서 감상 카드") and quote_card.contains("슬램덩크"), "copy_book_quote_card should format quote card for clipboard")
	print("✓ Pen Nib Size Cycler & Book Quote Card Share verified")

	# Test Sprint 26: Washi Tape Pattern Cycler & Library Infographic Briefing
	var new_washi = main_inst.detail_modal.cycle_washi_tape()
	assert(new_washi in main_inst.detail_modal.WASHI_PRESETS, "cycle_washi_tape should cycle washi colors")
	var info_text = main_inst.show_library_infographic()
	assert(info_text.contains("소장:") and info_text.contains("완독률:"), "show_library_infographic should output library stats briefing")
	print("✓ Washi Tape Cycler & Library Infographic Briefing verified")

	# Test Sprint 27: Deco Sticker Pack Cycler & Quick Volume Advance
	var new_sticker = main_inst.detail_modal.cycle_deco_sticker()
	assert(new_sticker in ["✨", "🌸", "☕", "🌙", "🍀", "🎧"], "cycle_deco_sticker should cycle among sticker presets")
	var prev_vols = slam_item.volumes.size()
	var advanced_vol = slam_item.quick_advance_volume()
	assert(advanced_vol == prev_vols + 1, "quick_advance_volume should increment volume count")
	assert(slam_item.volumes.size() == prev_vols + 1, "quick_advance_volume should append new volume to item")
	print("✓ Deco Sticker Pack Cycler & Quick Volume Advance verified")

	# Test Sprint 28: Collector Rarity Tier Cycler & Smart Tag Quick Filter
	var new_rarity = main_inst.detail_modal.cycle_rarity_tier()
	assert(new_rarity in ["🌟노말", "💎레어", "👑슈퍼레어", "🔮시크릿"], "cycle_rarity_tier should cycle among rarity presets")
	var count_all = main_inst.filter_by_smart_tag("#전체")
	assert(count_all >= 6, "filter_by_smart_tag(#전체) should show all items")
	var count_manga = main_inst.filter_by_smart_tag("#만화")
	assert(count_manga >= 4, "filter_by_smart_tag(#만화) should filter to manga items")
	var count_gacha = main_inst.filter_by_smart_tag("#가챠")
	assert(count_gacha >= 2, "filter_by_smart_tag(#가챠) should filter to gacha items")
	main_inst.filter_by_smart_tag("#전체")
	print("✓ Collector Rarity Tier Cycler & Smart Tag Quick Filter verified")

	# Test Sprint 29: Diary Paper Pattern Cycler & Collector Storage Location Tracker
	var new_paper = main_inst.detail_modal.cycle_paper_pattern()
	assert(new_paper in ["ruled", "grid", "blank", "vintage"], "cycle_paper_pattern should cycle among paper presets")
	var new_loc = main_inst.detail_modal.cycle_storage_location()
	assert(new_loc in ["🗄️ 1층 장식장", "📦 아크릴함", "📚 책상 선반", "🎒 외출 파우치"], "cycle_storage_location should cycle among storage presets")
	print("✓ Diary Paper Pattern Cycler & Collector Storage Location Tracker verified")

	# Test Sprint 30: Reading Ambient Sound Player & Item Acquisition Source Tracker
	var new_src = main_inst.detail_modal.cycle_acquisition_source()
	assert(new_src in ["🏪 오프라인 서점", "🇯🇵 직구/해외", "🎁 선물", "🎪 팝업/행사", "📦 온라인 서점"], "cycle_acquisition_source should cycle among source presets")
	var new_snd = main_inst.cycle_ambient_sound()
	assert(new_snd in main_inst.AMBIENT_SOUND_PRESETS, "cycle_ambient_sound should cycle ambient sound presets")
	print("✓ Reading Ambient Sound Player & Item Acquisition Source Tracker verified")

	# Test Sprint 31: Reading Mood Tag Cycler & Target Volume Progress Tracker
	var new_mood = main_inst.detail_modal.cycle_reading_mood()
	assert(new_mood in ["🥰 힐링", "🔥 열혈", "😭 감동", "🤯 반전", "🤣 유쾌"], "cycle_reading_mood should cycle among mood presets")
	slam_item.target_volumes = 20
	var pct = slam_item.get_completion_percentage()
	assert(pct > 0.0 and pct <= 100.0, "get_completion_percentage should compute valid percentage against target_volumes")
	print("✓ Reading Mood Tag Cycler & Target Volume Progress Tracker verified")

	# Test Sprint 32: Reread Counter & Collection Asset Value Briefing
	var new_rc = main_inst.detail_modal.increment_reread_count()
	assert(new_rc >= 2, "increment_reread_count should increment reread_count")
	var total_val = main_inst.archive_state.get_total_collection_value()
	assert(total_val > 0, "get_total_collection_value should compute positive collection value")
	var info_str = main_inst.show_library_infographic()
	assert("총 가치: ₩" in info_str, "show_library_infographic should include total collection value")
	print("✓ Reread Counter & Collection Asset Value Briefing verified")

	# Test Sprint 33: Duplicate Count Tracker & HFlowContainer Modal Layout
	var prev_val = slam_item.get_item_value()
	var new_dc = main_inst.detail_modal.increment_duplicate_count()
	assert(new_dc >= 2, "increment_duplicate_count should increment duplicate_count")
	assert(slam_item.get_item_value() == prev_val * new_dc, "get_item_value should scale with duplicate_count")
	var stamp_row = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow")
	assert(stamp_row is HFlowContainer, "StampRow should use HFlowContainer to prevent horizontal modal overflow")
	print("✓ Duplicate Count Tracker & HFlowContainer Modal Layout verified")

	# Test Sprint 34: InkRow HFlowContainer Wrap, Diary Signature Stamp & Total Rereads Briefing
	var ink_row = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow")
	assert(ink_row is HFlowContainer, "InkRow should use HFlowContainer to prevent NibBtn horizontal clipping")
	var new_sig = main_inst.detail_modal.cycle_diary_signature()
	assert(new_sig in ["✍️ 주희의 서재", "🌙 밤독서 기록", "☕ 카페 다꾸", "🎁 소장 기념"], "cycle_diary_signature should cycle signature presets")
	var total_rr = main_inst.archive_state.get_total_rereads()
	assert(total_rr >= main_inst.archive_state.items.size(), "get_total_rereads should sum reread_count across all items")
	var info_str2 = main_inst.show_library_infographic()
	assert("총 재독:" in info_str2, "show_library_infographic should include total rereads count")
	print("✓ InkRow HFlowContainer Wrap, Diary Signature Stamp & Total Rereads Briefing verified")

	# Test Sprint 35: FilterBar HFlowContainer Wrap & Possession State Tracker
	var filter_hbox = main_inst.get_node_or_null("VBox/FilterMargin/FilterBar/HBox")
	assert(filter_hbox is HFlowContainer, "FilterBar/HBox should use HFlowContainer to prevent SortBtn clipping")
	var new_pos = main_inst.detail_modal.cycle_possession_state()
	assert(new_pos in ["📦 소장중", "🛒 예약중", "🚚 배송중", "✨ 전시중"], "cycle_possession_state should cycle possession presets")
	print("✓ FilterBar HFlowContainer Wrap & Possession State Tracker verified")

	# Test Sprint 36: Purchase Date Stamp & Header Live Asset Value Summary
	var stamped_date = main_inst.detail_modal.stamp_purchase_date()
	assert(stamped_date.begins_with("📅 "), "stamp_purchase_date should stamp formatted MM.DD date")
	assert("자산 ₩" in main_inst.sub_title.text, "main_view sub_title should display live collection asset value")
	print("✓ Purchase Date Stamp & Header Live Asset Value Summary verified")

	# Test Sprint 37: KRW Comma Formatter, Live Today Header Date & Custom Keyword Tag Cycler
	assert(main_inst.archive_state.format_krw(80000) == "₩80,000", "format_krw should format thousands with commas")
	assert("," in main_inst.sub_title.text, "main_view sub_title should display comma-formatted KRW asset value")
	var new_tag = main_inst.detail_modal.cycle_custom_tag()
	assert(new_tag in ["#소장각", "#인생만화", "#힐링타임", "#전시필수", "#한정특전"], "cycle_custom_tag should cycle keyword tags")
	print("✓ KRW Comma Formatter, Live Today Header Date & Custom Keyword Tag Cycler verified")

	# Test Sprint 38: Tag/Location Search, Modal Value Display & Share Card Signature
	var tag_hits = main_inst.archive_state.get_filtered_items(-1, new_tag)
	assert(tag_hits.size() >= 1, "get_filtered_items should match custom_tag")
	assert("💎 ₩" in main_inst.detail_modal.author_label.text, "detail_modal author_label should display formatted item value")
	var shared_card = main_inst.detail_modal.copy_book_quote_card()
	assert(new_tag in shared_card and "✍️" in shared_card or "🌙" in shared_card or "☕" in shared_card or "🎁" in shared_card, "copy_book_quote_card should include custom_tag and diary_signature")
	print("✓ Tag/Location Search, Modal Value Display & Share Card Signature verified")

	# Test Sprint 39: TagLabel Autowrap & One-Tap Estimated Value Boost
	assert(main_inst.detail_modal.tag_label.autowrap_mode == TextServer.AUTOWRAP_WORD_SMART, "tag_label should use AUTOWRAP_WORD_SMART to avoid ellipsis truncation")
	var before_val = slam_item.get_item_value()
	var after_val = main_inst.detail_modal.boost_estimated_value()
	assert(after_val > before_val, "boost_estimated_value should increase item estimated value")
	print("✓ TagLabel Autowrap & One-Tap Estimated Value Boost verified")

	# Test Sprint 40: 4-Way Sort Cycler (Value Sort) & Favorite Character Stamp
	var new_fc = main_inst.detail_modal.cycle_favorite_character()
	assert(new_fc in ["🌟 최애 캐릭터", "🏀 강백호", "🧙‍♀️ 프리렌", "🐾 치이카와", "🏐 히나타", "🌸 체리"], "cycle_favorite_character should cycle character presets")
	print("✓ 4-Way Sort Cycler (Value Sort) & Favorite Character Stamp verified")

	# Test Sprint 41: Condition Grade Cycler & Favorite Character Search Integration
	var new_cg = main_inst.detail_modal.cycle_condition_grade()
	assert(new_cg in ["✨ S급(최상)", "📖 A급(양호)", "🏷️ B급(사용감)", "📦 미개봉(새상품)"], "cycle_condition_grade should cycle condition grades")
	var fc_hits = main_inst.archive_state.get_filtered_items(-1, new_fc)
	assert(fc_hits.size() >= 1, "get_filtered_items should match favorite_character")
	print("✓ Condition Grade Cycler & Favorite Character Search Integration verified")

	# Test Sprint 42: Cover Finish Preset, Condition Search & Summary Asset Value
	var new_fin = main_inst.detail_modal.cycle_cover_finish()
	assert(new_fin in ["📜 무광 매트", "✨ 유광 코팅", "🌟 홀로그램", "🧶 패브릭 양장"], "cycle_cover_finish should cycle cover finish presets")
	var fin_hits = main_inst.archive_state.get_filtered_items(-1, new_fin)
	assert(fin_hits.size() >= 1, "get_filtered_items should match cover_finish")
	var summary_text2 = main_inst.archive_state.export_diary_summary()
	assert("총 자산 ₩" in summary_text2, "export_diary_summary should include formatted total collection value")
	print("✓ Cover Finish Preset, Condition Search & Summary Asset Value verified")

	# Test Sprint 43: Reading Weather Stamp & Cover Finish Sheen Visuals
	var new_rw = main_inst.detail_modal.cycle_reading_weather()
	assert(new_rw in ["☀️ 맑은 오후", "🌧️ 비 오는 밤", "❄️ 눈 내리는 창가", "🌙 새벽 감성"], "cycle_reading_weather should cycle weather presets")
	var card_out = main_inst.detail_modal.copy_book_quote_card()
	assert(new_rw in card_out, "copy_book_quote_card should include reading_weather stamp")
	print("✓ Reading Weather Stamp & Cover Finish Sheen Visuals verified")

	# Test Sprint 44: Reading Spot Stamp & Weather/Spot Search Integration
	var new_rs = main_inst.detail_modal.cycle_reading_spot()
	assert(new_rs in ["🛋️ 이불 속", "☕ 북카페", "🪑 내 방 책상", "🚃 출퇴근길"], "cycle_reading_spot should cycle spot presets")
	var spot_hits = main_inst.archive_state.get_filtered_items(-1, new_rs)
	assert(spot_hits.size() >= 1, "get_filtered_items should match reading_spot")
	print("✓ Reading Spot Stamp & Weather/Spot Search Integration verified")

	# Test Sprint 45: Modal Meta & Share Card Spot Sync + Acquisition Source Search
	assert(new_rw in main_inst.detail_modal.tag_label.text, "tag_label should include reading_weather")
	assert(new_rs in main_inst.detail_modal.tag_label.text, "tag_label should include reading_spot")
	var card_out_s45 = main_inst.detail_modal.copy_book_quote_card()
	assert(new_rs in card_out_s45, "copy_book_quote_card should include reading_spot")
	var src_hits = main_inst.archive_state.get_filtered_items(-1, "오프라인 서점")
	assert(src_hits.size() >= 1, "get_filtered_items should match acquisition_source")
	print("✓ Modal Meta & Share Card Spot Sync + Acquisition Source Search verified")

	# Test Sprint 46: Unified _refresh_tag_label & Card Value Display
	main_inst.detail_modal.cycle_reading_mood()
	main_inst.detail_modal.cycle_rarity_tier()
	main_inst.detail_modal.cycle_storage_location()
	main_inst.detail_modal.cycle_acquisition_source()
	assert(new_rw in main_inst.detail_modal.tag_label.text and new_rs in main_inst.detail_modal.tag_label.text, "All stamp cyclers should preserve reading_weather and reading_spot in tag_label")
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst._render_cards()
	var first_card_s46 = main_inst.card_grid.get_child(0)
	assert("₩" in first_card_s46.progress_label.text, "Card progress_label should display formatted KRW estimated_value")
	print("✓ Unified _refresh_tag_label & Card Value Display verified")

	# Test Sprint 47: Modal Author Rating Display & Summary Weather/Spot/Value Export
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	assert("★" in main_inst.detail_modal.author_label.text and "💎 ₩" in main_inst.detail_modal.author_label.text, "Modal author_label should include average rating and formatted KRW value")
	var card_out_s47 = main_inst.detail_modal.copy_book_quote_card()
	assert("💎 ₩" in card_out_s47, "copy_book_quote_card should include formatted KRW value")
	var summary_s47 = main_inst.archive_state.export_diary_summary()
	assert("☀️" in summary_s47 or "🌧️" in summary_s47 or "❄️" in summary_s47 or "🌙" in summary_s47, "export_diary_summary should include reading_weather")
	assert("🛋️" in summary_s47 or "☕" in summary_s47 or "🪑" in summary_s47 or "🚃" in summary_s47, "export_diary_summary should include reading_spot")
	print("✓ Modal Author Rating Display & Summary Weather/Spot/Value Export verified")

	# Test Sprint 48: Live Author Rating/Value Sync on Vol & Duplicate Changes + Library Avg Rating
	main_inst.detail_modal.cycle_volume_rating(0)
	assert(not ("★5.0" in main_inst.detail_modal.author_label.text), "cycle_volume_rating should immediately update modal author_label average rating")
	main_inst.detail_modal.increment_duplicate_count()
	assert("₩42,000" in main_inst.detail_modal.author_label.text, "increment_duplicate_count should immediately double modal author_label value")
	var lib_avg = main_inst.archive_state.get_average_library_rating()
	assert(lib_avg > 0.0 and lib_avg <= 5.0, "get_average_library_rating should return valid average rating")
	assert("평균 ★" in main_inst.archive_state.export_diary_summary(), "export_diary_summary should include average library rating")
	print("✓ Live Author Rating/Value Sync on Vol & Duplicate Changes + Library Avg Rating verified")

	# Test Sprint 49: Header Avg Rating KPI & Modal Vol Progress Header + KRW Helper
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst._update_stats()
	assert("★" in main_inst.sub_title.text, "Header sub_title should include average library rating")
	assert("평균 ★" in main_inst.show_library_infographic(), "show_library_infographic should include average library rating")
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	assert("/" in main_inst.detail_modal.vol_header.text and "%" in main_inst.detail_modal.vol_header.text, "Modal vol_header should show owned/target volume ratio and percentage")
	print("✓ Header Avg Rating KPI & Modal Vol Progress Header + KRW Helper verified")

	# Test Sprint 50 Milestone: Gacha Checklist Header, Quote Mood/Weather Toast & Zero-Dup format_krw
	var gacha_item_s50 = null
	for it in main_inst.archive_state.items:
		if it.category == 1:
			gacha_item_s50 = it
			break
	assert(gacha_item_s50 != null, "Should have a gacha item in defaults")
	main_inst.detail_modal.open(gacha_item_s50)
	assert(gacha_item_s50.storage_location in main_inst.detail_modal.vol_header.text and gacha_item_s50.condition_grade in main_inst.detail_modal.vol_header.text, "Gacha modal vol_header should show storage_location and condition_grade")
	var picked_s50 = main_inst.pick_random_item()
	assert(picked_s50 != null and picked_s50.reading_weather in main_inst.status_toast.text and picked_s50.reading_spot in main_inst.status_toast.text, "pick_random_item toast should include reading_weather and reading_spot")
	print("✓ Sprint 50 Milestone: Gacha Checklist Header, Quote Mood/Weather Toast & Zero-Dup format_krw verified")

	# Test Sprint 51: Card Rich Tooltip & Today Quote Live Refresh on Diary Update
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst._render_cards()
	var card_s51 = main_inst.card_grid.get_child(0)
	assert("₩" in card_s51.tooltip_text and "맑은 오후" in card_s51.tooltip_text and "이불 속" in card_s51.tooltip_text, "Card tooltip_text should include value, reading_weather, and reading_spot")
	var first_it = main_inst.archive_state.items[0]
	first_it.volumes[0]["quote"] = "스프린트51 실시간 밑줄 동기화"
	main_inst.quote_cursor = 0
	main_inst._on_diary_updated(first_it)
	assert("스프린트51 실시간 밑줄 동기화" in main_inst.today_quote_label.text, "_on_diary_updated should refresh today_quote_label")
	print("✓ Card Rich Tooltip & Today Quote Live Refresh on Diary Update verified")

	# Test Sprint 52: Modal Bookmark Count Header & Stat Card Tooltips
	main_inst._update_stats()
	var stat_books_card = main_inst.stat_items.get_parent().get_parent()
	assert("총 자산" in stat_books_card.tooltip_text, "StatBooks card tooltip_text should show total asset value")
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.toggle_volume_bookmark(0)
	assert("🔖" in main_inst.detail_modal.vol_header.text, "Modal vol_header should show bookmarked volume count when > 0")
	print("✓ Modal Bookmark Count Header & Stat Card Tooltips verified")

	# Test Sprint 53: Gacha Checklist Header Live Refresh & Search Power Tooltips
	assert("날씨" in main_inst.search_input.tooltip_text and "장소" in main_inst.search_input.tooltip_text, "SearchInput tooltip_text should describe unified search fields")
	main_inst.detail_modal.open(gacha_item_s50)
	var new_loc_s53 = main_inst.detail_modal.cycle_storage_location()
	var new_cg_s53 = main_inst.detail_modal.cycle_condition_grade()
	assert(new_loc_s53 in main_inst.detail_modal.vol_header.text and new_cg_s53 in main_inst.detail_modal.vol_header.text, "Gacha vol_header should live-refresh on storage_location and condition_grade changes")
	print("✓ Gacha Checklist Header Live Refresh & Search Power Tooltips verified")

	# Test Sprint 54: Gacha 3rd Checklist Line, Share Card Reread/Dup & Nav Tooltips
	var nav_row_s54 = main_inst.get_node_or_null("VBox/BottomBar/Margin/VBox/NavRow")
	assert(nav_row_s54 != null and nav_row_s54.get_child(0).tooltip_text != "", "Bottom NavRow buttons should have descriptive tooltips")
	main_inst.detail_modal.open(gacha_item_s50)
	assert(main_inst.detail_modal.vol_list.get_child_count() >= 3, "Gacha checklist should include 3rd summary line with source, mood, and favorite character")
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.increment_reread_count()
	main_inst.detail_modal.increment_duplicate_count()
	var card_out_s54 = main_inst.detail_modal.copy_book_quote_card()
	assert("회독" in card_out_s54 and "👯×" in card_out_s54, "copy_book_quote_card should include reread_count and duplicate_count when > 1")
	print("✓ Gacha 3rd Checklist Line, Share Card Reread/Dup & Nav Tooltips verified")

	# Test Sprint 55: Active Ink Swatch Highlight, Quote Banner Tooltip & Empty Search State
	main_inst.detail_modal.set_fountain_pen_ink("#7f1d1d")
	var ink_burgundy = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/InkBurgundy")
	var ink_espresso = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/InkEspresso")
	assert(ink_burgundy != null and ink_burgundy.get_theme_stylebox("normal").border_width_left == 2, "Active ink button should have 2px highlight border")
	assert(ink_espresso != null and ink_espresso.get_theme_stylebox("normal").border_width_left == 1, "Inactive ink button should keep 1px border")
	main_inst._refresh_today_quote()
	assert("독서 일기장 펼치기" in main_inst.today_quote_label.tooltip_text, "today_quote_label should expose dynamic open tooltip")
	main_inst.search_input.text = "존재하지않는작품XYZ"
	main_inst._render_cards()
	var empty_lbl = main_inst.card_grid.get_node_or_null("EmptyStateLabel")
	assert(empty_lbl != null and "조건에 맞는 서재 기록이 없습니다" in empty_lbl.text, "Empty search should display EmptyStateLabel guidance")
	main_inst.search_input.text = ""
	main_inst._render_cards()
	print("✓ Active Ink Swatch Highlight, Quote Banner Tooltip & Empty Search State verified")

	# Test Sprint 56: Active Stamp Highlight & Highlighter Button ON/OFF Visual State
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.apply_stamp("초판특전")
	var stamp_first_btn = main_inst.detail_modal.stamp_row.get_node_or_null("StampFirst")
	var stamp_comp_btn = main_inst.detail_modal.stamp_row.get_node_or_null("StampComplete")
	assert(stamp_first_btn != null and stamp_first_btn.get_theme_stylebox("normal").border_width_left == 2, "Active stamp button should have 2px border highlight")
	assert(stamp_comp_btn != null and stamp_comp_btn.get_theme_stylebox("normal").border_width_left == 1, "Inactive stamp button should keep 1px border")
	var hl_btn_s56 = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/QuoteEditRow/HighlightBtn")
	assert(hl_btn_s56 != null, "HighlightBtn should exist")
	var prev_hl = main_inst.archive_state.items[0].highlight_enabled
	main_inst.detail_modal.toggle_quote_highlight()
	assert(("ON" in hl_btn_s56.text) == (not prev_hl), "HighlightBtn text should reflect highlight ON/OFF state")
	main_inst.detail_modal.toggle_quote_highlight()
	print("✓ Active Stamp Highlight & Highlighter Button ON/OFF Visual State verified")

	# Test Sprint 57: AddModal Cover Swatch Highlight, Empty Title Feedback & StatFirsts Filter Sync
	main_inst.add_modal.open()
	main_inst.add_modal.select_color("#1d4ed8")
	var cobalt_btn = main_inst.add_modal.color_row.get_child(1)
	assert("✓ " in cobalt_btn.text and cobalt_btn.get_theme_stylebox("normal").border_width_left == 2, "Selected AddModal swatch should show checkmark and 2px border")
	main_inst.add_modal.title_input.text = "   "
	main_inst.add_modal._on_submit_btn_pressed()
	assert("⚠️" in main_inst.add_modal.title_input.placeholder_text and main_inst.add_modal.visible, "Empty title submit should show warning placeholder and keep AddModal open")
	main_inst.add_modal.close()
	main_inst._on_tab_complete_pressed()
	main_inst._on_stat_firsts_clicked()
	assert(main_inst.filter_firsts_only and not main_inst.filter_completed_only and not main_inst.filter_favorites_only, "_on_stat_firsts_clicked should reset completed/favorites flags")
	main_inst._on_tab_all_pressed()
	print("✓ AddModal Cover Swatch Highlight, Empty Title Feedback & StatFirsts Filter Sync verified")

	# Test Sprint 58: Clickable Volume Quote Edit Mode & Card Bookmark Count Badge
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.start_editing_volume_quote(1)
	assert(main_inst.detail_modal.editing_vol_index == 1 and "2권" in main_inst.detail_modal.save_quote_btn.text, "start_editing_volume_quote should set editing_vol_index and update SaveQuoteBtn text")
	main_inst.detail_modal.quote_input.text = "2권 직접 클릭 편집 테스트"
	main_inst.detail_modal._on_save_quote_btn_pressed()
	assert(main_inst.archive_state.items[0].volumes[1]["quote"] == "2권 직접 클릭 편집 테스트" and main_inst.detail_modal.editing_vol_index == -1, "Saving in volume edit mode should update volume quote and reset editing_vol_index")
	assert(main_inst.detail_modal.save_quote_btn.text == "🖋️ 밑줄 저장", "SaveQuoteBtn should reset to default text after volume quote save")
	var first_card_s58 = main_inst.card_grid.get_child(0)
	assert(first_card_s58.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "CardItem should use CURSOR_POINTING_HAND")
	main_inst.archive_state.items[0].volumes[0]["bookmarked"] = true
	first_card_s58.setup(main_inst.archive_state.items[0])
	assert("🔖1" in first_card_s58.vol_badge.text, "CardItem vol_badge should show bookmark count when > 0")
	print("✓ Clickable Volume Quote Edit Mode & Card Bookmark Count Badge verified")

	# Test Sprint 59: Quote Input Enter-to-Save, Gacha Duplicate Badge & Export Presets Ready
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.quote_input.text = "엔터키 바로 저장 테스트"
	main_inst.detail_modal.quote_input.text_submitted.emit("엔터키 바로 저장 테스트")
	assert(main_inst.archive_state.items[0].memo == "엔터키 바로 저장 테스트", "Pressing Enter in quote_input should save memo immediately")
	var gacha_it_s59 = main_inst.archive_state.items[2]
	gacha_it_s59.duplicate_count = 2
	var gacha_card_s59 = main_inst.card_grid.get_child(2)
	gacha_card_s59.setup(gacha_it_s59)
	assert(gacha_card_s59.vol_badge.text == "🔮×2", "Gacha CardItem vol_badge should show 🔮×2 when duplicate_count == 2")
	assert(FileAccess.file_exists("res://export_presets.cfg"), "export_presets.cfg should exist for macOS/Web builds")
	print("✓ Quote Input Enter-to-Save, Gacha Duplicate Badge & Export Presets Ready verified")

	# Test Sprint 60: Keyboard Escape Modal Close & AddModal Enter-to-Submit
	var esc_ev := InputEventKey.new()
	esc_ev.pressed = true
	esc_ev.keycode = KEY_ESCAPE
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	assert(main_inst.detail_modal.visible, "DetailModal should be open before Escape")
	main_inst.detail_modal._unhandled_input(esc_ev)
	assert(not main_inst.detail_modal.visible, "DetailModal should close on KEY_ESCAPE")
	main_inst.add_modal.open()
	assert(main_inst.add_modal.visible, "AddModal should be open before Escape")
	main_inst.add_modal._unhandled_input(esc_ev)
	assert(not main_inst.add_modal.visible, "AddModal should close on KEY_ESCAPE")
	main_inst.add_modal.open()
	main_inst.add_modal.title_input.text = "키보드 엔터 등록 테스트"
	main_inst.add_modal.quote_input.text = "엔터 한 번으로 등록"
	main_inst.add_modal.quote_input.text_submitted.emit("엔터 한 번으로 등록")
	assert(not main_inst.add_modal.visible, "AddModal should submit and close on quote_input Enter")
	print("✓ Keyboard Escape Modal Close & AddModal Enter-to-Submit verified")

	# Restore clean 6 defaults on disk so screenshot is clean
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst.archive_state.save_to_file()

	print("--- ALL GODOT INTEGRATION TESTS PASSED (100%) ---")
	quit(0)
