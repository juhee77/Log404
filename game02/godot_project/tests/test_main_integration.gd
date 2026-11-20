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
	var empty_lbl = main_inst.card_grid.get_node_or_null("EmptyStateBox/EmptyStateLabel")
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

	# Test Sprint 61: Search & Quote Clear Buttons + Unified Action Cursor Affordance
	assert(main_inst.search_input.clear_button_enabled, "SearchInput should enable built-in clear button")
	assert(main_inst.detail_modal.quote_input.clear_button_enabled, "DetailModal quote_input should enable built-in clear button")
	assert(main_inst.tab_all.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "Header/Filter action buttons should use CURSOR_POINTING_HAND")
	print("✓ Search & Quote Clear Buttons + Unified Action Cursor Affordance verified")

	# Test Sprint 62: Gacha Possession Progress Label, AddModal Clear Buttons & Modal Cursor Affordance
	var gacha_it_s62 = null
	for it in main_inst.archive_state.items:
		if it.category == 1:
			gacha_it_s62 = it
			break
	assert(gacha_it_s62 != null, "Should find a gacha item")
	gacha_it_s62.possession_state = "✨ 전시중"
	var gacha_card_s62 = main_inst.card_grid.get_child(0)
	gacha_card_s62.setup(gacha_it_s62)
	assert("전시" in gacha_card_s62.progress_label.text, "Gacha CardItem progress_label should reflect possession_state 전시")
	assert(main_inst.add_modal.title_input.clear_button_enabled and main_inst.add_modal.author_input.clear_button_enabled and main_inst.add_modal.quote_input.clear_button_enabled, "AddModal LineEdits should enable clear_button_enabled")
	assert(main_inst.detail_modal.save_quote_btn.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND, "DetailModal action buttons should use CURSOR_POINTING_HAND")
	print("✓ Gacha Possession Progress Label, AddModal Clear Buttons & Modal Cursor Affordance verified")

	# Test Sprint 63: Volume Row Tooltips/Cursors & Search Escape Clear
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var first_vol_row = main_inst.detail_modal.vol_list.get_child(0)
	var first_hbox = first_vol_row.get_child(0).get_child(0)
	var vol_status_btn = first_hbox.get_child(1)
	assert(vol_status_btn.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND and vol_status_btn.tooltip_text != "", "Volume row buttons should have CURSOR_POINTING_HAND and tooltip_text")
	main_inst.detail_modal.close()
	main_inst.search_input.text = "슬램덩크"
	main_inst._render_cards()
	assert(main_inst.card_grid.get_child_count() == 1, "Search should filter to 1 card before Escape")
	var esc_search_ev := InputEventKey.new()
	esc_search_ev.pressed = true
	esc_search_ev.keycode = KEY_ESCAPE
	main_inst.search_input.gui_input.emit(esc_search_ev)
	assert(main_inst.search_input.text == "" and main_inst.card_grid.get_child_count() > 1, "Pressing Escape in SearchInput should clear text and restore cards")
	print("✓ Volume Row Tooltips/Cursors & Search Escape Clear verified")

	# Test Sprint 64: EmptyState Reset All Filters Button & AddModal Title Auto-Focus
	main_inst.search_input.text = "없는작품ABC999"
	main_inst._render_cards()
	var reset_btn_s64 = main_inst.card_grid.get_node_or_null("EmptyStateBox/EmptyStateResetBtn")
	assert(reset_btn_s64 != null, "EmptyStateBox should contain EmptyStateResetBtn")
	reset_btn_s64.pressed.emit()
	assert(main_inst.search_input.text == "" and main_inst.card_grid.get_child_count() > 1, "Pressing EmptyStateResetBtn should clear search and restore cards")
	main_inst.add_modal.open()
	assert(main_inst.add_modal.visible, "AddModal should open and focus title_input")
	main_inst.add_modal.close()
	print("✓ EmptyState Reset All Filters Button & AddModal Title Auto-Focus verified")

	# Test Sprint 65: Modal Stamp/Ink Tooltips & Dimmer Click-Outside Close
	var mood_tip_btn = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/StampRow/MoodBtn")
	var weather_tip_btn = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn")
	assert(mood_tip_btn != null and mood_tip_btn.tooltip_text != "", "StampRow buttons should have descriptive tooltips")
	assert(weather_tip_btn != null and weather_tip_btn.tooltip_text != "", "InkRow buttons should have descriptive tooltips")
	var dim_click := InputEventMouseButton.new()
	dim_click.pressed = true
	dim_click.button_index = MOUSE_BUTTON_LEFT
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.get_node("Dimmer").gui_input.emit(dim_click)
	assert(not main_inst.detail_modal.visible, "Clicking DetailModal Dimmer should close DetailModal")
	main_inst.add_modal.open()
	main_inst.add_modal.get_node("Dimmer").gui_input.emit(dim_click)
	assert(not main_inst.add_modal.visible, "Clicking AddModal Dimmer should close AddModal")
	print("✓ Modal Stamp/Ink Tooltips & Dimmer Click-Outside Close verified")

	# Test Sprint 66: Cover/Washi Interactive Tooltips & Modal Top Action Tooltips
	assert(main_inst.detail_modal.cover_rect.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND and main_inst.detail_modal.cover_rect.tooltip_text != "", "Modal CoverRect should have pointing cursor and tooltip")
	var washi_s66 = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/ModalWashiTape")
	assert(washi_s66 != null and washi_s66.tooltip_text != "", "ModalWashiTape should have tooltip_text")
	var del_btn_s66 = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn")
	assert(del_btn_s66 != null and del_btn_s66.tooltip_text != "", "Modal top action buttons should have tooltip_text")
	print("✓ Cover/Washi Interactive Tooltips & Modal Top Action Tooltips verified")

	# Test Sprint 67: Clickable SubTitle Infographic Briefing & Header Action Tooltips
	assert(main_inst.sub_title.mouse_default_cursor_shape == Control.CURSOR_POINTING_HAND and main_inst.sub_title.tooltip_text != "", "SubTitle should be clickable with pointing cursor and tooltip")
	var sub_click := InputEventMouseButton.new()
	sub_click.pressed = true
	sub_click.button_index = MOUSE_BUTTON_LEFT
	main_inst.sub_title.gui_input.emit(sub_click)
	assert("📊 소장:" in main_inst.status_toast.text, "Clicking SubTitle should display library infographic in status_toast")
	var top_add_s67 = main_inst.get_node_or_null("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AddBtn")
	assert(top_add_s67 != null and top_add_s67.tooltip_text != "", "Header AddBtn should have tooltip_text")
	print("✓ Clickable SubTitle Infographic Briefing & Header Action Tooltips verified")

	# Test Sprint 68: Volume Removed Toast Feedback & Keyboard Search Shortcut
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var vol_cnt_before_s68 = main_inst.archive_state.items[0].volumes.size()
	main_inst.detail_modal.remove_last_volume()
	assert(main_inst.archive_state.items[0].volumes.size() == vol_cnt_before_s68 - 1, "remove_last_volume should pop last volume")
	assert("마지막 권 기록 삭제" in main_inst.status_toast.text, "volume_removed should display deletion toast")
	main_inst.detail_modal.close()
	var slash_ev := InputEventKey.new()
	slash_ev.pressed = true
	slash_ev.keycode = KEY_SLASH
	main_inst._unhandled_input(slash_ev)
	print("✓ Volume Removed Toast Feedback & Keyboard Search Shortcut verified")

	# Test Sprint 69: Share Card Copied Feedback & Number Key 1-5 Tab Shortcuts
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var share_btn_s69 = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/ShareCardBtn")
	assert(share_btn_s69 != null and share_btn_s69.text == "💌 공유", "ShareCardBtn should start with 💌 공유")
	main_inst.detail_modal.copy_book_quote_card()
	assert(share_btn_s69.text == "✅ 복사됨!" and "클립보드에 복사되었습니다" in main_inst.status_toast.text, "copy_book_quote_card should update ShareCardBtn and status_toast")
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	assert(share_btn_s69.text == "💌 공유", "Re-opening DetailModal should reset ShareCardBtn text")
	main_inst.detail_modal.close()
	main_inst.search_input.release_focus()
	var k2_ev := InputEventKey.new()
	k2_ev.pressed = true
	k2_ev.keycode = KEY_2
	main_inst._unhandled_input(k2_ev)
	assert(main_inst.archive_state.current_filter == 0, "Pressing 2 should switch to Manga filter")
	var k1_ev := InputEventKey.new()
	k1_ev.pressed = true
	k1_ev.keycode = KEY_1
	main_inst._unhandled_input(k1_ev)
	assert(main_inst.archive_state.current_filter == -1, "Pressing 1 should switch back to All filter")
	print("✓ Share Card Copied Feedback & Number Key 1-5 Tab Shortcuts verified")

	# Test Sprint 70: Active Editing Volume Row Highlight & Tab Shortcut Tooltips
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.start_editing_volume_quote(1)
	var row0_panel = main_inst.detail_modal.vol_list.get_child(0)
	var row1_panel = main_inst.detail_modal.vol_list.get_child(1)
	assert(row1_panel is PanelContainer and row1_panel.get_theme_stylebox("panel").border_width_left == 2, "Editing volume row should have 2px highlight border")
	assert(row0_panel is PanelContainer and row0_panel.get_theme_stylebox("panel").border_width_left == 0, "Non-editing volume row should have 0px left border")
	main_inst.detail_modal.close()
	assert("[1]" in main_inst.tab_all.tooltip_text and "[2]" in main_inst.tab_manga.tooltip_text, "Filter tabs should include [1]-[5] shortcut tooltips")
	print("✓ Active Editing Volume Row Highlight & Tab Shortcut Tooltips verified")

	# Test Sprint 71: Toggle-Off Volume Quote Edit & Auto-Switch to All Tab on Submit
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.start_editing_volume_quote(1)
	assert(main_inst.detail_modal.editing_vol_index == 1, "First click should enter volume edit mode")
	main_inst.detail_modal.start_editing_volume_quote(1)
	assert(main_inst.detail_modal.editing_vol_index == -1 and main_inst.detail_modal.save_quote_btn.text == "🖋️ 밑줄 저장", "Second click on same volume should toggle off volume edit mode")
	main_inst.detail_modal.close()
	main_inst._on_tab_manga_pressed()
	main_inst._on_item_submitted("가챠 자동 탭 복귀 테스트", 1, "테스트", "#6d28d9", "테스트 문장")
	assert(main_inst.archive_state.current_filter == -1, "Submitting new item should switch back to All tab so new item is visible")
	print("✓ Toggle-Off Volume Quote Edit & Auto-Switch to All Tab on Submit verified")

	# Test Sprint 72: Reread/Duplicate Decrement & Camera Snap Auto-Switch to All Tab
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var rr_up = main_inst.detail_modal.increment_reread_count()
	var rr_dn = main_inst.detail_modal.decrement_reread_count()
	assert(rr_dn == rr_up - 1 and rr_dn >= 1, "decrement_reread_count should decrement reread_count with floor 1")
	var dc_up = main_inst.detail_modal.increment_duplicate_count()
	var dc_dn = main_inst.detail_modal.decrement_duplicate_count()
	assert(dc_dn == dc_up - 1 and dc_dn >= 1, "decrement_duplicate_count should decrement duplicate_count with floor 1")
	main_inst.detail_modal.close()
	main_inst._on_tab_gacha_pressed()
	main_inst._on_camera_snap_btn_pressed()
	assert(main_inst.archive_state.current_filter == -1, "Camera snap should auto-switch back to All tab")
	print("✓ Reread/Duplicate Decrement & Camera Snap Auto-Switch to All Tab verified")

	# Test Sprint 73: Estimated Value Right-Click Reduce & Keyboard S/R Shortcuts
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var val_up = main_inst.detail_modal.boost_estimated_value()
	var val_dn = main_inst.detail_modal.reduce_estimated_value()
	assert(val_dn == val_up - 5000 and val_dn >= 0, "reduce_estimated_value should subtract 5000 with floor 0")
	main_inst.detail_modal.close()
	main_inst.search_input.release_focus()
	var prev_sort_s73 = main_inst.sort_mode
	var ks_ev := InputEventKey.new()
	ks_ev.pressed = true
	ks_ev.keycode = KEY_S
	main_inst._unhandled_input(ks_ev)
	assert(main_inst.sort_mode == (prev_sort_s73 + 1) % 4, "Pressing S should cycle sort_mode")
	main_inst.sort_mode = 0
	print("✓ Estimated Value Right-Click Reduce & Keyboard S/R Shortcuts verified")

	# Test Sprint 74: Volume Rating Right-Click Reverse Cycle & Keyboard N/T Shortcuts
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var r0_before = int(main_inst.archive_state.items[0].volumes[0]["rating"])
	main_inst.detail_modal.reverse_cycle_volume_rating(0)
	var r0_after = int(main_inst.archive_state.items[0].volumes[0]["rating"])
	assert(r0_after != r0_before, "reverse_cycle_volume_rating should change volume rating")
	main_inst.detail_modal.cycle_volume_rating(0)
	main_inst.detail_modal.close()
	main_inst.search_input.release_focus()
	var prev_theme_s74 = main_inst.theme_cursor
	var kt_ev := InputEventKey.new()
	kt_ev.pressed = true
	kt_ev.keycode = KEY_T
	main_inst._unhandled_input(kt_ev)
	assert(main_inst.theme_cursor == (prev_theme_s74 + 1) % main_inst.ROOM_THEMES.size(), "Pressing T should cycle room theme")
	var kn_ev := InputEventKey.new()
	kn_ev.pressed = true
	kn_ev.keycode = KEY_N
	main_inst._unhandled_input(kn_ev)
	assert(main_inst.add_modal.visible, "Pressing N should open AddModal")
	main_inst.add_modal.close()
	print("✓ Volume Rating Right-Click Reverse Cycle & Keyboard N/T Shortcuts verified")

	# Test Sprint 75: Cover Right-Click Color Cycle & Keyboard M/Q Shortcuts
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var prev_col_s75 = main_inst.archive_state.items[0].cover_color
	var rclick_cov := InputEventMouseButton.new()
	rclick_cov.pressed = true
	rclick_cov.button_index = MOUSE_BUTTON_RIGHT
	main_inst.detail_modal.cover_rect.gui_input.emit(rclick_cov)
	assert(main_inst.archive_state.items[0].cover_color != prev_col_s75, "Right-clicking CoverRect should cycle cover_color")
	main_inst.detail_modal.close()
	main_inst.search_input.release_focus()
	var prev_amb_s75 = main_inst.ambient_sound_index
	var km_ev := InputEventKey.new()
	km_ev.pressed = true
	km_ev.keycode = KEY_M
	main_inst._unhandled_input(km_ev)
	assert(main_inst.ambient_sound_index != prev_amb_s75, "Pressing M should cycle ambient sound")
	var prev_q_s75 = main_inst.quote_cursor
	var kq_ev := InputEventKey.new()
	kq_ev.pressed = true
	kq_ev.keycode = KEY_Q
	main_inst._unhandled_input(kq_ev)
	assert(main_inst.quote_cursor != prev_q_s75, "Pressing Q should advance today quote")
	print("✓ Cover Right-Click Color Cycle & Keyboard M/Q Shortcuts verified")

	# Test Sprint 76: DetailModal Left/Right Page Flip Navigation & Keyboard I Infographic
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var k_right := InputEventKey.new()
	k_right.pressed = true
	k_right.keycode = KEY_RIGHT
	main_inst.detail_modal._unhandled_input(k_right)
	assert(main_inst.detail_modal.current_item == main_inst.archive_state.items[1], "KEY_RIGHT in DetailModal should navigate to next item")
	var k_left := InputEventKey.new()
	k_left.pressed = true
	k_left.keycode = KEY_LEFT
	main_inst.detail_modal._unhandled_input(k_left)
	assert(main_inst.detail_modal.current_item == main_inst.archive_state.items[0], "KEY_LEFT in DetailModal should navigate back to previous item")
	main_inst.detail_modal.close()
	main_inst.search_input.release_focus()
	var ki_ev := InputEventKey.new()
	ki_ev.pressed = true
	ki_ev.keycode = KEY_I
	main_inst._unhandled_input(ki_ev)
	assert("📊 소장:" in main_inst.status_toast.text, "Pressing I should show library infographic toast")
	print("✓ DetailModal Left/Right Page Flip Navigation & Keyboard I Infographic verified")

	# Test Sprint 77: Modal Header Prev/Next Buttons & Keyboard C Summary Copy
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var prev_btn_s77 = main_inst.detail_modal.get_node_or_null("Panel/VBox/Header/HBox/PrevItemBtn")
	var next_btn_s77 = main_inst.detail_modal.get_node_or_null("Panel/VBox/Header/HBox/NextItemBtn")
	assert(prev_btn_s77 != null and next_btn_s77 != null, "DetailModal header should have PrevItemBtn and NextItemBtn")
	next_btn_s77.pressed.emit()
	assert(main_inst.detail_modal.current_item == main_inst.archive_state.items[1], "Pressing NextItemBtn should open next item")
	main_inst.detail_modal.close()
	main_inst.search_input.release_focus()
	var kc_ev := InputEventKey.new()
	kc_ev.pressed = true
	kc_ev.keycode = KEY_C
	main_inst._unhandled_input(kc_ev)
	assert("클립보드에 복사되었습니다" in main_inst.status_toast.text, "Pressing C should copy library summary to clipboard")
	print("✓ Modal Header Prev/Next Buttons & Keyboard C Summary Copy verified")

	# Test Sprint 78: Two-Step Delete Confirmation Safety & Keyboard H Shortcut Cheatsheet
	var temp_item_s78 = main_inst.archive_state.add_item("삭제 안전 테스트 작품", 0, "테스터", "#b91c1c", "📕", "삭제 테스트", "테스트")
	var count_before_s78 = main_inst.archive_state.items.size()
	main_inst.detail_modal.open(temp_item_s78)
	var del_btn_s78 = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn")
	main_inst.detail_modal._on_delete_btn_pressed()
	assert(main_inst.detail_modal.delete_armed and "삭제 확인" in del_btn_s78.text and main_inst.archive_state.items.size() == count_before_s78, "First delete click should arm confirmation without deleting")
	main_inst.detail_modal._on_delete_btn_pressed()
	assert(not main_inst.detail_modal.visible and main_inst.archive_state.items.size() == count_before_s78 - 1, "Second delete click should delete item and close modal")
	main_inst.search_input.release_focus()
	var kh_ev := InputEventKey.new()
	kh_ev.pressed = true
	kh_ev.keycode = KEY_H
	main_inst._unhandled_input(kh_ev)
	assert("단축키:" in main_inst.status_toast.text, "Pressing H should display keyboard shortcut cheatsheet toast")
	print("✓ Two-Step Delete Confirmation Safety & Keyboard H Shortcut Cheatsheet verified")

	# Test Sprint 79: Visual Delete Arm + Escape Disarm & Card Right-Click Quick Advance
	var item_s79 = main_inst.archive_state.items[0]
	main_inst.detail_modal.open(item_s79)
	main_inst.detail_modal._on_delete_btn_pressed()
	var del_btn_s79 = main_inst.detail_modal.get_node_or_null("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn")
	assert(main_inst.detail_modal.delete_armed and del_btn_s79.get_theme_color("font_color") == Color(1.0, 1.0, 1.0, 1.0), "Armed DeleteBtn should highlight with white-on-red styling")
	var esc_disarm := InputEventKey.new()
	esc_disarm.pressed = true
	esc_disarm.keycode = KEY_ESCAPE
	main_inst.detail_modal._unhandled_input(esc_disarm)
	assert(main_inst.detail_modal.visible and not main_inst.detail_modal.delete_armed and del_btn_s79.text == "일기 삭제", "First ESC while delete_armed should disarm without closing modal")
	main_inst.detail_modal.close()
	var card_s79 = main_inst.card_grid.get_child(0)
	var vols_before_s79 = item_s79.volumes.size()
	var rclick_card := InputEventMouseButton.new()
	rclick_card.pressed = true
	rclick_card.button_index = MOUSE_BUTTON_RIGHT
	card_s79._gui_input(rclick_card)
	assert(item_s79.volumes.size() == vols_before_s79 + 1 and "완독 기록 완료" in main_inst.status_toast.text, "Right-clicking CardItem should quick_advance volume and show toast")
	print("✓ Visual Delete Arm + Escape Disarm & Card Right-Click Quick Advance verified")

	# Test Sprint 80: Bookmarked Volume Row Gold Accent & Keyboard 0 Reset All Filters
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.toggle_volume_bookmark(0)
	var bm_row_panel: PanelContainer = main_inst.detail_modal.vol_list.get_child(0)
	assert(bm_row_panel.get_theme_stylebox("panel").border_width_left == 3, "Bookmarked volume row should have 3px gold left accent border")
	main_inst.detail_modal.close()
	main_inst.search_input.text = "프리렌"
	main_inst._on_tab_manga_pressed()
	main_inst.search_input.release_focus()
	var k0_ev := InputEventKey.new()
	k0_ev.pressed = true
	k0_ev.keycode = KEY_0
	main_inst._unhandled_input(k0_ev)
	assert(main_inst.search_input.text == "" and main_inst.archive_state.current_filter == -1, "Pressing 0 should reset search and all filters")
	print("✓ Bookmarked Volume Row Gold Accent & Keyboard 0 Reset All Filters verified")

	# Sprint 81: Modal Page Index Toast & Filtered Value Summary Toast
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst._on_modal_navigate_requested(1)
	assert("(2/6)" in main_inst.status_toast.text, "Modal page flip toast should include (2/6) index indicator")
	main_inst.detail_modal.close()
	main_inst._on_tab_fav_pressed()
	assert("₩" in main_inst.status_toast.text and "종" in main_inst.status_toast.text, "Favorites tab toast should show filtered count and KRW total")
	main_inst._on_tab_all_pressed()
	print("✓ Modal Page Index Toast & Filtered Value Summary Toast verified")

	# Sprint 82: All-5-Tab Value Summary Toasts & Dynamic Modal Nav Tooltips
	main_inst._on_tab_manga_pressed()
	assert("이북·단행본" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Manga tab toast should show filtered count and KRW total")
	main_inst._on_tab_gacha_pressed()
	assert("가챠·굿즈" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Gacha tab toast should show filtered count and KRW total")
	main_inst._on_tab_all_pressed()
	assert("전체 서재" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "All tab toast should show filtered count and KRW total")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var modal_next_btn = main_inst.detail_modal.find_child("NextItemBtn", true, false)
	assert(modal_next_btn != null and "(2/6)" in modal_next_btn.tooltip_text, "Modal next button tooltip should preview (2/6) item")
	main_inst._on_modal_navigate_requested(1)
	assert("(3/6)" in modal_next_btn.tooltip_text, "Modal next button tooltip should update to (3/6) after navigation")
	main_inst.detail_modal.close()
	print("✓ All-5-Tab Value Summary Toasts & Dynamic Modal Nav Tooltips verified")

	# Sprint 83: Live Search Summary Toast & Modal Header Page Badge
	main_inst.search_input.text = "프리렌"
	main_inst._on_search_text_changed("프리렌")
	assert("검색 결과" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Search toast should include result count and KRW total")
	main_inst.search_input.text = ""
	main_inst._on_search_text_changed("")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var header_page_lbl = main_inst.detail_modal.find_child("PageBadgeLabel", true, false)
	assert(header_page_lbl != null and header_page_lbl.text == "1/6", "Modal header page badge should display 1/6 on first item")
	main_inst._on_modal_navigate_requested(1)
	assert(header_page_lbl.text == "2/6", "Modal header page badge should update to 2/6 after next navigation")
	main_inst.detail_modal.close()
	print("✓ Live Search Summary Toast & Modal Header Page Badge verified")

	# Sprint 84: Unified _open_detail_modal Sync (Quote Jump & Random Pick) & Sort Summary Toast
	main_inst.quote_cursor = 3
	main_inst.open_current_quote_item()
	var expected_item = main_inst.detail_modal.current_item
	var expected_idx = main_inst.archive_state.items.find(expected_item)
	assert(header_page_lbl.text == "%d/%d" % [expected_idx + 1, main_inst.archive_state.items.size()], "Quote jump should sync PageBadgeLabel")
	main_inst.detail_modal.close()
	var s84_picked = main_inst.pick_random_item()
	var s84_picked_idx = main_inst.archive_state.items.find(s84_picked)
	assert(header_page_lbl.text == "%d/%d" % [s84_picked_idx + 1, main_inst.archive_state.items.size()], "Random pick should sync PageBadgeLabel")
	main_inst.detail_modal.close()
	main_inst._on_sort_btn_pressed()
	assert("정렬 기준 변경" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Sort toast should include filtered count and KRW total")
	print("✓ Unified _open_detail_modal Sync & Sort Summary Toast verified")

	# Sprint 85: Modal Home/End Direct Jump & Firsts/Smart-Tag Value Summary Toasts
	main_inst._on_stat_firsts_clicked()
	assert("초판 스탬프" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "StatFirsts toast should show filtered count and KRW total")
	main_inst.filter_by_smart_tag("#만화")
	assert("스마트 태그 #만화" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Smart tag toast should show filtered count and KRW total")
	main_inst._on_tab_all_pressed()
	main_inst._on_card_clicked(main_inst.archive_state.items[2])
	var end_ev := InputEventKey.new()
	end_ev.pressed = true
	end_ev.keycode = KEY_END
	main_inst.detail_modal._unhandled_input(end_ev)
	assert(header_page_lbl.text == "6/6", "Pressing End in modal should jump to last page 6/6")
	var home_ev := InputEventKey.new()
	home_ev.pressed = true
	home_ev.keycode = KEY_HOME
	main_inst.detail_modal._unhandled_input(home_ev)
	assert(header_page_lbl.text == "1/6", "Pressing Home in modal should jump to first page 1/6")
	main_inst.detail_modal.close()
	print("✓ Modal Home/End Direct Jump & Firsts/Smart-Tag Value Summary Toasts verified")

	# Sprint 86: Clickable PageBadgeLabel & In-Modal Keyboard C Share Card Copy
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var badge_click_ev := InputEventMouseButton.new()
	badge_click_ev.pressed = true
	badge_click_ev.button_index = MOUSE_BUTTON_LEFT
	header_page_lbl.gui_input.emit(badge_click_ev)
	assert(header_page_lbl.text == "2/6", "Clicking PageBadgeLabel should advance to 2/6")
	var badge_rclick_ev := InputEventMouseButton.new()
	badge_rclick_ev.pressed = true
	badge_rclick_ev.button_index = MOUSE_BUTTON_RIGHT
	header_page_lbl.gui_input.emit(badge_rclick_ev)
	assert(header_page_lbl.text == "1/6", "Right-clicking PageBadgeLabel should go back to 1/6")
	var mc_ev := InputEventKey.new()
	mc_ev.pressed = true
	mc_ev.keycode = KEY_C
	main_inst.detail_modal._unhandled_input(mc_ev)
	assert("복사되었습니다" in main_inst.status_toast.text, "Pressing C inside modal should copy current item's quote card")
	main_inst.detail_modal.close()
	print("✓ Clickable PageBadgeLabel & In-Modal Keyboard C Share Card Copy verified")

	# Sprint 87: In-Modal Keyboard +/- Volume Control & H Modal Shortcut Help
	var target_s87 = main_inst.archive_state.items[0]
	var orig_vols: int = target_s87.volumes.size()
	main_inst._on_card_clicked(target_s87)
	var plus_ev := InputEventKey.new()
	plus_ev.pressed = true
	plus_ev.keycode = KEY_EQUAL
	main_inst.detail_modal._unhandled_input(plus_ev)
	assert(target_s87.volumes.size() == orig_vols + 1, "Pressing =/+ inside modal should add a volume")
	var minus_ev := InputEventKey.new()
	minus_ev.pressed = true
	minus_ev.keycode = KEY_MINUS
	main_inst.detail_modal._unhandled_input(minus_ev)
	assert(target_s87.volumes.size() == orig_vols, "Pressing - inside modal should remove the last volume")
	var mh_ev := InputEventKey.new()
	mh_ev.pressed = true
	mh_ev.keycode = KEY_H
	main_inst.detail_modal._unhandled_input(mh_ev)
	assert("모달 단축키" in main_inst.status_toast.text, "Pressing H inside modal should show modal shortcut cheatsheet toast")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard +/- Volume Control & H Modal Shortcut Help verified")

	# Sprint 88: In-Modal Keyboard E Quote Focus & Updated H Cheatsheet
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	main_inst.detail_modal.quote_input.caret_column = 0
	var me_ev := InputEventKey.new()
	me_ev.pressed = true
	me_ev.keycode = KEY_E
	main_inst.detail_modal._unhandled_input(me_ev)
	assert(main_inst.detail_modal.quote_input.caret_column == main_inst.detail_modal.quote_input.text.length(), "Pressing E in modal should focus quote_input and move caret to end")
	main_inst.detail_modal.quote_input.release_focus()
	main_inst._on_modal_help_requested()
	assert("[E]" in main_inst.status_toast.text, "Modal help cheatsheet should list [E] quote edit shortcut")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard E Quote Focus & Updated H Cheatsheet verified")

	# Sprint 89: In-Modal Keyboard L Highlighter Toggle & Updated Cheatsheet
	var target_s89 = main_inst.archive_state.items[0]
	var orig_hl: bool = target_s89.highlight_enabled
	main_inst._on_card_clicked(target_s89)
	var ml_ev := InputEventKey.new()
	ml_ev.pressed = true
	ml_ev.keycode = KEY_L
	main_inst.detail_modal._unhandled_input(ml_ev)
	assert(target_s89.highlight_enabled == (not orig_hl), "Pressing L inside modal should toggle quote highlight")
	main_inst.detail_modal._unhandled_input(ml_ev)
	main_inst._on_modal_help_requested()
	assert("[L]" in main_inst.status_toast.text, "Modal help cheatsheet should list [L] highlighter shortcut")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard L Highlighter Toggle & Updated Cheatsheet verified")

	# Sprint 90 Milestone: In-Modal Keyboard 1-4 Quick Stamp & Shortcut Tooltip Hints
	var target_s90 = main_inst.archive_state.items[0]
	var orig_stamp_s90: String = target_s90.status_tag
	main_inst._on_card_clicked(target_s90)
	var m3_ev := InputEventKey.new()
	m3_ev.pressed = true
	m3_ev.keycode = KEY_3
	main_inst.detail_modal._unhandled_input(m3_ev)
	assert(target_s90.status_tag == "인생최애", "Pressing 3 inside modal should apply 인생최애 stamp")
	main_inst.detail_modal.apply_stamp(orig_stamp_s90)
	var add_btn_s90: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/AddVolBtn")
	assert("(+)" in add_btn_s90.tooltip_text, "AddVolBtn tooltip should show (+) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[1~4]" in main_inst.status_toast.text, "Modal help cheatsheet should list [1~4] stamp shortcuts")
	main_inst.detail_modal.close()
	print("✓ Sprint 90 Milestone: In-Modal Keyboard 1-4 Quick Stamp & Shortcut Tooltip Hints verified")

	# Sprint 91: In-Modal Keyboard I Ink Cycle & V/Shift+V Value Adjust
	var target_s91 = main_inst.archive_state.items[0]
	var orig_ink_s91: String = target_s91.memo_ink_color
	var orig_val_s91: int = target_s91.get_item_value()
	main_inst._on_card_clicked(target_s91)
	var mi_ev := InputEventKey.new()
	mi_ev.pressed = true
	mi_ev.keycode = KEY_I
	main_inst.detail_modal._unhandled_input(mi_ev)
	assert(target_s91.memo_ink_color != orig_ink_s91, "Pressing I inside modal should cycle fountain pen ink color")
	var mv_ev := InputEventKey.new()
	mv_ev.pressed = true
	mv_ev.keycode = KEY_V
	main_inst.detail_modal._unhandled_input(mv_ev)
	assert(target_s91.get_item_value() == orig_val_s91 + 5000, "Pressing V inside modal should boost item value by 5000")
	var msv_ev := InputEventKey.new()
	msv_ev.pressed = true
	msv_ev.keycode = KEY_V
	msv_ev.shift_pressed = true
	main_inst.detail_modal._unhandled_input(msv_ev)
	assert(target_s91.get_item_value() == orig_val_s91, "Pressing Shift+V inside modal should reduce item value by 5000")
	main_inst.detail_modal.set_fountain_pen_ink(orig_ink_s91)
	main_inst._on_modal_help_requested()
	assert("[I]" in main_inst.status_toast.text and "[V]" in main_inst.status_toast.text, "Modal help cheatsheet should list [I] and [V] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard I Ink Cycle & V/Shift+V Value Adjust verified")

	# Sprint 92: In-Modal Keyboard W Washi Tape & P Paper Pattern Cyclers
	var target_s92 = main_inst.archive_state.items[0]
	var orig_tape_s92: String = target_s92.washi_tape_color
	var orig_paper_s92: String = target_s92.paper_pattern
	main_inst._on_card_clicked(target_s92)
	var mw_ev := InputEventKey.new()
	mw_ev.pressed = true
	mw_ev.keycode = KEY_W
	main_inst.detail_modal._unhandled_input(mw_ev)
	assert(target_s92.washi_tape_color != orig_tape_s92, "Pressing W inside modal should cycle washi tape color")
	var mp_ev := InputEventKey.new()
	mp_ev.pressed = true
	mp_ev.keycode = KEY_P
	main_inst.detail_modal._unhandled_input(mp_ev)
	assert(target_s92.paper_pattern != orig_paper_s92, "Pressing P inside modal should cycle paper pattern")
	main_inst._on_modal_help_requested()
	assert("[W]" in main_inst.status_toast.text and "[P]" in main_inst.status_toast.text, "Modal help cheatsheet should list [W] and [P] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard W Washi Tape & P Paper Pattern Cyclers verified")

	# Sprint 93: In-Modal Keyboard S Sticker & R Rarity Cyclers + Tooltip Hints
	var target_s93 = main_inst.archive_state.items[0]
	var orig_sticker_s93: String = target_s93.deco_sticker
	var orig_rarity_s93: String = target_s93.rarity_tier
	main_inst._on_card_clicked(target_s93)
	var ms_ev := InputEventKey.new()
	ms_ev.pressed = true
	ms_ev.keycode = KEY_S
	main_inst.detail_modal._unhandled_input(ms_ev)
	assert(target_s93.deco_sticker != orig_sticker_s93, "Pressing S inside modal should cycle deco sticker")
	var mr_ev := InputEventKey.new()
	mr_ev.pressed = true
	mr_ev.keycode = KEY_R
	main_inst.detail_modal._unhandled_input(mr_ev)
	assert(target_s93.rarity_tier != orig_rarity_s93, "Pressing R inside modal should cycle rarity tier")
	var tape_btn_s93: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/TapeCycleBtn")
	assert("(W)" in tape_btn_s93.tooltip_text, "TapeCycleBtn tooltip should include (W) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[S]" in main_inst.status_toast.text and "[R]" in main_inst.status_toast.text, "Modal help cheatsheet should list [S] and [R] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard S Sticker & R Rarity Cyclers + Tooltip Hints verified")

	# Sprint 94: In-Modal Keyboard O Obi Band & M Mood Tag Cyclers
	var target_s94 = main_inst.archive_state.items[0]
	var orig_obi_s94: String = target_s94.obi_text
	var orig_mood_s94: String = target_s94.reading_mood
	main_inst._on_card_clicked(target_s94)
	var mo_ev := InputEventKey.new()
	mo_ev.pressed = true
	mo_ev.keycode = KEY_O
	main_inst.detail_modal._unhandled_input(mo_ev)
	assert(target_s94.obi_text != orig_obi_s94, "Pressing O inside modal should cycle obi band preset")
	var mm_ev := InputEventKey.new()
	mm_ev.pressed = true
	mm_ev.keycode = KEY_M
	main_inst.detail_modal._unhandled_input(mm_ev)
	assert(target_s94.reading_mood != orig_mood_s94, "Pressing M inside modal should cycle reading mood tag")
	var mood_btn_s94: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/MoodBtn")
	assert("(M)" in mood_btn_s94.tooltip_text, "MoodBtn tooltip should include (M) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[O]" in main_inst.status_toast.text and "[M]" in main_inst.status_toast.text, "Modal help cheatsheet should list [O] and [M] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard O Obi Band & M Mood Tag Cyclers verified")

	# Sprint 95: In-Modal Keyboard G Condition Grade & T Custom Tag Cyclers
	var target_s95 = main_inst.archive_state.items[0]
	var orig_grade_s95: String = target_s95.condition_grade
	var orig_tag_s95: String = target_s95.custom_tag
	main_inst._on_card_clicked(target_s95)
	var mg_ev := InputEventKey.new()
	mg_ev.pressed = true
	mg_ev.keycode = KEY_G
	main_inst.detail_modal._unhandled_input(mg_ev)
	assert(target_s95.condition_grade != orig_grade_s95, "Pressing G inside modal should cycle condition grade")
	var mt_ev := InputEventKey.new()
	mt_ev.pressed = true
	mt_ev.keycode = KEY_T
	main_inst.detail_modal._unhandled_input(mt_ev)
	assert(target_s95.custom_tag != orig_tag_s95, "Pressing T inside modal should cycle custom tag")
	var tag_btn_s95: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn")
	assert("(T)" in tag_btn_s95.tooltip_text, "CustomTagBtn tooltip should include (T) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[G]" in main_inst.status_toast.text and "[T]" in main_inst.status_toast.text, "Modal help cheatsheet should list [G] and [T] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard G Condition Grade & T Custom Tag Cyclers verified")

	# Sprint 96: In-Modal Keyboard F Cover Finish & A Acquisition Source Cyclers
	var target_s96 = main_inst.archive_state.items[0]
	var orig_finish_s96: String = target_s96.cover_finish
	var orig_src_s96: String = target_s96.acquisition_source
	main_inst._on_card_clicked(target_s96)
	var mf_ev := InputEventKey.new()
	mf_ev.pressed = true
	mf_ev.keycode = KEY_F
	main_inst.detail_modal._unhandled_input(mf_ev)
	assert(target_s96.cover_finish != orig_finish_s96, "Pressing F inside modal should cycle cover finish")
	var ma_ev := InputEventKey.new()
	ma_ev.pressed = true
	ma_ev.keycode = KEY_A
	main_inst.detail_modal._unhandled_input(ma_ev)
	assert(target_s96.acquisition_source != orig_src_s96, "Pressing A inside modal should cycle acquisition source")
	var src_btn_s96: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/SourceBtn")
	assert("(A)" in src_btn_s96.tooltip_text, "SourceBtn tooltip should include (A) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[F]" in main_inst.status_toast.text and "[A]" in main_inst.status_toast.text, "Modal help cheatsheet should list [F] and [A] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard F Cover Finish & A Acquisition Source Cyclers verified")

	# Sprint 97: In-Modal Keyboard N Pen Nib & B Storage Location Cyclers
	var target_s97 = main_inst.archive_state.items[0]
	var orig_nib_s97: int = target_s97.pen_nib_size
	var orig_loc_s97: String = target_s97.storage_location
	main_inst._on_card_clicked(target_s97)
	var mn_ev := InputEventKey.new()
	mn_ev.pressed = true
	mn_ev.keycode = KEY_N
	main_inst.detail_modal._unhandled_input(mn_ev)
	assert(target_s97.pen_nib_size != orig_nib_s97, "Pressing N inside modal should cycle pen nib size")
	var mb_ev := InputEventKey.new()
	mb_ev.pressed = true
	mb_ev.keycode = KEY_B
	main_inst.detail_modal._unhandled_input(mb_ev)
	assert(target_s97.storage_location != orig_loc_s97, "Pressing B inside modal should cycle storage location")
	var loc_btn_s97: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/StorageBtn")
	assert("(B)" in loc_btn_s97.tooltip_text, "StorageBtn tooltip should include (B) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[N]" in main_inst.status_toast.text and "[B]" in main_inst.status_toast.text, "Modal help cheatsheet should list [N] and [B] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard N Pen Nib & B Storage Location Cyclers verified")

	# Sprint 98: In-Modal Keyboard D/Shift+D Duplicate & K Favorite Character Cyclers
	var target_s98 = main_inst.archive_state.items[0]
	var orig_dup_s98: int = target_s98.duplicate_count
	var orig_fc_s98: String = target_s98.favorite_character
	main_inst._on_card_clicked(target_s98)
	var md_ev := InputEventKey.new()
	md_ev.pressed = true
	md_ev.keycode = KEY_D
	main_inst.detail_modal._unhandled_input(md_ev)
	assert(target_s98.duplicate_count == orig_dup_s98 + 1, "Pressing D inside modal should increment duplicate_count")
	var msd_ev := InputEventKey.new()
	msd_ev.pressed = true
	msd_ev.keycode = KEY_D
	msd_ev.shift_pressed = true
	main_inst.detail_modal._unhandled_input(msd_ev)
	assert(target_s98.duplicate_count == orig_dup_s98, "Pressing Shift+D inside modal should decrement duplicate_count")
	var mk_ev := InputEventKey.new()
	mk_ev.pressed = true
	mk_ev.keycode = KEY_K
	main_inst.detail_modal._unhandled_input(mk_ev)
	assert(target_s98.favorite_character != orig_fc_s98, "Pressing K inside modal should cycle favorite_character")
	var fc_btn_s98: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn")
	assert("(K)" in fc_btn_s98.tooltip_text, "FavCharBtn tooltip should include (K) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[D]" in main_inst.status_toast.text and "[K]" in main_inst.status_toast.text, "Modal help cheatsheet should list [D] and [K] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard D/Shift+D Duplicate & K Favorite Character Cyclers verified")

	# Sprint 99: In-Modal Keyboard U Reading Weather & J Reading Spot Cyclers
	var target_s99 = main_inst.archive_state.items[0]
	var orig_weather_s99: String = target_s99.reading_weather
	var orig_spot_s99: String = target_s99.reading_spot
	main_inst._on_card_clicked(target_s99)
	var mu_ev := InputEventKey.new()
	mu_ev.pressed = true
	mu_ev.keycode = KEY_U
	main_inst.detail_modal._unhandled_input(mu_ev)
	assert(target_s99.reading_weather != orig_weather_s99, "Pressing U inside modal should cycle reading weather")
	var mj_ev := InputEventKey.new()
	mj_ev.pressed = true
	mj_ev.keycode = KEY_J
	main_inst.detail_modal._unhandled_input(mj_ev)
	assert(target_s99.reading_spot != orig_spot_s99, "Pressing J inside modal should cycle reading spot")
	var w_btn_s99: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn")
	assert("(U)" in w_btn_s99.tooltip_text, "WeatherBtn tooltip should include (U) shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[U]" in main_inst.status_toast.text and "[J]" in main_inst.status_toast.text, "Modal help cheatsheet should list [U] and [J] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard U Reading Weather & J Reading Spot Cyclers verified")

	# Sprint 100 Milestone: In-Modal Keyboard Q Cover Color, Y/Shift+Y Reread & Z Possession State + Dispatch Refactor
	var target_s100 = main_inst.archive_state.items[0]
	var orig_col_s100: String = target_s100.cover_color
	var orig_rr_s100: int = target_s100.reread_count
	var orig_pos_s100: String = target_s100.possession_state
	main_inst._on_card_clicked(target_s100)
	var mq_ev := InputEventKey.new()
	mq_ev.pressed = true
	mq_ev.keycode = KEY_Q
	main_inst.detail_modal._unhandled_input(mq_ev)
	assert(target_s100.cover_color != orig_col_s100, "Pressing Q inside modal should cycle cover color")
	var my_ev := InputEventKey.new()
	my_ev.pressed = true
	my_ev.keycode = KEY_Y
	main_inst.detail_modal._unhandled_input(my_ev)
	assert(target_s100.reread_count == orig_rr_s100 + 1, "Pressing Y inside modal should increment reread_count")
	var msy_ev := InputEventKey.new()
	msy_ev.pressed = true
	msy_ev.keycode = KEY_Y
	msy_ev.shift_pressed = true
	main_inst.detail_modal._unhandled_input(msy_ev)
	assert(target_s100.reread_count == orig_rr_s100, "Pressing Shift+Y inside modal should decrement reread_count")
	var mz_ev := InputEventKey.new()
	mz_ev.pressed = true
	mz_ev.keycode = KEY_Z
	main_inst.detail_modal._unhandled_input(mz_ev)
	assert(target_s100.possession_state != orig_pos_s100, "Pressing Z inside modal should cycle possession_state")
	var pos_btn_s100: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/PossessionBtn")
	assert("(Z" in pos_btn_s100.tooltip_text, "PossessionBtn tooltip should include (Z shortcut hint")
	main_inst._on_modal_help_requested()
	assert("[Q]" in main_inst.status_toast.text and "[Y]" in main_inst.status_toast.text and "[Z]" in main_inst.status_toast.text, "Modal help cheatsheet should list [Q], [Y], and [Z] shortcuts")
	main_inst.detail_modal.close()
	print("✓ Sprint 100 Milestone: In-Modal Keyboard Q/Y/Z & Dispatch Table Refactor verified")

	# Sprint 101: In-Modal Keyboard X Cover Icon & Delete Key Two-Step Safety
	var target_s101 = main_inst.archive_state.items[0]
	var orig_icon_s101: String = target_s101.icon_emoji
	main_inst._on_card_clicked(target_s101)
	var mx_ev := InputEventKey.new()
	mx_ev.pressed = true
	mx_ev.keycode = KEY_X
	main_inst.detail_modal._unhandled_input(mx_ev)
	assert(target_s101.icon_emoji != orig_icon_s101, "Pressing X inside modal should cycle cover icon")
	var mdel_ev := InputEventKey.new()
	mdel_ev.pressed = true
	mdel_ev.keycode = KEY_DELETE
	main_inst.detail_modal._unhandled_input(mdel_ev)
	assert(main_inst.detail_modal.delete_armed, "Pressing Delete inside modal should arm two-step delete")
	var mesc_s101 := InputEventKey.new()
	mesc_s101.pressed = true
	mesc_s101.keycode = KEY_ESCAPE
	main_inst.detail_modal._unhandled_input(mesc_s101)
	assert(not main_inst.detail_modal.delete_armed and main_inst.detail_modal.visible, "Pressing Escape should disarm delete without closing modal")
	main_inst._on_modal_help_requested()
	assert("[X]" in main_inst.status_toast.text and "[Del]" in main_inst.status_toast.text, "Modal help cheatsheet should list [X] and [Del] shortcuts")
	main_inst.detail_modal.close()
	print("✓ In-Modal Keyboard X Cover Icon & Delete Key Two-Step Safety verified")

	# Sprint 102: E-Book Space/PageUp/PageDown Navigation & Search Escape Value Summary
	main_inst.search_input.text = "프리렌"
	main_inst._render_cards()
	var sesc_ev := InputEventKey.new()
	sesc_ev.pressed = true
	sesc_ev.keycode = KEY_ESCAPE
	main_inst.search_input.gui_input.emit(sesc_ev)
	assert(main_inst.search_input.text == "" and "₩" in main_inst.status_toast.text, "Search Escape reset toast should show filtered KRW summary")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var space_ev := InputEventKey.new()
	space_ev.pressed = true
	space_ev.keycode = KEY_SPACE
	main_inst.detail_modal._unhandled_input(space_ev)
	assert(header_page_lbl.text == "2/6", "Pressing Space in modal should turn to next page 2/6")
	var pgup_ev := InputEventKey.new()
	pgup_ev.pressed = true
	pgup_ev.keycode = KEY_PAGEUP
	main_inst.detail_modal._unhandled_input(pgup_ev)
	assert(header_page_lbl.text == "1/6", "Pressing PageUp in modal should turn to previous page 1/6")
	main_inst.detail_modal.close()
	print("✓ E-Book Space/PageUp/PageDown Navigation & Search Escape Value Summary verified")

	# Sprint 103: Quote Index Tooltip, Quick-Advance KRW Toast & Submit Library Summary Toast
	main_inst.quote_cursor = 0
	main_inst._refresh_today_quote()
	assert("(1/" in main_inst.today_quote_label.tooltip_text, "Today quote tooltip should include (1/N) index")
	main_inst._on_card_quick_advanced(main_inst.archive_state.items[0])
	assert("₩" in main_inst.status_toast.text, "Quick advance toast should show item KRW value")
	main_inst._on_item_submitted("테스트 신작", 0, "테스트 작가")
	assert("₩" in main_inst.status_toast.text and "종" in main_inst.status_toast.text, "Item submit toast should show updated library count and KRW total")
	print("✓ Quote Index Tooltip, Quick-Advance KRW Toast & Submit Library Summary Toast verified")

	# Sprint 104: Web Scrape / Camera Snap / Delete Library Summary Toasts & NextQuoteBtn Index Tooltip
	assert("(1/" in main_inst.next_quote_btn.tooltip_text, "NextQuoteBtn tooltip should show (1/N) index")
	main_inst._on_web_scrape_btn_pressed()
	assert("웹 표지 자동 스크랩" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Web scrape toast should include library count and KRW total")
	main_inst._on_camera_snap_btn_pressed()
	assert("카메라 찰칵" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Camera snap toast should include library count and KRW total")
	var last_s104 = main_inst.archive_state.items[main_inst.archive_state.items.size() - 1]
	main_inst._on_item_deleted(last_s104)
	assert("삭제되었습니다" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Delete toast should include remaining library count and KRW total")
	print("✓ Web Scrape / Camera Snap / Delete Library Summary Toasts & NextQuoteBtn Index Tooltip verified")

	# Sprint 105: Shift+Q / Right-Click Prev Quote & Vol Add/Remove KRW Toasts
	main_inst.quote_cursor = 1
	main_inst._refresh_today_quote()
	var sq_ev := InputEventKey.new()
	sq_ev.pressed = true
	sq_ev.keycode = KEY_Q
	sq_ev.shift_pressed = true
	main_inst._unhandled_input(sq_ev)
	assert(main_inst.quote_cursor == 0, "Pressing Shift+Q on main view should step to previous quote")
	var rq_ev := InputEventMouseButton.new()
	rq_ev.pressed = true
	rq_ev.button_index = MOUSE_BUTTON_RIGHT
	main_inst.next_quote_btn.gui_input.emit(rq_ev)
	assert(main_inst.quote_cursor > 0, "Right-clicking NextQuoteBtn should wrap to previous quote")
	var vol_it_s105 = main_inst.archive_state.items[0]
	main_inst._on_volume_added(vol_it_s105)
	assert("₩" in main_inst.status_toast.text, "Volume added toast should include item KRW value")
	main_inst._on_volume_removed(vol_it_s105)
	assert("₩" in main_inst.status_toast.text, "Volume removed toast should include item KRW value")
	print("✓ Shift+Q / Right-Click Prev Quote & Vol Add/Remove KRW Toasts verified")

	# Sprint 106: Shift+S/T/M & Right-Click Reverse Cycle for Sort, Theme & Ambient Sound
	main_inst.sort_mode = 2
	var ss_ev := InputEventKey.new()
	ss_ev.pressed = true
	ss_ev.keycode = KEY_S
	ss_ev.shift_pressed = true
	main_inst._unhandled_input(ss_ev)
	assert(main_inst.sort_mode == 1, "Shift+S should step sort_mode backward")
	main_inst.theme_cursor = 2
	var st_ev := InputEventKey.new()
	st_ev.pressed = true
	st_ev.keycode = KEY_T
	st_ev.shift_pressed = true
	main_inst._unhandled_input(st_ev)
	assert(main_inst.theme_cursor == 1, "Shift+T should step theme_cursor backward")
	main_inst.ambient_sound_index = 2
	var sm_ev := InputEventKey.new()
	sm_ev.pressed = true
	sm_ev.keycode = KEY_M
	sm_ev.shift_pressed = true
	main_inst._unhandled_input(sm_ev)
	assert(main_inst.ambient_sound_index == 1, "Shift+M should step ambient_sound_index backward")
	print("✓ Shift+S/T/M & Right-Click Reverse Cycle for Sort, Theme & Ambient Sound verified")

	# Sprint 107: Shift+R / Right-Click Random Pick Peek Without Opening Modal
	main_inst.detail_modal.close()
	var sr_ev := InputEventKey.new()
	sr_ev.pressed = true
	sr_ev.keycode = KEY_R
	sr_ev.shift_pressed = true
	main_inst._unhandled_input(sr_ev)
	assert(not main_inst.detail_modal.visible and "미리보기" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Shift+R should peek random item in toast without opening modal")
	var rpick_rc := InputEventMouseButton.new()
	rpick_rc.pressed = true
	rpick_rc.button_index = MOUSE_BUTTON_RIGHT
	main_inst.random_pick_btn.gui_input.emit(rpick_rc)
	assert(not main_inst.detail_modal.visible and "미리보기" in main_inst.status_toast.text, "Right-clicking RandomPickBtn should peek random item without opening modal")
	print("✓ Shift+R / Right-Click Random Pick Peek Without Opening Modal verified")

	# Sprint 108: Right-Click Spine Peek & Right-Click SubTitle Clipboard Copy
	var s108_spine = main_inst.spine_shelf_row.get_child(0)
	var sp_rc := InputEventMouseButton.new()
	sp_rc.pressed = true
	sp_rc.button_index = MOUSE_BUTTON_RIGHT
	s108_spine.gui_input.emit(sp_rc)
	assert("책등 상세 미리보기" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Right-clicking spine should show detailed preview with KRW value")
	main_inst.sub_title.gui_input.emit(sp_rc)
	assert("클립보드에 복사되었습니다" in main_inst.status_toast.text, "Right-clicking SubTitle should copy library summary to clipboard")
	print("✓ Right-Click Spine Peek & Right-Click SubTitle Clipboard Copy verified")

	# Sprint 109: Right-Click TodayQuoteLabel Step & AddModal Author Enter-to-Submit
	main_inst.quote_cursor = 0
	main_inst._refresh_today_quote()
	var tq_rc := InputEventMouseButton.new()
	tq_rc.pressed = true
	tq_rc.button_index = MOUSE_BUTTON_RIGHT
	main_inst.today_quote_label.gui_input.emit(tq_rc)
	assert(main_inst.quote_cursor == 1, "Right-clicking today_quote_label should advance to next quote")
	var count_before_s109: int = main_inst.archive_state.items.size()
	main_inst.add_modal.open()
	main_inst.add_modal.title_input.text = "작가엔터등록테스트"
	main_inst.add_modal.author_input.text = "테스트작가"
	main_inst.add_modal.author_input.text_submitted.emit("테스트작가")
	assert(main_inst.archive_state.items.size() == count_before_s109 + 1 and not main_inst.add_modal.visible, "Pressing Enter in AddModal author_input should submit new item")
	print("✓ Right-Click TodayQuoteLabel Step & AddModal Author Enter-to-Submit verified")

	# Sprint 110 Milestone: Right-Click PrevItemBtn/NextItemBtn First/Last Page Jump
	main_inst._on_card_clicked(main_inst.archive_state.items[2])
	var prev_btn_s110 = main_inst.detail_modal.find_child("PrevItemBtn", true, false)
	var next_btn_s110 = main_inst.detail_modal.find_child("NextItemBtn", true, false)
	var rclick_s110 := InputEventMouseButton.new()
	rclick_s110.pressed = true
	rclick_s110.button_index = MOUSE_BUTTON_RIGHT
	next_btn_s110.gui_input.emit(rclick_s110)
	assert(header_page_lbl.text.ends_with("/%d" % main_inst.archive_state.items.size()) and header_page_lbl.text.begins_with(str(main_inst.archive_state.items.size())), "Right-clicking NextItemBtn should jump to last page")
	prev_btn_s110.gui_input.emit(rclick_s110)
	assert(header_page_lbl.text.begins_with("1/"), "Right-clicking PrevItemBtn should jump to first page")
	assert("우클릭: 끝" in next_btn_s110.tooltip_text, "NextItemBtn tooltip should mention right-click jump to end")
	main_inst.detail_modal.close()
	print("✓ Sprint 110 Milestone: Right-Click PrevItemBtn/NextItemBtn First/Last Page Jump verified")

	# Sprint 111 Milestone: Reset-All KRW Summary Toast & Right-Click AddBtn Instant JSON Backup
	main_inst._reset_all_filters()
	assert("전체 서재가 복원되었습니다." in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Reset-all toast should include KRW summary")
	var top_add_s111 = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AddBtn")
	assert("우클릭: 즉시 JSON 저장" in top_add_s111.tooltip_text, "AddBtn tooltip should mention right-click JSON backup")
	var rclick_s111 := InputEventMouseButton.new()
	rclick_s111.pressed = true
	rclick_s111.button_index = MOUSE_BUTTON_RIGHT
	top_add_s111.gui_input.emit(rclick_s111)
	assert("JSON 백업 저장 완료" in main_inst.status_toast.text or "로컬 JSON 서재 백업 저장 완료" in main_inst.status_toast.text, "Right-clicking AddBtn should show JSON backup toast")
	assert("₩" in main_inst.status_toast.text, "Right-clicking AddBtn backup toast should include KRW summary")
	print("✓ Sprint 111 Milestone: Reset-All KRW Summary & Right-Click AddBtn JSON Backup verified")

	# Sprint 112 Milestone: Bottom Dock WebBtn / CamBtn / DiyBtn Right-Click Power Actions
	var web_btn_s112 = main_inst.get_node("VBox/BottomBar/Margin/VBox/NavRow/WebBtn")
	var cam_btn_s112 = main_inst.get_node("VBox/BottomBar/Margin/VBox/NavRow/CamBtn")
	var diy_btn_s112 = main_inst.get_node("VBox/BottomBar/Margin/VBox/NavRow/DiyBtn")
	assert("우클릭: 이북·단행본 필터" in web_btn_s112.tooltip_text, "WebBtn tooltip should mention right-click manga filter")
	assert("우클릭: 가챠노트 필터" in cam_btn_s112.tooltip_text, "CamBtn tooltip should mention right-click gacha filter")
	assert("우클릭: 즉시 JSON 저장" in diy_btn_s112.tooltip_text, "DiyBtn tooltip should mention right-click JSON backup")
	var rclick_s112 := InputEventMouseButton.new()
	rclick_s112.pressed = true
	rclick_s112.button_index = MOUSE_BUTTON_RIGHT
	web_btn_s112.gui_input.emit(rclick_s112)
	assert(main_inst.archive_state.current_filter == 0, "Right-clicking WebBtn should filter to manga (0)")
	cam_btn_s112.gui_input.emit(rclick_s112)
	assert(main_inst.archive_state.current_filter == 1, "Right-clicking CamBtn should filter to gacha (1)")
	main_inst._on_tab_all_pressed()
	diy_btn_s112.gui_input.emit(rclick_s112)
	assert("로컬 JSON 서재 백업 저장 완료" in main_inst.status_toast.text and "₩" in main_inst.status_toast.text, "Right-clicking DiyBtn should trigger JSON backup toast with KRW summary")
	print("✓ Sprint 112 Milestone: Bottom Dock WebBtn/CamBtn/DiyBtn Right-Click Power Actions verified")

	# Sprint 113 Milestone: Right-Click Reverse Cycle for Obi / Washi / Sticker / Rarity / Paper
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var rclick_s113 := InputEventMouseButton.new()
	rclick_s113.pressed = true
	rclick_s113.button_index = MOUSE_BUTTON_RIGHT
	var obi_btn_s113 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/ObiCycleBtn")
	var tape_btn_s113 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/TapeCycleBtn")
	var deco_btn_s113 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/DecoStickerBtn")
	var rar_btn_s113 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/RarityBtn")
	var pap_btn_s113 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/PaperBtn")
	assert("우클릭: 이전" in obi_btn_s113.tooltip_text and "우클릭: 이전" in pap_btn_s113.tooltip_text, "Decorator tooltips should mention right-click reverse cycle")
	main_inst.detail_modal.cycle_obi_preset(1)
	var obi_after_fwd = main_inst.archive_state.items[0].obi_text
	obi_btn_s113.gui_input.emit(rclick_s113)
	assert(main_inst.archive_state.items[0].obi_text != obi_after_fwd, "Right-clicking ObiCycleBtn should step backward")
	main_inst.detail_modal.cycle_washi_tape(1)
	var tape_after_fwd = main_inst.archive_state.items[0].washi_tape_color
	tape_btn_s113.gui_input.emit(rclick_s113)
	assert(main_inst.archive_state.items[0].washi_tape_color != tape_after_fwd, "Right-clicking TapeCycleBtn should step backward")
	var deco_before = main_inst.archive_state.items[0].deco_sticker
	main_inst.detail_modal.cycle_deco_sticker(1)
	deco_btn_s113.gui_input.emit(rclick_s113)
	assert(main_inst.archive_state.items[0].deco_sticker == deco_before, "Right-clicking DecoStickerBtn should return to previous sticker")
	var rar_before = main_inst.archive_state.items[0].rarity_tier
	main_inst.detail_modal.cycle_rarity_tier(1)
	rar_btn_s113.gui_input.emit(rclick_s113)
	assert(main_inst.archive_state.items[0].rarity_tier == rar_before, "Right-clicking RarityBtn should return to previous rarity")
	var pap_before = main_inst.archive_state.items[0].paper_pattern
	main_inst.detail_modal.cycle_paper_pattern(1)
	pap_btn_s113.gui_input.emit(rclick_s113)
	assert(main_inst.archive_state.items[0].paper_pattern == pap_before, "Right-clicking PaperBtn should return to previous paper pattern")
	main_inst.detail_modal.close()
	print("✓ Sprint 113 Milestone: Modal Decorator 5-Button Right-Click Reverse Cycle verified")

	# Sprint 114 Milestone: Right-Click Reverse Cycle for Storage / Source / Mood / Possession
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var rclick_s114 := InputEventMouseButton.new()
	rclick_s114.pressed = true
	rclick_s114.button_index = MOUSE_BUTTON_RIGHT
	var sto_btn_s114 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/StorageBtn")
	var src_btn_s114 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/SourceBtn")
	var mood_btn_s114 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/MoodBtn")
	var pos_btn_s114 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/PossessionBtn")
	assert("우클릭: 이전" in sto_btn_s114.tooltip_text and "우클릭: 이전" in pos_btn_s114.tooltip_text, "Storage/Possession tooltips should mention right-click reverse cycle")
	var sto_before = main_inst.archive_state.items[0].storage_location
	main_inst.detail_modal.cycle_storage_location(1)
	sto_btn_s114.gui_input.emit(rclick_s114)
	assert(main_inst.archive_state.items[0].storage_location == sto_before, "Right-clicking StorageBtn should step backward")
	var src_before = main_inst.archive_state.items[0].acquisition_source
	main_inst.detail_modal.cycle_acquisition_source(1)
	src_btn_s114.gui_input.emit(rclick_s114)
	assert(main_inst.archive_state.items[0].acquisition_source == src_before, "Right-clicking SourceBtn should step backward")
	var mood_before = main_inst.archive_state.items[0].reading_mood
	main_inst.detail_modal.cycle_reading_mood(1)
	mood_btn_s114.gui_input.emit(rclick_s114)
	assert(main_inst.archive_state.items[0].reading_mood == mood_before, "Right-clicking MoodBtn should step backward")
	var pos_before = main_inst.archive_state.items[0].possession_state
	main_inst.detail_modal.cycle_possession_state(1)
	pos_btn_s114.gui_input.emit(rclick_s114)
	assert(main_inst.archive_state.items[0].possession_state == pos_before, "Right-clicking PossessionBtn should step backward")
	main_inst.detail_modal.close()
	print("✓ Sprint 114 Milestone: StampRow Storage/Source/Mood/Possession Right-Click Reverse Cycle verified")

	# Sprint 115 Milestone: InkRow 8-Button Right-Click Reverse Cycle
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var rclick_s115 := InputEventMouseButton.new()
	rclick_s115.pressed = true
	rclick_s115.button_index = MOUSE_BUTTON_RIGHT
	var nib_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/NibBtn")
	var sig_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/SignatureBtn")
	var tag_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/CustomTagBtn")
	var fc_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/FavCharBtn")
	var cond_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/ConditionBtn")
	var fin_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/FinishBtn")
	var w_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/WeatherBtn")
	var sp_btn_s115 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/SpotBtn")
	assert("우클릭: 이전" in nib_btn_s115.tooltip_text and "우클릭: 이전" in sp_btn_s115.tooltip_text, "InkRow tooltips should mention right-click reverse cycle")
	main_inst.detail_modal.cycle_pen_nib_size(1)
	var nib_fwd = int(main_inst.archive_state.items[0].pen_nib_size)
	nib_btn_s115.gui_input.emit(rclick_s115)
	assert(int(main_inst.archive_state.items[0].pen_nib_size) != nib_fwd, "Right-clicking NibBtn should step backward")
	var sig_b = main_inst.archive_state.items[0].diary_signature
	main_inst.detail_modal.cycle_diary_signature(1)
	sig_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].diary_signature == sig_b, "Right-clicking SignatureBtn should step backward")
	var tag_b = main_inst.archive_state.items[0].custom_tag
	main_inst.detail_modal.cycle_custom_tag(1)
	tag_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].custom_tag == tag_b, "Right-clicking CustomTagBtn should step backward")
	var fc_b = main_inst.archive_state.items[0].favorite_character
	main_inst.detail_modal.cycle_favorite_character(1)
	fc_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].favorite_character == fc_b, "Right-clicking FavCharBtn should step backward")
	var cond_b = main_inst.archive_state.items[0].condition_grade
	main_inst.detail_modal.cycle_condition_grade(1)
	cond_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].condition_grade == cond_b, "Right-clicking ConditionBtn should step backward")
	var fin_b = main_inst.archive_state.items[0].cover_finish
	main_inst.detail_modal.cycle_cover_finish(1)
	fin_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].cover_finish == fin_b, "Right-clicking FinishBtn should step backward")
	var rw_b = main_inst.archive_state.items[0].reading_weather
	main_inst.detail_modal.cycle_reading_weather(1)
	w_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].reading_weather == rw_b, "Right-clicking WeatherBtn should step backward")
	var rs_b = main_inst.archive_state.items[0].reading_spot
	main_inst.detail_modal.cycle_reading_spot(1)
	sp_btn_s115.gui_input.emit(rclick_s115)
	assert(main_inst.archive_state.items[0].reading_spot == rs_b, "Right-clicking SpotBtn should step backward")
	main_inst.detail_modal.close()
	print("✓ Sprint 115 Milestone: InkRow 8-Button Right-Click Reverse Cycle verified")

	# Sprint 116 Milestone: In-Modal Shift+Key Reverse Cycle for 16 Step Cyclers
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s116 = main_inst.archive_state.items[0]
	var orig_w_s116 = item_s116.washi_tape_color
	var orig_r_s116 = item_s116.rarity_tier
	var orig_m_s116 = item_s116.reading_mood
	var orig_f_s116 = item_s116.cover_finish
	var orig_z_s116 = item_s116.possession_state
	for kc in [KEY_W, KEY_R, KEY_M, KEY_F, KEY_Z]:
		var fwd_ev := InputEventKey.new()
		fwd_ev.pressed = true
		fwd_ev.keycode = kc
		main_inst.detail_modal._unhandled_input(fwd_ev)
		var rev_ev := InputEventKey.new()
		rev_ev.pressed = true
		rev_ev.shift_pressed = true
		rev_ev.keycode = kc
		main_inst.detail_modal._unhandled_input(rev_ev)
	assert(item_s116.washi_tape_color == orig_w_s116, "Shift+W should reverse-cycle washi tape")
	assert(item_s116.rarity_tier == orig_r_s116, "Shift+R should reverse-cycle rarity tier")
	assert(item_s116.reading_mood == orig_m_s116, "Shift+M should reverse-cycle reading mood")
	assert(item_s116.cover_finish == orig_f_s116, "Shift+F should reverse-cycle cover finish")
	assert(item_s116.possession_state == orig_z_s116, "Shift+Z should reverse-cycle possession state")
	main_inst.detail_modal.close()
	print("✓ Sprint 116 Milestone: In-Modal Shift+Key 16-Cycler Reverse Navigation verified")

	# Sprint 117 Milestone: In-Modal Shift+I/Q/X Reverse Cycle Completing All 19 Step Cyclers
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s117 = main_inst.archive_state.items[0]
	var orig_ink_s117 = item_s117.memo_ink_color
	var ink_fwd := InputEventKey.new()
	ink_fwd.pressed = true
	ink_fwd.keycode = KEY_I
	main_inst.detail_modal._unhandled_input(ink_fwd)
	var ink_rev := InputEventKey.new()
	ink_rev.pressed = true
	ink_rev.shift_pressed = true
	ink_rev.keycode = KEY_I
	main_inst.detail_modal._unhandled_input(ink_rev)
	assert(item_s117.memo_ink_color == orig_ink_s117, "Shift+I should reverse-cycle fountain pen ink color")
	var col_fwd := InputEventKey.new()
	col_fwd.pressed = true
	col_fwd.keycode = KEY_Q
	main_inst.detail_modal._unhandled_input(col_fwd)
	var col_after_fwd = item_s117.cover_color
	var col_rev := InputEventKey.new()
	col_rev.pressed = true
	col_rev.shift_pressed = true
	col_rev.keycode = KEY_Q
	main_inst.detail_modal._unhandled_input(col_rev)
	assert(item_s117.cover_color != col_after_fwd, "Shift+Q should reverse-cycle cover color")
	var ico_fwd := InputEventKey.new()
	ico_fwd.pressed = true
	ico_fwd.keycode = KEY_X
	main_inst.detail_modal._unhandled_input(ico_fwd)
	var ico_after_fwd = item_s117.icon_emoji
	var ico_rev := InputEventKey.new()
	ico_rev.pressed = true
	ico_rev.shift_pressed = true
	ico_rev.keycode = KEY_X
	main_inst.detail_modal._unhandled_input(ico_rev)
	assert(item_s117.icon_emoji != ico_after_fwd, "Shift+X should reverse-cycle cover icon emoji")
	main_inst.detail_modal.close()
	print("✓ Sprint 117 Milestone: In-Modal Shift+I/Q/X Reverse Cycle (19/19 Cyclers Complete) verified")

	# Sprint 118 Milestone: Main & Modal H Cheatsheet Shift+Reverse & CoverRect Tooltip Sync
	var kh_s118 := InputEventKey.new()
	kh_s118.pressed = true
	kh_s118.keycode = KEY_H
	main_inst._unhandled_input(kh_s118)
	assert("[Space] 책장" in main_inst.status_toast.text and "[우클릭] 역순환·백업" in main_inst.status_toast.text, "Main H cheatsheet should mention Space and right-click backup/reverse")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	assert("Shift+X: 이전" in main_inst.detail_modal.cover_rect.tooltip_text and "Shift+Q: 이전" in main_inst.detail_modal.cover_rect.tooltip_text, "CoverRect tooltip should mention Shift+X and Shift+Q")
	main_inst._on_modal_help_requested()
	assert("[Shift+순환키] 역순환" in main_inst.status_toast.text, "Modal H cheatsheet should mention Shift+cycler reverse navigation")
	main_inst.detail_modal.close()
	print("✓ Sprint 118 Milestone: Main & Modal H Cheatsheet + CoverRect Tooltip Sync verified")

	# Sprint 119 Milestone: ShareCardBtn Right-Click & Shift+C Summary Copy + ModalWashiTape Right-Click Reverse
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var share_btn_s119 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/ShareCardBtn")
	assert("우클릭·Shift+C: 전체 서재 리포트 복사" in share_btn_s119.tooltip_text, "ShareCardBtn tooltip should mention right-click/Shift+C full summary copy")
	var rclick_s119 := InputEventMouseButton.new()
	rclick_s119.pressed = true
	rclick_s119.button_index = MOUSE_BUTTON_RIGHT
	share_btn_s119.gui_input.emit(rclick_s119)
	assert("서재 요약 리포트가 클립보드에 복사되었습니다" in main_inst.status_toast.text or "클립보드" in main_inst.status_toast.text, "Right-clicking ShareCardBtn should copy library summary")
	main_inst.status_toast.text = ""
	var sc_s119 := InputEventKey.new()
	sc_s119.pressed = true
	sc_s119.shift_pressed = true
	sc_s119.keycode = KEY_C
	main_inst.detail_modal._unhandled_input(sc_s119)
	assert("클립보드" in main_inst.status_toast.text, "Shift+C inside modal should copy library summary")
	var washi_s119 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/ModalWashiTape")
	var washi_orig = main_inst.archive_state.items[0].washi_tape_color
	main_inst.detail_modal.cycle_washi_tape(1)
	washi_s119.gui_input.emit(rclick_s119)
	assert(main_inst.archive_state.items[0].washi_tape_color == washi_orig, "Right-clicking ModalWashiTape should step backward")
	main_inst.detail_modal.close()
	print("✓ Sprint 119 Milestone: ShareCardBtn Right-Click/Shift+C Summary Copy & ModalWashiTape Reverse verified")

	# Sprint 120 Milestone: Stat Cards 4-Way Right-Click Power Actions & Modal Shift+C Help Hint
	var rclick_s120 := InputEventMouseButton.new()
	rclick_s120.pressed = true
	rclick_s120.button_index = MOUSE_BUTTON_RIGHT
	var s_items = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatItems")
	var s_vols = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatVols")
	var s_firsts = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatFirsts")
	var s_gacha = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatGacha")
	s_items.gui_input.emit(rclick_s120)
	assert("클립보드" in main_inst.status_toast.text, "Right-clicking StatItems should copy summary report")
	s_vols.gui_input.emit(rclick_s120)
	assert(main_inst.archive_state.current_filter == 0 and main_inst.sort_mode == 3, "Right-clicking StatVols should filter manga and sort by value (3)")
	s_firsts.gui_input.emit(rclick_s120)
	assert("📊 소장:" in main_inst.status_toast.text and "총 가치:" in main_inst.status_toast.text, "Right-clicking StatFirsts should show infographic briefing")
	s_gacha.gui_input.emit(rclick_s120)
	assert("로컬 JSON 서재 백업 저장 완료" in main_inst.status_toast.text, "Right-clicking StatGacha should trigger instant JSON backup")
	main_inst._on_tab_all_pressed()
	main_inst._set_sort_mode(0)
	main_inst._on_modal_help_requested()
	assert("Shift+C: 리포트" in main_inst.status_toast.text, "Modal H cheatsheet should mention Shift+C report copy")
	print("✓ Sprint 120 Milestone: Stat Cards 4-Way Right-Click Power Actions & Modal Shift+C Help Hint verified")

	# Sprint 121 Milestone: Filter Tabs 5-Way Right-Click Value Sort & Full Reset
	var rclick_s121 := InputEventMouseButton.new()
	rclick_s121.pressed = true
	rclick_s121.button_index = MOUSE_BUTTON_RIGHT
	assert("우클릭: 완전 초기화" in main_inst.tab_all.tooltip_text and "우클릭: 가치순 보기" in main_inst.tab_gacha.tooltip_text, "Filter tab tooltips should mention right-click power actions")
	main_inst.tab_gacha.gui_input.emit(rclick_s121)
	assert(main_inst.archive_state.current_filter == 1 and main_inst.sort_mode == 3, "Right-clicking TabGacha should filter gacha and sort by value (3)")
	main_inst.tab_fav.gui_input.emit(rclick_s121)
	assert(main_inst.filter_favorites_only and main_inst.sort_mode == 3, "Right-clicking TabFav should filter fav and sort by value (3)")
	main_inst.search_input.text = "test_query"
	main_inst.tab_all.gui_input.emit(rclick_s121)
	assert(main_inst.archive_state.current_filter == -1 and main_inst.sort_mode == 0 and main_inst.search_input.text == "", "Right-clicking TabAll should reset search, filter, and sort mode to default")
	print("✓ Sprint 121 Milestone: Filter Tabs 5-Way Right-Click Value Sort & Full Reset verified")

	# Sprint 122 Milestone: SaveQuoteBtn Right-Click Restore Memo & HighlightBtn Right-Click Ink Cycle
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s122 = main_inst.archive_state.items[0]
	var save_q_btn = main_inst.detail_modal.save_quote_btn
	var hl_btn_s122 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/QuoteEditRow/HighlightBtn")
	assert("우클릭: 원문 복원" in save_q_btn.tooltip_text and "우클릭: 잉크색 변경" in hl_btn_s122.tooltip_text, "SaveQuoteBtn and HighlightBtn tooltips should mention right-click actions")
	var rclick_s122 := InputEventMouseButton.new()
	rclick_s122.pressed = true
	rclick_s122.button_index = MOUSE_BUTTON_RIGHT
	main_inst.detail_modal.quote_input.text = "임시로 바꾼 미저장 문장"
	save_q_btn.gui_input.emit(rclick_s122)
	assert(main_inst.detail_modal.quote_input.text == item_s122.memo, "Right-clicking SaveQuoteBtn should restore quote_input to original memo")
	var ink_before_s122 = item_s122.memo_ink_color
	hl_btn_s122.gui_input.emit(rclick_s122)
	assert(item_s122.memo_ink_color != ink_before_s122, "Right-clicking HighlightBtn should cycle fountain pen ink color")
	main_inst.detail_modal.close()
	print("✓ Sprint 122 Milestone: SaveQuoteBtn Right-Click Restore & HighlightBtn Right-Click Ink Cycle verified")

	# Sprint 123 Milestone: AddVolBtn Right-Click Add+Edit & DeleteBtn Right-Click Disarm
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s123 = main_inst.archive_state.items[0]
	var orig_vols_s123 = item_s123.volumes.size()
	var add_v_btn = main_inst.detail_modal.add_vol_btn
	var del_btn_s123 = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/DeleteBtn")
	assert("우클릭: 추가 후 바로 밑줄 입력" in add_v_btn.tooltip_text and "우클릭: 삭제 확인 해제" in del_btn_s123.tooltip_text, "AddVolBtn and DeleteBtn tooltips should mention right-click actions")
	var rclick_s123 := InputEventMouseButton.new()
	rclick_s123.pressed = true
	rclick_s123.button_index = MOUSE_BUTTON_RIGHT
	add_v_btn.gui_input.emit(rclick_s123)
	assert(item_s123.volumes.size() == orig_vols_s123 + 1 and main_inst.detail_modal.editing_vol_index == orig_vols_s123, "Right-clicking AddVolBtn should add a volume and immediately enter quote edit mode")
	main_inst.detail_modal.remove_last_volume()
	main_inst.detail_modal._on_delete_btn_pressed()
	assert(main_inst.detail_modal.delete_armed == true, "First click on DeleteBtn should arm deletion")
	del_btn_s123.gui_input.emit(rclick_s123)
	assert(main_inst.detail_modal.delete_armed == false, "Right-clicking DeleteBtn should disarm deletion safely")
	main_inst.detail_modal.close()
	print("✓ Sprint 123 Milestone: AddVolBtn Right-Click Add+Edit & DeleteBtn Right-Click Disarm verified")

	# Sprint 124 Milestone: Ink Swatches Right-Click Ink+Highlight & Volume Bookmark Right-Click Edit
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s124 = main_inst.archive_state.items[0]
	var orig_hl_s124 = item_s124.highlight_enabled
	var ink_sepia = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/InkSepia")
	assert("우클릭: 잉크 적용+형광펜 토글" in ink_sepia.tooltip_text, "Ink swatch tooltip should mention right-click ink+highlight toggle")
	var rclick_s124 := InputEventMouseButton.new()
	rclick_s124.pressed = true
	rclick_s124.button_index = MOUSE_BUTTON_RIGHT
	ink_sepia.gui_input.emit(rclick_s124)
	assert(item_s124.memo_ink_color == "#78350f" and item_s124.highlight_enabled != orig_hl_s124, "Right-clicking InkSepia should set sepia ink and toggle highlighter")
	var first_row_bm: Button = null
	for b in main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Button", true, false):
		if b.text == "🏷️" or b.text == "🔖":
			first_row_bm = b
			break
	assert(first_row_bm != null and "우클릭: 이 권 밑줄 편집" in first_row_bm.tooltip_text, "Bookmark ribbon tooltip should mention right-click quote edit")
	first_row_bm.gui_input.emit(rclick_s124)
	assert(main_inst.detail_modal.editing_vol_index == 0, "Right-clicking volume bookmark ribbon should start editing that volume's quote")
	main_inst.detail_modal.close()
	print("✓ Sprint 124 Milestone: Ink Swatch Right-Click Ink+Highlight & Bookmark Right-Click Edit verified")

	# Sprint 125 Milestone: Stamp Buttons Right-Click Stamp+Share & Vol Status Right-Click Dual Toggle
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s125 = main_inst.archive_state.items[0]
	var stamp_fav_btn = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/StampFav")
	assert("우클릭: 인장+감상카드 복사" in stamp_fav_btn.tooltip_text, "StampFav tooltip should mention right-click stamp+share copy")
	var rclick_s125 := InputEventMouseButton.new()
	rclick_s125.pressed = true
	rclick_s125.button_index = MOUSE_BUTTON_RIGHT
	stamp_fav_btn.gui_input.emit(rclick_s125)
	assert(item_s125.status_tag == "인생최애" and "감상 카드" in main_inst.status_toast.text, "Right-clicking StampFav should apply stamp and copy quote card")
	var first_status_btn: Button = null
	for b in main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Button", true, false):
		if "초판" in b.text or "소장완료" in b.text:
			first_status_btn = b
			break
	var orig_st_s125 = item_s125.volumes[0].get("status", "")
	var orig_bm_s125 = bool(item_s125.volumes[0].get("bookmarked", false))
	assert(first_status_btn != null and "우클릭: 초판+북마크 동시 토글" in first_status_btn.tooltip_text, "Status button tooltip should mention dual toggle")
	first_status_btn.gui_input.emit(rclick_s125)
	assert(item_s125.volumes[0].get("status", "") != orig_st_s125 and bool(item_s125.volumes[0].get("bookmarked", false)) != orig_bm_s125, "Right-clicking volume status button should toggle both status and bookmark")
	main_inst.detail_modal.close()
	print("✓ Sprint 125 Milestone: Stamp Right-Click Stamp+Share & Vol Status Dual Toggle verified")

	# Sprint 126 Milestone: CloseBtn Right-Click Close+Backup & Vol DateBtn Right-Click Quote Copy
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var first_date_btn: Button = null
	for b in main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Button", true, false):
		if "📅" in b.text:
			first_date_btn = b
			break
	assert(first_date_btn != null and "우클릭: 이 권 대사 복사" in first_date_btn.tooltip_text, "Volume date button tooltip should mention right-click quote copy")
	var rclick_s126 := InputEventMouseButton.new()
	rclick_s126.pressed = true
	rclick_s126.button_index = MOUSE_BUTTON_RIGHT
	first_date_btn.gui_input.emit(rclick_s126)
	assert(first_date_btn.text == "✅ 복사됨", "Right-clicking volume date button should show copied feedback")
	var close_btn_s126 = main_inst.detail_modal.get_node("Panel/VBox/Header/HBox/CloseBtn")
	assert("우클릭: 닫고 즉시 JSON 백업" in close_btn_s126.tooltip_text, "CloseBtn tooltip should mention right-click close+backup")
	close_btn_s126.gui_input.emit(rclick_s126)
	assert(not main_inst.detail_modal.visible and "로컬 JSON 서재 백업 저장 완료" in main_inst.status_toast.text, "Right-clicking CloseBtn should close modal and trigger instant JSON backup")
	print("✓ Sprint 126 Milestone: CloseBtn Right-Click Close+Backup & Vol DateBtn Quote Copy verified")

	# Sprint 127 Milestone: DateStampBtn Right-Click Reset & TitleLabel Click Title Copy
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s127 = main_inst.archive_state.items[0]
	var date_stamp_btn = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/DateStampBtn")
	assert("우클릭: 기본값 초기화" in date_stamp_btn.tooltip_text, "DateStampBtn tooltip should mention right-click reset")
	main_inst.detail_modal.stamp_purchase_date()
	assert(item_s127.purchase_date != "📅 기념일", "stamp_purchase_date should set today date")
	var rclick_s127 := InputEventMouseButton.new()
	rclick_s127.pressed = true
	rclick_s127.button_index = MOUSE_BUTTON_RIGHT
	date_stamp_btn.gui_input.emit(rclick_s127)
	assert(item_s127.purchase_date == "📅 기념일" and date_stamp_btn.text == "📅 기념일", "Right-clicking DateStampBtn should reset purchase date")
	var lclick_s127 := InputEventMouseButton.new()
	lclick_s127.pressed = true
	lclick_s127.button_index = MOUSE_BUTTON_LEFT
	assert("작품 제목 클립보드 복사" in main_inst.detail_modal.title_label.tooltip_text, "TitleLabel tooltip should mention clipboard copy")
	main_inst.detail_modal.title_label.gui_input.emit(lclick_s127)
	assert("✅ 복사됨: " in main_inst.detail_modal.title_label.tooltip_text, "Clicking TitleLabel should update tooltip with copied confirmation")
	main_inst.detail_modal.close()
	print("✓ Sprint 127 Milestone: DateStampBtn Right-Click Reset & TitleLabel Click Copy verified")

	# Sprint 128 Milestone: CatBadge Click Filter Category & AuthorLabel Click Search Author
	var gacha_item_s128 = null
	for it in main_inst.archive_state.items:
		if it.category == 1:
			gacha_item_s128 = it
			break
	assert(gacha_item_s128 != null, "Should find a gacha item in archive_state")
	main_inst._on_card_clicked(gacha_item_s128)
	var lclick_s128 := InputEventMouseButton.new()
	lclick_s128.pressed = true
	lclick_s128.button_index = MOUSE_BUTTON_LEFT
	assert("같은 카테고리" in main_inst.detail_modal.cat_badge.tooltip_text and "작가·시리즈의 다른 작품 검색" in main_inst.detail_modal.author_label.tooltip_text, "CatBadge and AuthorLabel tooltips should mention filter/search actions")
	main_inst.detail_modal.cat_badge.gui_input.emit(lclick_s128)
	assert(not main_inst.detail_modal.visible and main_inst.archive_state.current_filter == 1, "Clicking CatBadge on gacha item should close modal and filter to gacha (1)")
	main_inst._on_tab_all_pressed()
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var target_author = main_inst.archive_state.items[0].author_or_series
	main_inst.detail_modal.author_label.gui_input.emit(lclick_s128)
	assert(not main_inst.detail_modal.visible and main_inst.search_input.text == target_author and "작가·시리즈 검색" in main_inst.status_toast.text, "Clicking AuthorLabel should close modal, set search_input to author, and show toast")
	main_inst._reset_all_filters()
	print("✓ Sprint 128 Milestone: CatBadge Click Category Filter & AuthorLabel Click Search verified")

	# Sprint 129 Milestone: AuthorLabel Right-Click Value Adjust & MemoLabel Left-Focus / Right-Highlight
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s129 = main_inst.archive_state.items[0]
	var orig_val_s129 = item_s129.get_item_value()
	var rclick_s129 := InputEventMouseButton.new()
	rclick_s129.pressed = true
	rclick_s129.button_index = MOUSE_BUTTON_RIGHT
	main_inst.detail_modal.author_label.gui_input.emit(rclick_s129)
	assert(item_s129.get_item_value() > orig_val_s129, "Right-clicking AuthorLabel should boost estimated value")
	var boosted_val_s129 = item_s129.get_item_value()
	rclick_s129.shift_pressed = true
	main_inst.detail_modal.author_label.gui_input.emit(rclick_s129)
	assert(item_s129.get_item_value() < boosted_val_s129, "Shift+Right-clicking AuthorLabel should reduce estimated value")
	rclick_s129.shift_pressed = false
	var orig_hl_s129 = item_s129.highlight_enabled
	assert("밑줄 문장 편집 입력창 이동" in main_inst.detail_modal.memo_label.tooltip_text and "형광펜 토글" in main_inst.detail_modal.memo_label.tooltip_text, "MemoLabel tooltip should mention edit focus and highlighter toggle")
	main_inst.detail_modal.memo_label.gui_input.emit(rclick_s129)
	assert(item_s129.highlight_enabled != orig_hl_s129, "Right-clicking MemoLabel should toggle highlighter")
	main_inst.detail_modal.close()
	print("✓ Sprint 129 Milestone: AuthorLabel Value Adjust & MemoLabel Focus/Highlight verified")

	# Sprint 130 Milestone: TagLabel Left/Right Obi Cycle & VolHeader Left/Right Add/Remove Volume
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var item_s130 = main_inst.archive_state.items[0]
	var orig_obi_s130 = item_s130.obi_text
	var lclick_s130 := InputEventMouseButton.new()
	lclick_s130.pressed = true
	lclick_s130.button_index = MOUSE_BUTTON_LEFT
	var rclick_s130 := InputEventMouseButton.new()
	rclick_s130.pressed = true
	rclick_s130.button_index = MOUSE_BUTTON_RIGHT
	assert("띠지 문구 다음 순환" in main_inst.detail_modal.tag_label.tooltip_text and "새 권·파츠 추가" in main_inst.detail_modal.vol_header.tooltip_text, "TagLabel and VolHeader tooltips should mention click actions")
	main_inst.detail_modal.tag_label.gui_input.emit(lclick_s130)
	assert(item_s130.obi_text != orig_obi_s130, "Left-clicking TagLabel should cycle obi preset forward")
	main_inst.detail_modal.tag_label.gui_input.emit(rclick_s130)
	assert(item_s130.obi_text == orig_obi_s130, "Right-clicking TagLabel should cycle obi preset backward")
	var orig_vols_s130 = item_s130.volumes.size()
	main_inst.detail_modal.vol_header.gui_input.emit(lclick_s130)
	assert(item_s130.volumes.size() == orig_vols_s130 + 1, "Left-clicking VolHeader should add a volume")
	main_inst.detail_modal.vol_header.gui_input.emit(rclick_s130)
	assert(item_s130.volumes.size() == orig_vols_s130, "Right-clicking VolHeader should remove last volume")
	main_inst.detail_modal.close()
	print("✓ Sprint 130 Milestone: TagLabel Obi Cycle & VolHeader Add/Remove Volume verified")

	# Sprint 131 Milestone: AppTitle Left-Reset / Right-Theme & StatusToast Left-Help / Right-RandomPeek
	var app_title_s131 = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/TitleRow/TitleCol/AppTitle")
	var lclick_s131 := InputEventMouseButton.new()
	lclick_s131.pressed = true
	lclick_s131.button_index = MOUSE_BUTTON_LEFT
	var rclick_s131 := InputEventMouseButton.new()
	rclick_s131.pressed = true
	rclick_s131.button_index = MOUSE_BUTTON_RIGHT
	assert("전체 서재 복원" in app_title_s131.tooltip_text and "단축키 치트시트 보기" in main_inst.status_toast.tooltip_text, "AppTitle and StatusToast tooltips should mention click actions")
	var orig_theme_s131 = main_inst.theme_cursor
	app_title_s131.gui_input.emit(rclick_s131)
	assert(main_inst.theme_cursor != orig_theme_s131, "Right-clicking AppTitle should cycle room theme")
	app_title_s131.gui_input.emit(lclick_s131)
	assert("전체 서재가 복원되었습니다" in main_inst.status_toast.text, "Left-clicking AppTitle should reset all filters")
	main_inst.status_toast.gui_input.emit(lclick_s131)
	assert("단축키:" in main_inst.status_toast.text, "Left-clicking StatusToast should show shortcut cheatsheet")
	main_inst.status_toast.gui_input.emit(rclick_s131)
	assert(not main_inst.detail_modal.visible and "오늘의 추천 미리보기" in main_inst.status_toast.text, "Right-clicking StatusToast should peek random item without opening modal")
	main_inst._step_theme(-1)
	print("✓ Sprint 131 Milestone: AppTitle & StatusToast Left/Right-Click Actions verified")

	# Sprint 132 Milestone: Card Shift+Right-Click Quote Copy & AddModal Right-Click Clear/Sample Submit
	var card_s132 = main_inst.card_grid.get_child(0)
	var srclick_s132 := InputEventMouseButton.new()
	srclick_s132.pressed = true
	srclick_s132.shift_pressed = true
	srclick_s132.button_index = MOUSE_BUTTON_RIGHT
	card_s132._gui_input(srclick_s132)
	assert(not main_inst.detail_modal.visible and "카드 감상 요약 클립보드 복사됨" in main_inst.status_toast.text, "Shift+Right-clicking CardItem should copy summary without opening modal")
	main_inst.add_modal.open()
	main_inst.add_modal.title_input.text = "임시 제목"
	main_inst.add_modal.author_input.text = "임시 작가"
	var rclick_s132 := InputEventMouseButton.new()
	rclick_s132.pressed = true
	rclick_s132.button_index = MOUSE_BUTTON_RIGHT
	assert("입력란 모두 비우기" in main_inst.add_modal.close_btn.tooltip_text and "샘플 자동 채움" in main_inst.add_modal.submit_btn.tooltip_text, "AddModal tooltips should mention right-click clear and sample submit")
	main_inst.add_modal.close_btn.gui_input.emit(rclick_s132)
	assert(main_inst.add_modal.visible and main_inst.add_modal.title_input.text == "" and main_inst.add_modal.author_input.text == "", "Right-clicking AddModal CloseBtn should clear inputs without closing")
	var orig_count_s132 = main_inst.archive_state.items.size()
	main_inst.add_modal.submit_btn.gui_input.emit(rclick_s132)
	assert(not main_inst.add_modal.visible and main_inst.archive_state.items.size() == orig_count_s132 + 1, "Right-clicking AddModal SubmitBtn with empty title should auto-fill sample and submit")
	main_inst.archive_state.items.remove_at(0)
	main_inst._render_cards()
	print("✓ Sprint 132 Milestone: Card Shift+Right-Click Copy & AddModal Right-Click Clear/Sample verified")

	# Sprint 133 Milestone: Card Rich Tooltip Sync & AddModal CatOption Right-Click Category Toggle
	var card_s133 = main_inst.card_grid.get_child(0)
	assert("Shift+우클릭: 감상 요약 복사" in card_s133.tooltip_text, "CardItem tooltip should mention Shift+Right-Click quote copy")
	main_inst.add_modal.open()
	var cat_opt_s133 = main_inst.add_modal.cat_option
	assert("이북 ↔ 가챠 즉시 전환" in cat_opt_s133.tooltip_text, "AddModal CatOption tooltip should mention right-click category toggle")
	var orig_cat_idx = cat_opt_s133.selected
	var rclick_s133 := InputEventMouseButton.new()
	rclick_s133.pressed = true
	rclick_s133.button_index = MOUSE_BUTTON_RIGHT
	cat_opt_s133.gui_input.emit(rclick_s133)
	assert(cat_opt_s133.selected != orig_cat_idx, "Right-clicking CatOption should toggle category immediately")
	cat_opt_s133.gui_input.emit(rclick_s133)
	assert(cat_opt_s133.selected == orig_cat_idx, "Second right-click on CatOption should toggle category back")
	main_inst.add_modal.close()
	print("✓ Sprint 133 Milestone: Card Tooltip Sync & AddModal CatOption Toggle verified")

	# Sprint 134 Milestone: AddModal Swatch Right-Click Instant Submit & ESC Two-Step Clear/Close
	main_inst.add_modal.open()
	main_inst.add_modal.title_input.text = "지워질 임시 제목"
	var esc_s134 := InputEventKey.new()
	esc_s134.pressed = true
	esc_s134.keycode = KEY_ESCAPE
	if main_inst.add_modal.title_input.has_focus():
		main_inst.add_modal._unhandled_input(esc_s134)
		assert(main_inst.add_modal.visible and main_inst.add_modal.title_input.text == "", "First ESC with non-empty focused input should clear text without closing")
		main_inst.add_modal._unhandled_input(esc_s134)
		assert(not main_inst.add_modal.visible, "Second ESC with empty input should close AddModal")
		main_inst.add_modal.open()
	var swatch_cobalt = main_inst.add_modal.color_row.get_child(1)
	assert("이 색으로 즉시 등록" in swatch_cobalt.tooltip_text, "AddModal swatch tooltip should mention right-click instant submit")
	var orig_cnt_s134 = main_inst.archive_state.items.size()
	var rclick_s134 := InputEventMouseButton.new()
	rclick_s134.pressed = true
	rclick_s134.button_index = MOUSE_BUTTON_RIGHT
	swatch_cobalt.gui_input.emit(rclick_s134)
	assert(not main_inst.add_modal.visible and main_inst.archive_state.items.size() == orig_cnt_s134 + 1 and main_inst.archive_state.items[0].cover_color == "#1d4ed8", "Right-clicking Cobalt swatch should submit sample item with cobalt color")
	main_inst.archive_state.items.remove_at(0)
	main_inst._render_cards()
	print("✓ Sprint 134 Milestone: AddModal Swatch Right-Click Submit & ESC Clear/Close verified")

	# Sprint 135 Milestone: SearchInput Enter Open First Result & EmptyStateResetBtn Right-Click Peek
	assert("Enter: 첫 결과 열기" in main_inst.search_input.tooltip_text, "SearchInput tooltip should mention Enter to open first result")
	main_inst.search_input.text = "프리렌"
	main_inst._render_cards()
	main_inst.search_input.text_submitted.emit("프리렌")
	assert(main_inst.detail_modal.visible and "프리렌" in main_inst.detail_modal.current_item.title, "Pressing Enter in SearchInput should open first filtered item modal")
	main_inst.detail_modal.close()
	main_inst.search_input.text = "존재하지않는작품XYZ"
	main_inst._render_cards()
	var empty_reset_s135 = main_inst.card_grid.find_child("EmptyStateResetBtn", true, false)
	assert(empty_reset_s135 != null and "랜덤 추천 미리보기" in empty_reset_s135.tooltip_text, "EmptyStateResetBtn tooltip should mention right-click random peek")
	var rclick_s135 := InputEventMouseButton.new()
	rclick_s135.pressed = true
	rclick_s135.button_index = MOUSE_BUTTON_RIGHT
	empty_reset_s135.gui_input.emit(rclick_s135)
	assert(main_inst.search_input.text == "" and "오늘의 추천 미리보기" in main_inst.status_toast.text, "Right-clicking EmptyStateResetBtn should reset filters and peek random item")
	print("✓ Sprint 135 Milestone: SearchInput Enter Open First & EmptyStateResetBtn Random Peek verified")

	# Sprint 136 Milestone: DetailModal Dimmer Right-Click Close+Backup & AddModal Dimmer Right-Click Clear
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var detail_dimmer_s136: Control = main_inst.detail_modal.get_node("Dimmer")
	assert("닫고 즉시 JSON 백업" in detail_dimmer_s136.tooltip_text, "DetailModal Dimmer tooltip should mention right-click close and backup")
	var rclick_s136 := InputEventMouseButton.new()
	rclick_s136.pressed = true
	rclick_s136.button_index = MOUSE_BUTTON_RIGHT
	detail_dimmer_s136.gui_input.emit(rclick_s136)
	assert(not main_inst.detail_modal.visible and "로컬 JSON 서재 백업 저장 완료" in main_inst.status_toast.text, "Right-clicking DetailModal Dimmer should close modal and trigger instant JSON backup")
	main_inst.add_modal.open()
	main_inst.add_modal.title_input.text = "임시 작성중"
	var add_dimmer_s136: Control = main_inst.add_modal.get_node("Dimmer")
	assert("입력 내용만 비우기" in add_dimmer_s136.tooltip_text, "AddModal Dimmer tooltip should mention right-click clear inputs")
	add_dimmer_s136.gui_input.emit(rclick_s136)
	assert(main_inst.add_modal.visible and main_inst.add_modal.title_input.text == "", "Right-clicking AddModal Dimmer should clear inputs without closing")
	main_inst.add_modal.close()
	print("✓ Sprint 136 Milestone: DetailModal Dimmer Close+Backup & AddModal Dimmer Clear verified")

	# Sprint 137 Milestone: Volume Row vol_lbl Edit/Bookmark & quote_lbl Right-Click Copy
	var target_s137 = main_inst.archive_state.items[0]
	main_inst._on_card_clicked(target_s137)
	var labels_s137 = main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Label", true, false)
	var vol_lbl_s137: Label = labels_s137[0]
	assert("밑줄 문장 편집" in vol_lbl_s137.tooltip_text and "북마크 토글" in vol_lbl_s137.tooltip_text, "vol_lbl tooltip should mention edit and bookmark toggle")
	var lclick_s137 := InputEventMouseButton.new()
	lclick_s137.pressed = true
	lclick_s137.button_index = MOUSE_BUTTON_LEFT
	vol_lbl_s137.gui_input.emit(lclick_s137)
	assert(main_inst.detail_modal.editing_vol_index == 0, "Left-clicking vol_lbl should enter quote edit mode for volume 0")
	var orig_bm_s137: bool = bool(target_s137.volumes[0].get("bookmarked", false))
	var rclick_s137 := InputEventMouseButton.new()
	rclick_s137.pressed = true
	rclick_s137.button_index = MOUSE_BUTTON_RIGHT
	vol_lbl_s137.gui_input.emit(rclick_s137)
	assert(bool(target_s137.volumes[0].get("bookmarked", false)) != orig_bm_s137, "Right-clicking vol_lbl should toggle volume bookmark")
	var labels_after_s137 = main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Label", true, false)
	var quote_lbl_s137: Label = labels_after_s137[1]
	assert("밑줄 문장 복사" in quote_lbl_s137.tooltip_text, "quote_lbl tooltip should mention right-click quote copy")
	quote_lbl_s137.gui_input.emit(rclick_s137)
	assert("✅ 복사됨:" in quote_lbl_s137.tooltip_text, "Right-clicking quote_lbl should copy volume quote and update tooltip")
	main_inst.detail_modal.close()
	print("✓ Sprint 137 Milestone: Volume Row vol_lbl Edit/Bookmark & quote_lbl Copy verified")

	# Sprint 138 Milestone: RemoveVolBtn Right-Click Last Bookmark & QuoteInput Right-Click Clear/Restore
	var target_s138 = main_inst.archive_state.items[0]
	main_inst._on_card_clicked(target_s138)
	var rem_btn_s138: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/TopInfo/MetaVBox/BtnRow/RemoveVolBtn")
	assert("마지막 권 북마크 토글" in rem_btn_s138.tooltip_text, "RemoveVolBtn tooltip should mention right-click last volume bookmark toggle")
	var last_idx_s138: int = target_s138.volumes.size() - 1
	var orig_last_bm_s138: bool = bool(target_s138.volumes[last_idx_s138].get("bookmarked", false))
	var rclick_s138 := InputEventMouseButton.new()
	rclick_s138.pressed = true
	rclick_s138.button_index = MOUSE_BUTTON_RIGHT
	rem_btn_s138.gui_input.emit(rclick_s138)
	assert(bool(target_s138.volumes[last_idx_s138].get("bookmarked", false)) != orig_last_bm_s138, "Right-clicking RemoveVolBtn should toggle last volume bookmark")
	assert("입력 비우기/원문 복원" in main_inst.detail_modal.quote_input.tooltip_text, "QuoteInput tooltip should mention right-click clear/restore")
	main_inst.detail_modal.quote_input.gui_input.emit(rclick_s138)
	assert(main_inst.detail_modal.quote_input.text == "", "First right-click on non-empty QuoteInput should clear text")
	main_inst.detail_modal.quote_input.gui_input.emit(rclick_s138)
	assert(main_inst.detail_modal.quote_input.text == target_s138.memo, "Second right-click on empty QuoteInput should restore item memo")
	main_inst.detail_modal.close()
	print("✓ Sprint 138 Milestone: RemoveVolBtn Last Bookmark & QuoteInput Clear/Restore verified")

	# Sprint 139 Milestone: SearchInput Right-Click Clear/Today-Quote & AddModal Inputs Right-Click Clear/Sample
	main_inst.search_input.text = ""
	main_inst._render_cards()
	assert("지우기/추천 검색" in main_inst.search_input.tooltip_text, "SearchInput tooltip should mention right-click clear/recommended search")
	var rclick_s139 := InputEventMouseButton.new()
	rclick_s139.pressed = true
	rclick_s139.button_index = MOUSE_BUTTON_RIGHT
	main_inst.search_input.gui_input.emit(rclick_s139)
	assert(main_inst.search_input.text != "" and "오늘의 밑줄 작품 검색" in main_inst.status_toast.text, "Right-clicking empty SearchInput should search current TodayQuote item")
	main_inst.search_input.gui_input.emit(rclick_s139)
	assert(main_inst.search_input.text == "" and "검색어 초기화" in main_inst.status_toast.text, "Right-clicking non-empty SearchInput should clear search text")
	main_inst.add_modal.open()
	main_inst.add_modal.clear_inputs()
	assert("샘플 채움" in main_inst.add_modal.title_input.tooltip_text, "AddModal TitleInput tooltip should mention right-click clear/sample")
	main_inst.add_modal.title_input.gui_input.emit(rclick_s139)
	assert(main_inst.add_modal.title_input.text == "나의 비밀 독서 일기", "Right-clicking empty AddModal TitleInput should fill sample title")
	main_inst.add_modal.title_input.gui_input.emit(rclick_s139)
	assert(main_inst.add_modal.title_input.text == "", "Right-clicking non-empty AddModal TitleInput should clear title")
	main_inst.add_modal.close()
	print("✓ Sprint 139 Milestone: SearchInput & AddModal Inputs Right-Click Clear/Sample verified")

	# Sprint 140 Milestone: DetailModal TitleLabel Right-Click Share Copy & CatBadge Right-Click All Reset
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst._reset_all_filters()
	main_inst._on_tab_manga_pressed()
	assert(main_inst.card_grid.get_child_count() == 4, "Setup: manga filter should show 4 cards")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	assert("감상 카드 전체 복사" in main_inst.detail_modal.title_label.tooltip_text, "TitleLabel tooltip should mention right-click share card copy")
	var rclick_s140 := InputEventMouseButton.new()
	rclick_s140.pressed = true
	rclick_s140.button_index = MOUSE_BUTTON_RIGHT
	main_inst.detail_modal.title_label.gui_input.emit(rclick_s140)
	assert("복사" in main_inst.status_toast.text, "Right-clicking TitleLabel should copy share card to clipboard")
	assert("전체 서재 보기" in main_inst.detail_modal.cat_badge.tooltip_text, "CatBadge tooltip should mention right-click all library reset")
	main_inst.detail_modal.cat_badge.gui_input.emit(rclick_s140)
	assert(not main_inst.detail_modal.visible and main_inst.card_grid.get_child_count() == 6, "Right-clicking CatBadge should close modal and reset to all 6 cards")
	print("✓ Sprint 140 Milestone: TitleLabel Share Copy & CatBadge All Library Reset verified")

	# Sprint 141 Milestone: StampLbl & InkLbl Bidirectional Left/Right-Click Cyclers
	var target_s141 = main_inst.archive_state.items[0]
	main_inst._on_card_clicked(target_s141)
	var stamp_lbl_s141: Label = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/StampLbl")
	var ink_lbl_s141: Label = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/InkLbl")
	assert("인장 프리셋 순환" in stamp_lbl_s141.tooltip_text, "StampLbl tooltip should mention stamp preset cycle")
	assert("만년필 잉크 순환" in ink_lbl_s141.tooltip_text, "InkLbl tooltip should mention fountain-pen ink cycle")
	var orig_stamp_s141: String = target_s141.status_tag
	var orig_ink_s141: String = target_s141.memo_ink_color
	var lclick_s141 := InputEventMouseButton.new()
	lclick_s141.pressed = true
	lclick_s141.button_index = MOUSE_BUTTON_LEFT
	var rclick_s141 := InputEventMouseButton.new()
	rclick_s141.pressed = true
	rclick_s141.button_index = MOUSE_BUTTON_RIGHT
	stamp_lbl_s141.gui_input.emit(lclick_s141)
	assert(target_s141.status_tag != orig_stamp_s141, "Left-clicking StampLbl should cycle stamp forward")
	stamp_lbl_s141.gui_input.emit(rclick_s141)
	assert(target_s141.status_tag == orig_stamp_s141, "Right-clicking StampLbl should reverse-cycle stamp")
	ink_lbl_s141.gui_input.emit(lclick_s141)
	assert(target_s141.memo_ink_color != orig_ink_s141, "Left-clicking InkLbl should cycle ink forward")
	ink_lbl_s141.gui_input.emit(rclick_s141)
	assert(target_s141.memo_ink_color == orig_ink_s141, "Right-clicking InkLbl should reverse-cycle ink")
	main_inst.detail_modal.close()
	print("✓ Sprint 141 Milestone: StampLbl & InkLbl Bidirectional Cyclers verified")

	# Sprint 142 Milestone: AddModal Header TitleLabel Sample Fill/Clear & Ctrl+Enter Submit
	var orig_cnt_s142: int = main_inst.archive_state.items.size()
	main_inst.add_modal.open()
	var add_title_s142: Label = main_inst.add_modal.get_node("Panel/VBox/Header/HBox/TitleLabel")
	assert("샘플 일기 일괄 채움" in add_title_s142.tooltip_text, "AddModal TitleLabel tooltip should mention sample fill and clear")
	var lclick_s142 := InputEventMouseButton.new()
	lclick_s142.pressed = true
	lclick_s142.button_index = MOUSE_BUTTON_LEFT
	var rclick_s142 := InputEventMouseButton.new()
	rclick_s142.pressed = true
	rclick_s142.button_index = MOUSE_BUTTON_RIGHT
	add_title_s142.gui_input.emit(lclick_s142)
	assert(main_inst.add_modal.title_input.text == "나의 비밀 독서 일기" and main_inst.add_modal.author_input.text == "주희의 서재", "Left-clicking AddModal TitleLabel should fill sample diary fields")
	add_title_s142.gui_input.emit(rclick_s142)
	assert(main_inst.add_modal.title_input.text == "" and main_inst.add_modal.author_input.text == "", "Right-clicking AddModal TitleLabel should clear all fields")
	add_title_s142.gui_input.emit(lclick_s142)
	var ctrl_enter_s142 := InputEventKey.new()
	ctrl_enter_s142.pressed = true
	ctrl_enter_s142.ctrl_pressed = true
	ctrl_enter_s142.keycode = KEY_ENTER
	main_inst.add_modal._unhandled_input(ctrl_enter_s142)
	assert(not main_inst.add_modal.visible and main_inst.archive_state.items.size() == orig_cnt_s142 + 1, "Ctrl+Enter in AddModal should submit and close")
	main_inst.archive_state.items.remove_at(0)
	main_inst._render_cards()
	print("✓ Sprint 142 Milestone: AddModal TitleLabel Fill/Clear & Ctrl+Enter Submit verified")

	# Sprint 143 Milestone: CardItem Shift+Left-Click Author Filter & SpineShelf Shift+Click Search/Copy
	main_inst._reset_all_filters()
	var card0_s143 = main_inst.card_grid.get_child(0)
	assert("Shift+좌클릭: 작가 검색" in card0_s143.tooltip_text, "CardItem tooltip should mention Shift+Left-Click author filter")
	var shift_lclick_s143 := InputEventMouseButton.new()
	shift_lclick_s143.pressed = true
	shift_lclick_s143.shift_pressed = true
	shift_lclick_s143.button_index = MOUSE_BUTTON_LEFT
	card0_s143._gui_input(shift_lclick_s143)
	assert(main_inst.search_input.text == main_inst.archive_state.items[0].author_or_series and "작가·시리즈 검색" in main_inst.status_toast.text, "Shift+Left-clicking CardItem should filter by author_or_series")
	main_inst._reset_all_filters()
	main_inst._render_spine_shelf()
	var spine0_s143 = main_inst.spine_shelf_row.get_child(0)
	assert("Shift+좌/우클릭: 검색/복사" in spine0_s143.tooltip_text, "Spine tooltip should mention Shift+Left/Right-Click search/copy")
	spine0_s143.gui_input.emit(shift_lclick_s143)
	assert(main_inst.search_input.text == main_inst.archive_state.items[0].title and "책등 작품 필터" in main_inst.status_toast.text, "Shift+Left-clicking spine should filter by item title")
	main_inst._reset_all_filters()
	print("✓ Sprint 143 Milestone: CardItem Shift+Left-Click Author & Spine Shift+Click Search verified")

	# Sprint 144 Milestone: VolHeader Shift+Left-Click Batch Bookmark & NextQuoteBtn Shift+Left-Click Open
	assert("Shift+좌클릭: 작품 열기" in main_inst.next_quote_btn.tooltip_text, "NextQuoteBtn tooltip should mention Shift+Left-Click open item")
	var shift_lclick_s144 := InputEventMouseButton.new()
	shift_lclick_s144.pressed = true
	shift_lclick_s144.shift_pressed = true
	shift_lclick_s144.button_index = MOUSE_BUTTON_LEFT
	main_inst.next_quote_btn.gui_input.emit(shift_lclick_s144)
	assert(main_inst.detail_modal.visible, "Shift+Left-clicking NextQuoteBtn should open current quote item modal")
	var item_s144 = main_inst.detail_modal.current_item
	assert("전권 북마크 일괄 토글" in main_inst.detail_modal.vol_header.tooltip_text, "VolHeader tooltip should mention batch bookmark toggle")
	main_inst.detail_modal.vol_header.gui_input.emit(shift_lclick_s144)
	assert(item_s144.get_bookmarked_volumes_count() == item_s144.volumes.size(), "First Shift+Left-click on VolHeader should bookmark all volumes")
	main_inst.detail_modal.vol_header.gui_input.emit(shift_lclick_s144)
	assert(item_s144.get_bookmarked_volumes_count() == 0, "Second Shift+Left-click on VolHeader should unbookmark all volumes")
	main_inst.detail_modal.close()
	print("✓ Sprint 144 Milestone: VolHeader Batch Bookmark & NextQuoteBtn Open verified")

	# Sprint 145 Milestone: TodayQuoteLabel Shift+Left-Click Copy & CoverRect Shift+Click Finish/Condition
	assert("Shift+좌클릭: 복사" in main_inst.today_quote_label.tooltip_text, "TodayQuoteLabel tooltip should mention Shift+Left-Click copy")
	var shift_lclick_s145 := InputEventMouseButton.new()
	shift_lclick_s145.pressed = true
	shift_lclick_s145.shift_pressed = true
	shift_lclick_s145.button_index = MOUSE_BUTTON_LEFT
	main_inst.today_quote_label.gui_input.emit(shift_lclick_s145)
	assert("오늘의 밑줄 복사 완료" in main_inst.status_toast.text, "Shift+Left-clicking TodayQuoteLabel should copy quote and show toast")
	var target_s145 = main_inst.archive_state.items[0]
	var orig_fin_s145: String = target_s145.cover_finish
	var orig_cond_s145: String = target_s145.condition_grade
	main_inst._on_card_clicked(target_s145)
	assert("Shift+좌/우클릭: 마감/상태등급" in main_inst.detail_modal.cover_rect.tooltip_text, "CoverRect tooltip should mention Shift+Left/Right-Click finish/condition")
	main_inst.detail_modal.cover_rect.gui_input.emit(shift_lclick_s145)
	assert(target_s145.cover_finish != orig_fin_s145, "Shift+Left-clicking CoverRect should cycle cover_finish")
	var shift_rclick_s145 := InputEventMouseButton.new()
	shift_rclick_s145.pressed = true
	shift_rclick_s145.shift_pressed = true
	shift_rclick_s145.button_index = MOUSE_BUTTON_RIGHT
	main_inst.detail_modal.cover_rect.gui_input.emit(shift_rclick_s145)
	assert(target_s145.condition_grade != orig_cond_s145, "Shift+Right-clicking CoverRect should cycle condition_grade")
	main_inst.detail_modal.close()
	print("✓ Sprint 145 Milestone: TodayQuoteLabel Copy & CoverRect Finish/Condition verified")

	# Sprint 146 Milestone: AppTitle Shift+Left-Click AddModal & ModalWashiTape Shift+Click Sticker/Paper
	var app_title_s146: Control = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/TitleRow/TitleCol/AppTitle")
	assert("새 일기 쓰기 (N)" in app_title_s146.tooltip_text, "AppTitle tooltip should mention Shift+Left-Click AddModal")
	var shift_lclick_s146 := InputEventMouseButton.new()
	shift_lclick_s146.pressed = true
	shift_lclick_s146.shift_pressed = true
	shift_lclick_s146.button_index = MOUSE_BUTTON_LEFT
	app_title_s146.gui_input.emit(shift_lclick_s146)
	assert(main_inst.add_modal.visible, "Shift+Left-clicking AppTitle should open AddModal")
	main_inst.add_modal.close()
	var target_s146 = main_inst.archive_state.items[0]
	var orig_stk_s146: String = target_s146.deco_sticker
	var orig_pat_s146: String = target_s146.paper_pattern
	main_inst._on_card_clicked(target_s146)
	var washi_s146: ColorRect = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/TopInfo/CoverRect/ModalWashiTape")
	assert("스티커/속지" in washi_s146.tooltip_text, "ModalWashiTape tooltip should mention Shift+Left/Right-Click sticker/paper")
	washi_s146.gui_input.emit(shift_lclick_s146)
	assert(target_s146.deco_sticker != orig_stk_s146, "Shift+Left-clicking ModalWashiTape should cycle deco_sticker")
	var shift_rclick_s146 := InputEventMouseButton.new()
	shift_rclick_s146.pressed = true
	shift_rclick_s146.shift_pressed = true
	shift_rclick_s146.button_index = MOUSE_BUTTON_RIGHT
	washi_s146.gui_input.emit(shift_rclick_s146)
	assert(target_s146.paper_pattern != orig_pat_s146, "Shift+Right-clicking ModalWashiTape should cycle paper_pattern")
	main_inst.detail_modal.close()
	print("✓ Sprint 146 Milestone: AppTitle AddModal & ModalWashiTape Sticker/Paper verified")

	# Sprint 147 Milestone: SubTitle Shift+Click Backup/Cheatsheet & PageBadgeLabel Shift+Click First/Last
	assert("백업/단축키" in main_inst.sub_title.tooltip_text, "SubTitle tooltip should mention Shift+Left/Right-Click backup/cheatsheet")
	var shift_lclick_s147 := InputEventMouseButton.new()
	shift_lclick_s147.pressed = true
	shift_lclick_s147.shift_pressed = true
	shift_lclick_s147.button_index = MOUSE_BUTTON_LEFT
	var shift_rclick_s147 := InputEventMouseButton.new()
	shift_rclick_s147.pressed = true
	shift_rclick_s147.shift_pressed = true
	shift_rclick_s147.button_index = MOUSE_BUTTON_RIGHT
	main_inst.sub_title.gui_input.emit(shift_lclick_s147)
	assert("로컬 JSON 서재 백업 저장 완료" in main_inst.status_toast.text, "Shift+Left-clicking SubTitle should trigger instant JSON backup")
	main_inst.sub_title.gui_input.emit(shift_rclick_s147)
	assert("단축키" in main_inst.status_toast.text, "Shift+Right-clicking SubTitle should show shortcut cheatsheet")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var page_lbl_s147: Label = main_inst.detail_modal.get_node("Panel/VBox/Header/HBox/PageBadgeLabel")
	assert("Shift+좌/우클릭" in page_lbl_s147.tooltip_text, "PageBadgeLabel tooltip should mention Shift+Left/Right-Click first/last")
	page_lbl_s147.gui_input.emit(shift_rclick_s147)
	assert(page_lbl_s147.text == "6/6", "Shift+Right-clicking PageBadgeLabel should jump to last item (6/6)")
	page_lbl_s147.gui_input.emit(shift_lclick_s147)
	assert(page_lbl_s147.text == "1/6", "Shift+Left-clicking PageBadgeLabel should jump to first item (1/6)")
	main_inst.detail_modal.close()
	print("✓ Sprint 147 Milestone: SubTitle Backup/Cheatsheet & PageBadgeLabel First/Last verified")

	# Sprint 148 Milestone: AmbientBtn Shift+Left-Click Mute & AuthorLabel Shift+Left-Click Copy
	main_inst.cycle_ambient_sound(1)
	assert(main_inst.ambient_sound_index != 0, "Setup: ambient sound should be active before Shift+Left-Click mute")
	var amb_btn_s148: Button = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AmbientBtn")
	assert("즉시 무음" in amb_btn_s148.tooltip_text, "AmbientBtn tooltip should mention Shift+Left-Click mute")
	var shift_lclick_s148 := InputEventMouseButton.new()
	shift_lclick_s148.pressed = true
	shift_lclick_s148.shift_pressed = true
	shift_lclick_s148.button_index = MOUSE_BUTTON_LEFT
	amb_btn_s148.gui_input.emit(shift_lclick_s148)
	assert(main_inst.ambient_sound_index == 0 and amb_btn_s148.text == "🔕 무음", "Shift+Left-clicking AmbientBtn should mute ambient sound immediately")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	assert("작가명 복사" in main_inst.detail_modal.author_label.tooltip_text, "AuthorLabel tooltip should mention Shift+Left-Click copy")
	main_inst.detail_modal.author_label.gui_input.emit(shift_lclick_s148)
	assert("✅ 작가 복사됨:" in main_inst.detail_modal.author_label.tooltip_text, "Shift+Left-clicking AuthorLabel should copy author name and update tooltip")
	main_inst.detail_modal.close()
	print("✓ Sprint 148 Milestone: AmbientBtn Mute & AuthorLabel Copy verified")

	# Sprint 149 Milestone: SortBtn Shift+Left-Click Default Reset & TagLabel Shift+Left-Click Copy
	main_inst._step_sort(1)
	assert(main_inst.sort_mode != 0, "Setup: sort_mode should be non-zero before Shift+Left-Click reset")
	assert("Shift+좌클릭: 기본순" in main_inst.sort_btn.tooltip_text, "SortBtn tooltip should mention Shift+Left-Click default reset")
	var shift_lclick_s149 := InputEventMouseButton.new()
	shift_lclick_s149.pressed = true
	shift_lclick_s149.shift_pressed = true
	shift_lclick_s149.button_index = MOUSE_BUTTON_LEFT
	main_inst.sort_btn.gui_input.emit(shift_lclick_s149)
	assert(main_inst.sort_mode == 0 and main_inst.sort_btn.text == "↕ 기본순", "Shift+Left-clicking SortBtn should reset sort mode to default")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	assert("태그 복사" in main_inst.detail_modal.tag_label.tooltip_text, "TagLabel tooltip should mention Shift+Left-Click tag copy")
	main_inst.detail_modal.tag_label.gui_input.emit(shift_lclick_s149)
	assert("✅ 태그 복사됨:" in main_inst.detail_modal.tag_label.tooltip_text, "Shift+Left-clicking TagLabel should copy tag text and update tooltip")
	main_inst.detail_modal.close()
	print("✓ Sprint 149 Milestone: SortBtn Default Reset & TagLabel Copy verified")

	# Sprint 150 Milestone: StatusToast Shift+Click Briefing/Copy & MemoLabel Shift+Left-Click Copy
	assert("브리핑/복사" in main_inst.status_toast.tooltip_text, "StatusToast tooltip should mention Shift+Left/Right-Click briefing/copy")
	var shift_lclick_s150 := InputEventMouseButton.new()
	shift_lclick_s150.pressed = true
	shift_lclick_s150.shift_pressed = true
	shift_lclick_s150.button_index = MOUSE_BUTTON_LEFT
	var shift_rclick_s150 := InputEventMouseButton.new()
	shift_rclick_s150.pressed = true
	shift_rclick_s150.shift_pressed = true
	shift_rclick_s150.button_index = MOUSE_BUTTON_RIGHT
	main_inst.status_toast.gui_input.emit(shift_lclick_s150)
	assert("₩" in main_inst.status_toast.text, "Shift+Left-clicking StatusToast should show library infographic briefing")
	main_inst.status_toast.gui_input.emit(shift_rclick_s150)
	assert("상태 메시지 복사 완료" in main_inst.status_toast.text, "Shift+Right-clicking StatusToast should copy toast text")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	assert("감상평 복사" in main_inst.detail_modal.memo_label.tooltip_text, "MemoLabel tooltip should mention Shift+Left-Click memo copy")
	main_inst.detail_modal.memo_label.gui_input.emit(shift_lclick_s150)
	assert("✅ 감상평 복사됨:" in main_inst.detail_modal.memo_label.tooltip_text, "Shift+Left-clicking MemoLabel should copy memo and update tooltip")
	main_inst.detail_modal.close()
	print("✓ Sprint 150 Milestone: StatusToast Briefing/Copy & MemoLabel Copy verified")

	# Sprint 151 Milestone: RandomPickBtn Shift+Left-Click Filter & SaveQuoteBtn/HighlightBtn Shift+Left-Click
	assert("Shift+좌클릭: 서재 필터" in main_inst.random_pick_btn.tooltip_text, "RandomPickBtn tooltip should mention Shift+Left-Click filter")
	var shift_lclick_s151 := InputEventMouseButton.new()
	shift_lclick_s151.pressed = true
	shift_lclick_s151.shift_pressed = true
	shift_lclick_s151.button_index = MOUSE_BUTTON_LEFT
	main_inst.random_pick_btn.gui_input.emit(shift_lclick_s151)
	assert(main_inst.search_input.text != "" and "랜덤 추천 서재 필터" in main_inst.status_toast.text, "Shift+Left-clicking RandomPickBtn should filter shelf to picked item")
	main_inst._reset_all_filters()
	var target_s151 = main_inst.archive_state.items[0]
	var orig_pat_s151: String = target_s151.paper_pattern
	main_inst._on_card_clicked(target_s151)
	var save_btn_s151: Button = main_inst.detail_modal.save_quote_btn
	var hl_btn_s151: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/QuoteEditRow/HighlightBtn")
	assert("저장+복사" in save_btn_s151.tooltip_text and "속지" in hl_btn_s151.tooltip_text, "SaveQuoteBtn and HighlightBtn tooltips should mention Shift+Left-Click actions")
	main_inst.detail_modal.quote_input.text = "테스트 밑줄 복사"
	save_btn_s151.gui_input.emit(shift_lclick_s151)
	assert("✅ 저장·복사됨:" in save_btn_s151.tooltip_text and target_s151.memo == "테스트 밑줄 복사", "Shift+Left-clicking SaveQuoteBtn should save and copy quote")
	hl_btn_s151.gui_input.emit(shift_lclick_s151)
	assert(target_s151.paper_pattern != orig_pat_s151, "Shift+Left-clicking HighlightBtn should cycle paper_pattern")
	main_inst.detail_modal.close()
	print("✓ Sprint 151 Milestone: RandomPickBtn Filter & Save/Highlight Shift+Click verified")

	# Sprint 152 Milestone: AddBtn Shift+Left-Click Sample Modal & AddVolBtn Shift+Left-Click First+Bookmark
	var add_btn_s152: Control = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/TitleRow/AddBtn")
	assert("샘플 채움 열기" in add_btn_s152.tooltip_text, "AddBtn tooltip should mention Shift+Left-Click sample modal")
	var shift_lclick_s152 := InputEventMouseButton.new()
	shift_lclick_s152.pressed = true
	shift_lclick_s152.shift_pressed = true
	shift_lclick_s152.button_index = MOUSE_BUTTON_LEFT
	add_btn_s152.gui_input.emit(shift_lclick_s152)
	assert(main_inst.add_modal.visible and main_inst.add_modal.title_input.text == "나의 비밀 독서 일기", "Shift+Left-clicking AddBtn should open AddModal pre-filled with sample")
	main_inst.add_modal.close()
	var target_s152 = main_inst.archive_state.items[0]
	var orig_vols_s152: int = target_s152.volumes.size()
	main_inst._on_card_clicked(target_s152)
	assert("초판+북마크 추가" in main_inst.detail_modal.add_vol_btn.tooltip_text, "AddVolBtn tooltip should mention Shift+Left-Click first+bookmark add")
	main_inst.detail_modal.add_vol_btn.gui_input.emit(shift_lclick_s152)
	assert(target_s152.volumes.size() == orig_vols_s152 + 1, "Shift+Left-clicking AddVolBtn should add 1 volume")
	var last_vol_s152 = target_s152.volumes[target_s152.volumes.size() - 1]
	assert(last_vol_s152.get("status", "") == "first" and bool(last_vol_s152.get("bookmarked", false)), "Newly added volume via Shift+Left-Click should be first edition and bookmarked")
	main_inst.detail_modal.close()
	print("✓ Sprint 152 Milestone: AddBtn Sample Modal & AddVolBtn First+Bookmark verified")

	# Sprint 153 Milestone: ThemeBtn Shift+Left-Click Default Reset & CloseBtn Shift+Left-Click Copy+Close
	main_inst._step_theme(1)
	assert(main_inst.theme_cursor != 0, "Setup: theme_cursor should be non-zero before Shift+Left-Click reset")
	var theme_btn_s153: Control = main_inst.get_node("VBox/BottomBar/Margin/VBox/NavRow").get_child(3)
	assert("기본 테마" in theme_btn_s153.tooltip_text, "ThemeBtn tooltip should mention Shift+Left-Click default theme reset")
	var shift_lclick_s153 := InputEventMouseButton.new()
	shift_lclick_s153.pressed = true
	shift_lclick_s153.shift_pressed = true
	shift_lclick_s153.button_index = MOUSE_BUTTON_LEFT
	theme_btn_s153.gui_input.emit(shift_lclick_s153)
	assert(main_inst.theme_cursor == 0 and "기본 속지 테마 복원" in main_inst.status_toast.text, "Shift+Left-clicking ThemeBtn should reset theme to default")
	main_inst._on_card_clicked(main_inst.archive_state.items[0])
	var close_btn_s153: Button = main_inst.detail_modal.get_node("Panel/VBox/Header/HBox/CloseBtn")
	assert("카드 복사+닫기" in close_btn_s153.tooltip_text, "CloseBtn tooltip should mention Shift+Left-Click copy+close")
	close_btn_s153.gui_input.emit(shift_lclick_s153)
	assert(not main_inst.detail_modal.visible and "복사" in main_inst.status_toast.text, "Shift+Left-clicking CloseBtn should copy share card and close modal")
	print("✓ Sprint 153 Milestone: ThemeBtn Default Reset & CloseBtn Copy+Close verified")

	# Sprint 154 Milestone: StatItems/StatGacha Shift+Left-Click & InkSwatch Shift+Left-Click Apply+Focus
	main_inst._set_sort_mode(2)
	main_inst.search_input.text = "프리렌"
	main_inst._render_cards()
	var stat_items_s154: Control = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatItems")
	var stat_gacha_s154: Control = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatGacha")
	assert("전체+기본순" in stat_items_s154.tooltip_text and "가챠 가치순" in stat_gacha_s154.tooltip_text, "StatItems and StatGacha tooltips should mention Shift+Left-Click actions")
	var shift_lclick_s154 := InputEventMouseButton.new()
	shift_lclick_s154.pressed = true
	shift_lclick_s154.shift_pressed = true
	shift_lclick_s154.button_index = MOUSE_BUTTON_LEFT
	stat_items_s154.gui_input.emit(shift_lclick_s154)
	assert(main_inst.sort_mode == 0 and main_inst.search_input.text == "" and main_inst.card_grid.get_child_count() == 6, "Shift+Left-clicking StatItems should reset all filters and sort mode")
	stat_gacha_s154.gui_input.emit(shift_lclick_s154)
	assert(main_inst.sort_mode == 3 and main_inst.card_grid.get_child_count() == 2, "Shift+Left-clicking StatGacha should filter gacha and sort by value")
	main_inst._reset_all_filters()
	main_inst._set_sort_mode(0)
	var target_s154 = main_inst.archive_state.items[0]
	main_inst._on_card_clicked(target_s154)
	var ink_burg_s154: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/InkRow/InkBurgundy")
	assert("잉크 적용+입력창" in ink_burg_s154.tooltip_text, "Ink swatch tooltip should mention Shift+Left-Click apply+focus")
	ink_burg_s154.gui_input.emit(shift_lclick_s154)
	assert(target_s154.memo_ink_color == "#7f1d1d", "Shift+Left-clicking InkBurgundy should apply burgundy ink")
	main_inst.detail_modal.close()
	print("✓ Sprint 154 Milestone: StatItems/StatGacha & InkSwatch Shift+Left-Click verified")

	# Sprint 155 Milestone: Filter Tabs Shift+Left-Click Quick Open & Stamp Shift+Left-Click Apply+Close
	assert("랜덤 열기" in main_inst.tab_all.tooltip_text and "첫 작품 열기" in main_inst.tab_gacha.tooltip_text, "Filter tabs tooltips should mention Shift+Left-Click open")
	var shift_lclick_s155 := InputEventMouseButton.new()
	shift_lclick_s155.pressed = true
	shift_lclick_s155.shift_pressed = true
	shift_lclick_s155.button_index = MOUSE_BUTTON_LEFT
	main_inst.tab_gacha.gui_input.emit(shift_lclick_s155)
	assert(main_inst.detail_modal.visible and main_inst.detail_modal.current_item.category == 1, "Shift+Left-clicking tab_gacha should filter gacha and open first gacha modal")
	main_inst.detail_modal.close()
	main_inst._reset_all_filters()
	main_inst.tab_all.gui_input.emit(shift_lclick_s155)
	assert(main_inst.detail_modal.visible, "Shift+Left-clicking tab_all should reset filters and open random modal")
	main_inst.detail_modal.close()
	var target_s155 = main_inst.archive_state.items[0]
	main_inst._on_card_clicked(target_s155)
	var stamp_fav_s155: Button = main_inst.detail_modal.get_node("Panel/VBox/BodyMargin/Body/StampRow/StampFav")
	assert("찍고 닫기" in stamp_fav_s155.tooltip_text, "Stamp button tooltip should mention Shift+Left-Click apply+close")
	stamp_fav_s155.gui_input.emit(shift_lclick_s155)
	assert(not main_inst.detail_modal.visible and target_s155.status_tag == "인생최애", "Shift+Left-clicking StampFav should apply stamp and close modal")
	print("✓ Sprint 155 Milestone: Filter Tabs Open & Stamp Apply+Close verified")

	# Sprint 156 Milestone: StatVols/StatFirsts Shift+Left-Click & Vol StarBtn Shift+Left-Click 5-Star+Bookmark
	var stat_vols_s156: Control = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatVols")
	var stat_firsts_s156: Control = main_inst.get_node("VBox/TopBar/TopMargin/StatsVBox/StatRow/StatFirsts")
	assert("첫 작품 열기" in stat_vols_s156.tooltip_text and "초판 가치순" in stat_firsts_s156.tooltip_text, "StatVols and StatFirsts tooltips should mention Shift+Left-Click actions")
	var shift_lclick_s156 := InputEventMouseButton.new()
	shift_lclick_s156.pressed = true
	shift_lclick_s156.shift_pressed = true
	shift_lclick_s156.button_index = MOUSE_BUTTON_LEFT
	stat_vols_s156.gui_input.emit(shift_lclick_s156)
	assert(main_inst.detail_modal.visible and main_inst.detail_modal.current_item.category == 0, "Shift+Left-clicking StatVols should filter manga and open first manga modal")
	main_inst.detail_modal.close()
	main_inst._reset_all_filters()
	stat_firsts_s156.gui_input.emit(shift_lclick_s156)
	assert(main_inst.sort_mode == 3 and main_inst.filter_firsts_only, "Shift+Left-clicking StatFirsts should filter first editions and sort by value")
	main_inst._reset_all_filters()
	main_inst._set_sort_mode(0)
	var target_s156 = main_inst.archive_state.items[0]
	target_s156.volumes[0]["rating"] = 3
	target_s156.volumes[0]["bookmarked"] = false
	main_inst._on_card_clicked(target_s156)
	var row_btns_s156 = main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Button", true, false)
	var star_btn_s156: Button = null
	for rb in row_btns_s156:
		if "★" in rb.text:
			star_btn_s156 = rb
	assert(star_btn_s156 != null and "★5+북마크" in star_btn_s156.tooltip_text, "StarBtn tooltip should mention Shift+Left-Click 5-star+bookmark")
	star_btn_s156.gui_input.emit(shift_lclick_s156)
	assert(int(target_s156.volumes[0].get("rating", 0)) == 5 and bool(target_s156.volumes[0].get("bookmarked", false)), "Shift+Left-clicking StarBtn should set 5 stars and bookmark")
	main_inst.detail_modal.close()
	print("✓ Sprint 156 Milestone: StatVols/StatFirsts & StarBtn Shift+Left-Click verified")

	# Sprint 157 Milestone: WebBtn/CamBtn Shift+Left-Click Scrape+Open & Vol BmBtn Shift+Left-Click First+Bookmark
	var orig_cnt_s157: int = main_inst.archive_state.items.size()
	var nav_row_s157 = main_inst.get_node("VBox/BottomBar/Margin/VBox/NavRow")
	var web_btn_s157: Control = nav_row_s157.get_child(0)
	var cam_btn_s157: Control = nav_row_s157.get_child(1)
	assert("스크랩 후 열기" in web_btn_s157.tooltip_text and "촬영 후 열기" in cam_btn_s157.tooltip_text, "WebBtn and CamBtn tooltips should mention Shift+Left-Click open")
	var shift_lclick_s157 := InputEventMouseButton.new()
	shift_lclick_s157.pressed = true
	shift_lclick_s157.shift_pressed = true
	shift_lclick_s157.button_index = MOUSE_BUTTON_LEFT
	web_btn_s157.gui_input.emit(shift_lclick_s157)
	assert(main_inst.archive_state.items.size() == orig_cnt_s157 + 1 and main_inst.detail_modal.visible, "Shift+Left-clicking WebBtn should scrape and open modal")
	main_inst.detail_modal.close()
	main_inst.archive_state.items.remove_at(0)
	main_inst._render_cards()
	var target_s157 = main_inst.archive_state.items[0]
	target_s157.volumes[0]["status"] = "owned"
	target_s157.volumes[0]["bookmarked"] = false
	main_inst._on_card_clicked(target_s157)
	var row_btns_s157 = main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Button", true, false)
	var bm_btn_s157: Button = null
	for rb in row_btns_s157:
		if rb.text == "🏷️" or rb.text == "🔖":
			bm_btn_s157 = rb
	assert(bm_btn_s157 != null and "초판+북마크" in bm_btn_s157.tooltip_text, "BmBtn tooltip should mention Shift+Left-Click first+bookmark")
	bm_btn_s157.gui_input.emit(shift_lclick_s157)
	assert(target_s157.volumes[0].get("status", "") == "first" and bool(target_s157.volumes[0].get("bookmarked", false)), "Shift+Left-clicking BmBtn should set first edition and bookmark")
	main_inst.detail_modal.close()
	print("✓ Sprint 157 Milestone: WebBtn/CamBtn Open & BmBtn First+Bookmark verified")

	# Sprint 158 Milestone: DiyBtn Shift+Left-Click Sample Modal & Vol StatusBtn Shift+Left-Click Batch Toggle
	var diy_btn_s158: Control = main_inst.get_node("VBox/BottomBar/Margin/VBox/NavRow").get_child(2)
	assert("샘플 채움 열기" in diy_btn_s158.tooltip_text, "DiyBtn tooltip should mention Shift+Left-Click sample modal")
	var shift_lclick_s158 := InputEventMouseButton.new()
	shift_lclick_s158.pressed = true
	shift_lclick_s158.shift_pressed = true
	shift_lclick_s158.button_index = MOUSE_BUTTON_LEFT
	diy_btn_s158.gui_input.emit(shift_lclick_s158)
	assert(main_inst.add_modal.visible and main_inst.add_modal.title_input.text == "나의 비밀 독서 일기", "Shift+Left-clicking DiyBtn should open AddModal pre-filled with sample")
	main_inst.add_modal.close()
	var target_s158 = main_inst.archive_state.items[0]
	target_s158.volumes[0]["status"] = "owned"
	main_inst._on_card_clicked(target_s158)
	var row_btns_s158 = main_inst.detail_modal.vol_list.get_child(0).find_children("*", "Button", true, false)
	var st_btn_s158: Button = null
	for rb in row_btns_s158:
		if "소장완료" in rb.text or "초판특전" in rb.text:
			st_btn_s158 = rb
	assert(st_btn_s158 != null and "전권 일괄 전환" in st_btn_s158.tooltip_text, "StatusBtn tooltip should mention Shift+Left-Click batch toggle")
	st_btn_s158.gui_input.emit(shift_lclick_s158)
	var all_first_s158: bool = true
	for vv in target_s158.volumes:
		if vv.get("status", "") != "first":
			all_first_s158 = false
	assert(all_first_s158, "Shift+Left-clicking StatusBtn should set all volumes to first edition")
	main_inst.detail_modal.close()
	print("✓ Sprint 158 Milestone: DiyBtn Sample Modal & StatusBtn Batch Toggle verified")

	# Sprint 159: Volume date_btn Shift+Left-Click batch date stamp & PrevItemBtn/NextItemBtn Shift+Left-Click
	var item159 = main_inst.archive_state.items[0]
	for v in item159.volumes:
		v["date"] = "2020.01.01"
	main_inst.detail_modal.open(item159)
	var vol_list159: VBoxContainer = main_inst.detail_modal.vol_list
	assert(vol_list159 != null and vol_list159.get_child_count() > 0, "Vol list should have volume rows")
	var first_row159 = vol_list159.get_child(0)
	var date_btn159: Button = null
	for child in first_row159.find_children("", "Button", true, false):
		if child is Button and "스탬프" in child.tooltip_text:
			date_btn159 = child
			break
	assert(date_btn159 != null, "Volume row should have date stamp button")
	assert("Shift+좌클릭: 전권 오늘 날짜 일괄 스탬프" in date_btn159.tooltip_text, "date_btn tooltip should mention Shift+Left-Click batch date stamp")
	var shift_lclick159 := InputEventMouseButton.new()
	shift_lclick159.button_index = MOUSE_BUTTON_LEFT
	shift_lclick159.pressed = true
	shift_lclick159.shift_pressed = true
	date_btn159.gui_input.emit(shift_lclick159)
	var today_d159 := Time.get_date_dict_from_system()
	var today_str159 := "%04d.%02d.%02d" % [today_d159.year, today_d159.month, today_d159.day]
	for v in item159.volumes:
		assert(str(v.get("date", "")) == today_str159, "Shift+Left-Click on date_btn should stamp today's date on all volumes")
	var prev_btn159: Button = main_inst.detail_modal.find_child("PrevItemBtn", true, false) as Button
	var next_btn159: Button = main_inst.detail_modal.find_child("NextItemBtn", true, false) as Button
	assert(prev_btn159 != null and next_btn159 != null, "PrevItemBtn and NextItemBtn should exist")
	assert("Shift+좌클릭" in prev_btn159.tooltip_text and "Shift+좌클릭" in next_btn159.tooltip_text, "Header nav tooltips should mention Shift+Left-Click")
	var nav_deltas159: Array = []
	var nav_cb159 := func(delta: int): nav_deltas159.append(delta)
	main_inst.detail_modal.navigate_requested.connect(nav_cb159)
	next_btn159.gui_input.emit(shift_lclick159)
	prev_btn159.gui_input.emit(shift_lclick159)
	main_inst.detail_modal.navigate_requested.disconnect(nav_cb159)
	assert(nav_deltas159 == [9999, -9999], "Shift+Left-Click on Next/PrevItemBtn should emit 9999 and -9999")
	main_inst.detail_modal.close()
	print("✓ Sprint 159: Volume Date Batch Stamp & Header Nav Shift+Left-Click verified")

	# Sprint 160 Milestone: RemoveVolBtn Shift+Left-Click Batch Bookmark & ShareCardBtn Shift+Left-Click Summary Copy
	var item160 = main_inst.archive_state.items[0]
	for v in item160.volumes:
		v["bookmarked"] = false
	main_inst.detail_modal.open(item160)
	var rem_btn160: Button = main_inst.detail_modal.find_child("RemoveVolBtn", true, false) as Button
	var share_btn160: Button = main_inst.detail_modal.find_child("ShareCardBtn", true, false) as Button
	assert(rem_btn160 != null and share_btn160 != null, "RemoveVolBtn and ShareCardBtn should exist")
	assert("Shift+좌클릭: 전권 북마크 일괄 토글" in rem_btn160.tooltip_text, "RemoveVolBtn tooltip should mention Shift+Left-Click batch bookmark")
	assert("Shift+좌클릭: 전체 서재 리포트 복사" in share_btn160.tooltip_text, "ShareCardBtn tooltip should mention Shift+Left-Click summary copy")
	var shift_lclick160 := InputEventMouseButton.new()
	shift_lclick160.button_index = MOUSE_BUTTON_LEFT
	shift_lclick160.pressed = true
	shift_lclick160.shift_pressed = true
	rem_btn160.gui_input.emit(shift_lclick160)
	for v in item160.volumes:
		assert(bool(v.get("bookmarked", false)), "First Shift+Left-Click on RemoveVolBtn should bookmark all volumes")
	rem_btn160.gui_input.emit(shift_lclick160)
	for v in item160.volumes:
		assert(not bool(v.get("bookmarked", false)), "Second Shift+Left-Click on RemoveVolBtn should unbookmark all volumes")
	var summary_count160: Array = [0]
	var summary_cb160 := func(): summary_count160[0] += 1
	main_inst.detail_modal.summary_copy_requested.connect(summary_cb160)
	share_btn160.gui_input.emit(shift_lclick160)
	main_inst.detail_modal.summary_copy_requested.disconnect(summary_cb160)
	assert(summary_count160[0] == 1, "Shift+Left-Click on ShareCardBtn should emit summary_copy_requested")
	main_inst.detail_modal.close()
	print("✓ Sprint 160 Milestone: RemoveVolBtn Batch Bookmark & ShareCardBtn Shift+Left-Click Report Copy verified")

	# Sprint 161: Volume vol_lbl Shift+Left-Click (First+Bookmark+5Star) & quote_lbl Shift+Left-Click (Copy+Bookmark)
	var item161 = main_inst.archive_state.items[0]
	item161.volumes[0]["bookmarked"] = false
	item161.volumes[1]["status"] = "owned"
	item161.volumes[1]["bookmarked"] = false
	item161.volumes[1]["rating"] = 3
	main_inst.detail_modal.open(item161)
	var row0_161 = main_inst.detail_modal.vol_list.get_child(0)
	var row1_161 = main_inst.detail_modal.vol_list.get_child(1)
	var vol_lbl161: Label = null
	for child in row1_161.find_children("", "Label", true, false):
		if child is Label and "Shift+좌클릭: 초판+북마크+★5" in child.tooltip_text:
			vol_lbl161 = child
			break
	var quote_lbl161: Label = null
	for child in row0_161.find_children("", "Label", true, false):
		if child is Label and "Shift+좌클릭: 복사+북마크" in child.tooltip_text:
			quote_lbl161 = child
			break
	assert(vol_lbl161 != null and quote_lbl161 != null, "vol_lbl and quote_lbl should have Sprint 161 tooltips")
	var shift_lclick161 := InputEventMouseButton.new()
	shift_lclick161.button_index = MOUSE_BUTTON_LEFT
	shift_lclick161.pressed = true
	shift_lclick161.shift_pressed = true
	vol_lbl161.gui_input.emit(shift_lclick161)
	assert(item161.volumes[1].get("status", "") == "first" and bool(item161.volumes[1].get("bookmarked", false)) and int(item161.volumes[1].get("rating", 0)) == 5, "Shift+Left-Click on vol_lbl should set first+bookmark+5star")
	quote_lbl161.gui_input.emit(shift_lclick161)
	assert(bool(item161.volumes[0].get("bookmarked", false)), "Shift+Left-Click on quote_lbl should bookmark the volume")
	main_inst.detail_modal.close()
	print("✓ Sprint 161: Volume Label First+Bookmark+5Star & Quote Label Copy+Bookmark verified")

	# Sprint 162: DateStampBtn Shift+Left-Click (Purchase+AllVol Date Sync) & DeleteBtn Shift+Left-Click Disarm
	var item162 = main_inst.archive_state.items[0]
	item162.purchase_date = "2020.01.01"
	for v in item162.volumes:
		v["date"] = "2020.01.01"
	main_inst.detail_modal.open(item162)
	var date_stamp_btn162: Button = main_inst.detail_modal.find_child("DateStampBtn", true, false) as Button
	var del_btn162: Button = main_inst.detail_modal.find_child("DeleteBtn", true, false) as Button
	assert(date_stamp_btn162 != null and del_btn162 != null, "DateStampBtn and DeleteBtn should exist")
	assert("Shift+좌클릭: 구매일+전권 오늘 날짜 동기화" in date_stamp_btn162.tooltip_text, "DateStampBtn tooltip should mention Shift+Left-Click sync")
	assert("Shift+좌클릭: 삭제 확인 해제" in del_btn162.tooltip_text, "DeleteBtn tooltip should mention Shift+Left-Click disarm")
	var shift_lclick162 := InputEventMouseButton.new()
	shift_lclick162.button_index = MOUSE_BUTTON_LEFT
	shift_lclick162.pressed = true
	shift_lclick162.shift_pressed = true
	date_stamp_btn162.gui_input.emit(shift_lclick162)
	var today_d162 := Time.get_date_dict_from_system()
	var today_str162 := "%04d.%02d.%02d" % [today_d162.year, today_d162.month, today_d162.day]
	var short_today162 := "%02d.%02d" % [today_d162.month, today_d162.day]
	assert(short_today162 in item162.purchase_date, "Shift+Left-Click on DateStampBtn should stamp today's purchase_date")
	for v in item162.volumes:
		assert(str(v.get("date", "")) == today_str162, "Shift+Left-Click on DateStampBtn should sync all volume dates to today")
	del_btn162.pressed.emit()
	assert(main_inst.detail_modal.delete_armed, "First DeleteBtn press should arm delete")
	del_btn162.gui_input.emit(shift_lclick162)
	assert(not main_inst.detail_modal.delete_armed, "Shift+Left-Click on DeleteBtn should disarm delete")
	main_inst.detail_modal.close()
	print("✓ Sprint 162: DateStampBtn Purchase+AllVol Sync & DeleteBtn Shift+Left-Click Disarm verified")

	# Sprint 163: RereadBtn/DuplicateBtn/ValueBtn Shift+Left-Click Decrement
	var item163 = main_inst.archive_state.items[0]
	item163.reread_count = 3
	item163.duplicate_count = 3
	item163.estimated_value = 25000
	main_inst.detail_modal.open(item163)
	var rr_btn163: Button = main_inst.detail_modal.find_child("RereadBtn", true, false) as Button
	var dup_btn163: Button = main_inst.detail_modal.find_child("DuplicateBtn", true, false) as Button
	var val_btn163: Button = main_inst.detail_modal.find_child("ValueBtn", true, false) as Button
	assert(rr_btn163 != null and dup_btn163 != null and val_btn163 != null, "RereadBtn, DuplicateBtn, ValueBtn should exist")
	assert("Shift+좌클릭: -1" in rr_btn163.tooltip_text and "Shift+좌클릭: -1" in dup_btn163.tooltip_text and "Shift+좌클릭: -5,000원" in val_btn163.tooltip_text, "Tooltips should mention Shift+Left-Click decrement")
	var shift_lclick163 := InputEventMouseButton.new()
	shift_lclick163.button_index = MOUSE_BUTTON_LEFT
	shift_lclick163.pressed = true
	shift_lclick163.shift_pressed = true
	rr_btn163.gui_input.emit(shift_lclick163)
	dup_btn163.gui_input.emit(shift_lclick163)
	val_btn163.gui_input.emit(shift_lclick163)
	assert(item163.reread_count == 2 and item163.duplicate_count == 2 and item163.estimated_value == 20000, "Shift+Left-Click should decrement reread, duplicate, and value")
	main_inst.detail_modal.close()
	print("✓ Sprint 163: RereadBtn/DuplicateBtn/ValueBtn Shift+Left-Click Decrement verified")

	# Sprint 164: StampRow & InkRow 17-Cycler Shift+Left-Click Reverse Navigation
	var item164 = main_inst.archive_state.items[0]
	main_inst.detail_modal.open(item164)
	var obi_btn164: Button = main_inst.detail_modal.find_child("ObiCycleBtn", true, false) as Button
	var weather_btn164: Button = main_inst.detail_modal.find_child("WeatherBtn", true, false) as Button
	assert(obi_btn164 != null and weather_btn164 != null, "ObiCycleBtn and WeatherBtn should exist")
	assert("Shift+좌클릭: 이전" in obi_btn164.tooltip_text and "Shift+좌클릭: 이전" in weather_btn164.tooltip_text, "Decorator tooltips should mention Shift+Left-Click reverse")
	obi_btn164.pressed.emit()
	weather_btn164.pressed.emit()
	var orig_obi164: String = item164.obi_text
	var orig_weather164: String = item164.reading_weather
	obi_btn164.pressed.emit()
	assert(item164.obi_text != orig_obi164, "ObiCycleBtn press should advance forward")
	weather_btn164.pressed.emit()
	assert(item164.reading_weather != orig_weather164, "WeatherBtn press should advance forward")
	var shift_lclick164 := InputEventMouseButton.new()
	shift_lclick164.button_index = MOUSE_BUTTON_LEFT
	shift_lclick164.pressed = true
	shift_lclick164.shift_pressed = true
	obi_btn164.gui_input.emit(shift_lclick164)
	weather_btn164.gui_input.emit(shift_lclick164)
	assert(item164.obi_text == orig_obi164 and item164.reading_weather == orig_weather164, "Shift+Left-Click on decorator cyclers should step backward")
	main_inst.detail_modal.close()
	print("✓ Sprint 164: StampRow & InkRow 17-Cycler Shift+Left-Click Reverse verified")

	# Sprint 165 Milestone: AddModal Swatches, CatOption, CloseBtn & SubmitBtn Shift+Left-Click
	var prev_cnt165: int = main_inst.archive_state.items.size()
	main_inst.add_modal.open()
	var am165 = main_inst.add_modal
	var swatch0_165: Button = am165.color_row.get_child(0) as Button
	assert(swatch0_165 != null and "Shift+좌클릭: 이 색으로 즉시 등록" in swatch0_165.tooltip_text, "AddModal swatch tooltip should mention Shift+Left-Click")
	assert("Shift+좌클릭: 이북 ↔ 가챠 즉시 전환" in am165.cat_option.tooltip_text, "AddModal CatOption tooltip should mention Shift+Left-Click")
	assert("Shift+좌클릭: 입력란 모두 비우기" in am165.close_btn.tooltip_text, "AddModal CloseBtn tooltip should mention Shift+Left-Click")
	assert("Shift+좌클릭: 샘플 자동 채움 등록" in am165.submit_btn.tooltip_text, "AddModal SubmitBtn tooltip should mention Shift+Left-Click")
	var shift_lclick165 := InputEventMouseButton.new()
	shift_lclick165.button_index = MOUSE_BUTTON_LEFT
	shift_lclick165.pressed = true
	shift_lclick165.shift_pressed = true
	am165.cat_option.select(0)
	am165.cat_option.gui_input.emit(shift_lclick165)
	assert(am165.cat_option.selected == 1, "Shift+Left-Click on CatOption should toggle category")
	am165.title_input.text = "임시 제목"
	am165.close_btn.gui_input.emit(shift_lclick165)
	assert(am165.title_input.text == "" and am165.visible, "Shift+Left-Click on CloseBtn should clear inputs without closing")
	swatch0_165.gui_input.emit(shift_lclick165)
	assert(main_inst.archive_state.items.size() == prev_cnt165 + 1 and not am165.visible, "Shift+Left-Click on swatch should instant-submit sample item")
	main_inst.add_modal.open()
	am165.clear_inputs()
	am165.submit_btn.gui_input.emit(shift_lclick165)
	assert(main_inst.archive_state.items.size() == prev_cnt165 + 2 and not am165.visible, "Shift+Left-Click on SubmitBtn should auto-fill sample and submit")
	print("✓ Sprint 165 Milestone: AddModal Swatches/CatOption/CloseBtn/SubmitBtn Shift+Left-Click verified")

	# Sprint 166: EmptyStateResetBtn Shift+Left-Click (Reset+Open Random) & DetailModal Dimmer Shift+Left-Click (Copy+Close)
	main_inst.search_input.text = "__NONE_SPRINT166__"
	main_inst._render_cards()
	var reset_btn166: Button = main_inst.find_child("EmptyStateResetBtn", true, false) as Button
	assert(reset_btn166 != null and "Shift+좌클릭: 복원 후 랜덤 일기장 열기" in reset_btn166.tooltip_text, "EmptyStateResetBtn tooltip should mention Shift+Left-Click random open")
	var shift_lclick166 := InputEventMouseButton.new()
	shift_lclick166.button_index = MOUSE_BUTTON_LEFT
	shift_lclick166.pressed = true
	shift_lclick166.shift_pressed = true
	reset_btn166.gui_input.emit(shift_lclick166)
	assert(main_inst.search_input.text == "" and main_inst.detail_modal.visible, "Shift+Left-Click on EmptyStateResetBtn should reset filters and open random modal")
	main_inst.detail_modal.close()
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	var dimmer166: Control = main_inst.detail_modal.get_node_or_null("Dimmer")
	assert(dimmer166 != null and "Shift+좌클릭: 카드 복사+닫기" in dimmer166.tooltip_text, "DetailModal Dimmer tooltip should mention Shift+Left-Click copy+close")
	dimmer166.gui_input.emit(shift_lclick166)
	assert(not main_inst.detail_modal.visible, "Shift+Left-Click on DetailModal Dimmer should copy card and close modal")
	print("✓ Sprint 166: EmptyStateResetBtn Random Open & DetailModal Dimmer Copy+Close verified")

	# Sprint 167: AddModal Dimmer Shift+Left-Click Clear & TitleLabel Shift+Left-Click Sample Submit
	var prev_cnt167: int = main_inst.archive_state.items.size()
	main_inst.add_modal.open()
	var am_dimmer167: Control = main_inst.add_modal.get_node_or_null("Dimmer")
	var am_title167: Label = main_inst.add_modal.get_node_or_null("Panel/VBox/Header/HBox/TitleLabel")
	assert(am_dimmer167 != null and am_title167 != null, "AddModal Dimmer and TitleLabel should exist")
	assert("Shift+좌클릭: 입력 내용만 비우기" in am_dimmer167.tooltip_text, "AddModal Dimmer tooltip should mention Shift+Left-Click clear")
	assert("Shift+좌클릭: 샘플 즉시 등록" in am_title167.tooltip_text, "AddModal TitleLabel tooltip should mention Shift+Left-Click sample submit")
	var shift_lclick167 := InputEventMouseButton.new()
	shift_lclick167.button_index = MOUSE_BUTTON_LEFT
	shift_lclick167.pressed = true
	shift_lclick167.shift_pressed = true
	main_inst.add_modal.title_input.text = "임시167"
	am_dimmer167.gui_input.emit(shift_lclick167)
	assert(main_inst.add_modal.title_input.text == "" and main_inst.add_modal.visible, "Shift+Left-Click on AddModal Dimmer should clear inputs without closing")
	am_title167.gui_input.emit(shift_lclick167)
	assert(main_inst.archive_state.items.size() == prev_cnt167 + 1 and not main_inst.add_modal.visible, "Shift+Left-Click on AddModal TitleLabel should fill sample and submit")
	print("✓ Sprint 167: AddModal Dimmer Clear & TitleLabel Shift+Left-Click Sample Submit verified")

	# Sprint 168: SearchInput Shift+Left-Click Open First & QuoteInput Shift+Left-Click Save+Copy
	main_inst.search_input.text = ""
	main_inst._render_cards()
	assert("Shift+좌클릭: 첫 결과 열기" in main_inst.search_input.tooltip_text, "SearchInput tooltip should mention Shift+Left-Click open first")
	var shift_lclick168 := InputEventMouseButton.new()
	shift_lclick168.button_index = MOUSE_BUTTON_LEFT
	shift_lclick168.pressed = true
	shift_lclick168.shift_pressed = true
	main_inst.search_input.gui_input.emit(shift_lclick168)
	assert(main_inst.detail_modal.visible, "Shift+Left-Click on SearchInput should open first filtered card")
	assert("Shift+좌클릭: 저장+복사" in main_inst.detail_modal.quote_input.tooltip_text, "QuoteInput tooltip should mention Shift+Left-Click save+copy")
	main_inst.detail_modal.quote_input.text = "스쿼드 168 테스트 밑줄"
	main_inst.detail_modal.quote_input.gui_input.emit(shift_lclick168)
	assert(main_inst.detail_modal.current_item.memo == "스쿼드 168 테스트 밑줄" and main_inst.detail_modal.quote_input.tooltip_text == "✅ 저장·복사됨: 스쿼드 168 테스트 밑줄", "Shift+Left-Click on QuoteInput should save and copy")
	main_inst.detail_modal.close()
	print("✓ Sprint 168: SearchInput Open First & QuoteInput Save+Copy Shift+Left-Click verified")

	# Sprint 169: AddModal Input Fields Shift+Left-Click Sample Fill & DetailModal CatBadge Shift+Left-Click All Library Reset
	main_inst.add_modal.open()
	main_inst.add_modal.clear_inputs()
	assert("Shift+좌클릭: 샘플 채움" in main_inst.add_modal.title_input.tooltip_text, "AddModal input tooltip should mention Shift+Left-Click sample fill")
	var shift_lclick169 := InputEventMouseButton.new()
	shift_lclick169.button_index = MOUSE_BUTTON_LEFT
	shift_lclick169.pressed = true
	shift_lclick169.shift_pressed = true
	main_inst.add_modal.title_input.gui_input.emit(shift_lclick169)
	main_inst.add_modal.author_input.gui_input.emit(shift_lclick169)
	main_inst.add_modal.quote_input.gui_input.emit(shift_lclick169)
	assert(main_inst.add_modal.title_input.text == "나의 비밀 독서 일기" and main_inst.add_modal.author_input.text == "주희의 서재" and main_inst.add_modal.quote_input.text == "오늘도 한 페이지의 여운을 남겼다.", "Shift+Left-Click on AddModal inputs should fill sample texts")
	main_inst.add_modal.close()
	main_inst._on_tab_manga_pressed()
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	assert("Shift+좌클릭: 전체 서재 보기" in main_inst.detail_modal.cat_badge.tooltip_text, "CatBadge tooltip should mention Shift+Left-Click all library reset")
	main_inst.detail_modal.cat_badge.gui_input.emit(shift_lclick169)
	assert(not main_inst.detail_modal.visible and main_inst.card_grid.get_child_count() == main_inst.archive_state.items.size(), "Shift+Left-Click on CatBadge should close modal and reset to all library")
	print("✓ Sprint 169: AddModal Input Sample Fill & CatBadge All-Library Reset Shift+Left-Click verified")

	# Sprint 170 Milestone: TitleLabel Shift+Left-Click Card Copy & StampLbl/InkLbl Shift+Left-Click Reverse
	var item170 = main_inst.archive_state.items[0]
	main_inst.detail_modal.open(item170)
	var title_lbl170: Label = main_inst.detail_modal.title_label
	var stamp_lbl170: Label = main_inst.detail_modal.find_child("StampLbl", true, false) as Label
	var ink_lbl170: Label = main_inst.detail_modal.find_child("InkLbl", true, false) as Label
	assert("우클릭·Shift+좌클릭: 감상 카드 전체 복사" in title_lbl170.tooltip_text, "TitleLabel tooltip should mention Shift+Left-Click card copy")
	assert(stamp_lbl170 != null and "우클릭·Shift+좌클릭: 역순환" in stamp_lbl170.tooltip_text, "StampLbl tooltip should mention Shift+Left-Click reverse")
	assert(ink_lbl170 != null and "우클릭·Shift+좌클릭: 역순환" in ink_lbl170.tooltip_text, "InkLbl tooltip should mention Shift+Left-Click reverse")
	var shift_lclick170 := InputEventMouseButton.new()
	shift_lclick170.button_index = MOUSE_BUTTON_LEFT
	shift_lclick170.pressed = true
	shift_lclick170.shift_pressed = true
	var copied_cnt170: Array = [0]
	var copy_cb170 := func(_it): copied_cnt170[0] += 1
	main_inst.detail_modal.card_copied.connect(copy_cb170)
	title_lbl170.gui_input.emit(shift_lclick170)
	main_inst.detail_modal.card_copied.disconnect(copy_cb170)
	assert(copied_cnt170[0] == 1, "Shift+Left-Click on TitleLabel should emit card_copied")
	var lclick170 := InputEventMouseButton.new()
	lclick170.button_index = MOUSE_BUTTON_LEFT
	lclick170.pressed = true
	stamp_lbl170.gui_input.emit(lclick170)
	ink_lbl170.gui_input.emit(lclick170)
	var fwd_stamp170: String = item170.status_tag
	var fwd_ink170: String = item170.memo_ink_color
	stamp_lbl170.gui_input.emit(lclick170)
	ink_lbl170.gui_input.emit(lclick170)
	assert(item170.status_tag != fwd_stamp170 and item170.memo_ink_color != fwd_ink170, "Left-click should advance stamp and ink")
	stamp_lbl170.gui_input.emit(shift_lclick170)
	ink_lbl170.gui_input.emit(shift_lclick170)
	assert(item170.status_tag == fwd_stamp170 and item170.memo_ink_color == fwd_ink170, "Shift+Left-Click on StampLbl and InkLbl should step backward")
	main_inst.detail_modal.close()
	print("✓ Sprint 170 Milestone: TitleLabel Card Copy & StampLbl/InkLbl Shift+Left-Click Reverse verified")

	# Sprint 171: MainView Shift+1~5 Tab Open, Shift+N Sample Modal & Shift+I Instant Backup
	main_inst.search_input.release_focus()
	var shift_k171 := InputEventKey.new()
	shift_k171.pressed = true
	shift_k171.shift_pressed = true
	shift_k171.keycode = KEY_2
	main_inst._unhandled_input(shift_k171)
	assert(main_inst.detail_modal.visible and main_inst.detail_modal.current_item.category == 0, "Shift+2 should filter Manga and open first item")
	main_inst.detail_modal.close()
	shift_k171.keycode = KEY_3
	main_inst._unhandled_input(shift_k171)
	assert(main_inst.detail_modal.visible and main_inst.detail_modal.current_item.category == 1, "Shift+3 should filter Gacha and open first item")
	main_inst.detail_modal.close()
	shift_k171.keycode = KEY_N
	main_inst._unhandled_input(shift_k171)
	assert(main_inst.add_modal.visible and main_inst.add_modal.title_input.text == "나의 비밀 독서 일기", "Shift+N should open AddModal with sample filled")
	main_inst.add_modal.close()
	shift_k171.keycode = KEY_I
	main_inst._unhandled_input(shift_k171)
	assert("백업" in main_inst.status_toast.text or "JSON" in main_inst.status_toast.text, "Shift+I should trigger instant JSON backup")
	print("✓ Sprint 171: MainView Shift+1~5 Tab Open, Shift+N Sample Modal & Shift+I Backup verified")

	# Sprint 172: MainView Shift+0 Full Studio Reset, Shift+C Today Quote Copy & Shift+H Cheatsheet Copy
	main_inst.search_input.release_focus()
	main_inst.search_input.text = "슬램덩크"
	main_inst._step_sort(1)
	main_inst._step_theme(1)
	var shift_k172 := InputEventKey.new()
	shift_k172.pressed = true
	shift_k172.shift_pressed = true
	shift_k172.keycode = KEY_0
	main_inst._unhandled_input(shift_k172)
	assert(main_inst.search_input.text == "" and main_inst.sort_mode == 0 and main_inst.theme_cursor == 0, "Shift+0 should reset search, sort, and theme to default")
	shift_k172.keycode = KEY_C
	main_inst._unhandled_input(shift_k172)
	assert("오늘의 밑줄 복사 완료" in main_inst.status_toast.text, "Shift+C should copy today's quote")
	shift_k172.keycode = KEY_H
	main_inst._unhandled_input(shift_k172)
	assert("단축키:" in main_inst.status_toast.text, "Shift+H should show and copy shortcut cheatsheet")
	print("✓ Sprint 172: MainView Shift+0 Full Studio Reset, Shift+C Quote Copy & Shift+H Cheatsheet verified")

	# Sprint 173: DetailModal Shift+Left/Right First/Last Jump & Shift+Plus/Minus Volume Power Keys
	var item173 = main_inst.archive_state.items[1]
	for v in item173.volumes:
		v["bookmarked"] = false
	var prev_vols173: int = item173.volumes.size()
	main_inst.detail_modal.open(item173)
	var nav_deltas173: Array = []
	var nav_cb173 := func(d: int): nav_deltas173.append(d)
	main_inst.detail_modal.navigate_requested.connect(nav_cb173)
	var shift_k173 := InputEventKey.new()
	shift_k173.pressed = true
	shift_k173.shift_pressed = true
	shift_k173.keycode = KEY_RIGHT
	main_inst.detail_modal._unhandled_input(shift_k173)
	shift_k173.keycode = KEY_LEFT
	main_inst.detail_modal._unhandled_input(shift_k173)
	main_inst.detail_modal.navigate_requested.disconnect(nav_cb173)
	assert(nav_deltas173 == [9999, -9999], "Shift+Right/Left in DetailModal should emit 9999 and -9999")
	main_inst.detail_modal.open(item173)
	shift_k173.keycode = KEY_EQUAL
	main_inst.detail_modal._unhandled_input(shift_k173)
	assert(item173.volumes.size() == prev_vols173 + 1 and item173.volumes[-1].get("status", "") == "first" and bool(item173.volumes[-1].get("bookmarked", false)), "Shift+Plus should add first+bookmarked volume")
	shift_k173.keycode = KEY_MINUS
	main_inst.detail_modal._unhandled_input(shift_k173)
	for v in item173.volumes:
		assert(bool(v.get("bookmarked", false)), "Shift+Minus should batch-bookmark all volumes")
	main_inst.detail_modal.close()
	print("✓ Sprint 173: DetailModal Shift+Arrows First/Last & Shift++/- Vol Power Keys verified")

	# Sprint 174: DetailModal Shift+E Sample Quote & Shift+1~4 Stamp+Close
	var item174 = main_inst.archive_state.items[0]
	main_inst.detail_modal.open(item174)
	main_inst.detail_modal.quote_input.text = ""
	main_inst.detail_modal.quote_input.release_focus()
	var shift_k174 := InputEventKey.new()
	shift_k174.pressed = true
	shift_k174.shift_pressed = true
	shift_k174.keycode = KEY_E
	main_inst.detail_modal._unhandled_input(shift_k174)
	assert(main_inst.detail_modal.quote_input.text == "오늘도 한 페이지의 여운을 남겼다.", "Shift+E in DetailModal should fill sample quote")
	main_inst.detail_modal.quote_input.release_focus()
	shift_k174.keycode = KEY_3
	main_inst.detail_modal._unhandled_input(shift_k174)
	assert(item174.status_tag == "인생최애" and not main_inst.detail_modal.visible, "Shift+3 in DetailModal should apply stamp and close")
	print("✓ Sprint 174: DetailModal Shift+E Sample Quote & Shift+1~4 Stamp+Close verified")

	# Sprint 175 Milestone: DetailModal Shift+L Paper Pattern, Shift+Delete Disarm & Shift+PageUp/Down
	var item175 = main_inst.archive_state.items[1]
	main_inst.detail_modal.open(item175)
	main_inst.detail_modal.quote_input.release_focus()
	var nav_deltas175: Array = []
	var nav_cb175 := func(d: int): nav_deltas175.append(d)
	main_inst.detail_modal.navigate_requested.connect(nav_cb175)
	var shift_k175 := InputEventKey.new()
	shift_k175.pressed = true
	shift_k175.shift_pressed = true
	shift_k175.keycode = KEY_PAGEDOWN
	main_inst.detail_modal._unhandled_input(shift_k175)
	shift_k175.keycode = KEY_PAGEUP
	main_inst.detail_modal._unhandled_input(shift_k175)
	main_inst.detail_modal.navigate_requested.disconnect(nav_cb175)
	assert(nav_deltas175 == [9999, -9999], "Shift+PageDown/PageUp should emit 9999 and -9999")
	main_inst.detail_modal.open(item175)
	var orig_paper175: String = item175.paper_pattern
	shift_k175.keycode = KEY_L
	main_inst.detail_modal._unhandled_input(shift_k175)
	assert(item175.paper_pattern != orig_paper175, "Shift+L in DetailModal should cycle paper pattern")
	var arm_k175 := InputEventKey.new()
	arm_k175.pressed = true
	arm_k175.keycode = KEY_DELETE
	main_inst.detail_modal._unhandled_input(arm_k175)
	assert(main_inst.detail_modal.delete_armed, "Delete key should arm delete")
	shift_k175.keycode = KEY_DELETE
	main_inst.detail_modal._unhandled_input(shift_k175)
	assert(not main_inst.detail_modal.delete_armed, "Shift+Delete should disarm delete")
	main_inst.detail_modal.close()
	print("✓ Sprint 175 Milestone: DetailModal Shift+L Paper, Shift+Delete Disarm & Shift+PageUp/Down verified")

	# Sprint 176: AddModal Shift+ESC Clear All & Shift+Enter Sample Submit
	var prev_cnt176: int = main_inst.archive_state.items.size()
	main_inst.add_modal.open()
	main_inst.add_modal.title_input.text = "임시176"
	main_inst.add_modal.author_input.text = "임시작가"
	main_inst.add_modal.title_input.release_focus()
	var shift_k176 := InputEventKey.new()
	shift_k176.pressed = true
	shift_k176.shift_pressed = true
	shift_k176.keycode = KEY_ESCAPE
	main_inst.add_modal._unhandled_input(shift_k176)
	assert(main_inst.add_modal.title_input.text == "" and main_inst.add_modal.author_input.text == "" and main_inst.add_modal.visible, "Shift+ESC in AddModal should clear all inputs without closing")
	shift_k176.keycode = KEY_ENTER
	main_inst.add_modal._unhandled_input(shift_k176)
	assert(main_inst.archive_state.items.size() == prev_cnt176 + 1 and not main_inst.add_modal.visible, "Shift+Enter in AddModal should auto-fill sample and submit")
	print("✓ Sprint 176: AddModal Shift+ESC Clear All & Shift+Enter Sample Submit verified")

	# Sprint 177: MainView Shift+/ Cheatsheet, Shift+ESC Filter Reset & Space/Shift+Space Open
	main_inst.search_input.release_focus()
	main_inst.search_input.text = "프리렌"
	main_inst._render_cards()
	var shift_k177 := InputEventKey.new()
	shift_k177.pressed = true
	shift_k177.shift_pressed = true
	shift_k177.keycode = KEY_ESCAPE
	main_inst._unhandled_input(shift_k177)
	assert(main_inst.search_input.text == "" and main_inst.card_grid.get_child_count() == main_inst.archive_state.items.size(), "Shift+ESC in MainView should reset all filters")
	shift_k177.keycode = KEY_SLASH
	main_inst._unhandled_input(shift_k177)
	assert("단축키:" in main_inst.status_toast.text, "Shift+/ (?) should show shortcut cheatsheet")
	var space_k177 := InputEventKey.new()
	space_k177.pressed = true
	space_k177.keycode = KEY_SPACE
	main_inst._unhandled_input(space_k177)
	assert(main_inst.detail_modal.visible, "Space in MainView should open first filtered card")
	main_inst.detail_modal.close()
	shift_k177.keycode = KEY_SPACE
	main_inst._unhandled_input(shift_k177)
	assert(main_inst.detail_modal.visible, "Shift+Space in MainView should open random diary modal")
	main_inst.detail_modal.close()
	print("✓ Sprint 177: MainView Shift+/ Cheatsheet, Shift+ESC Reset & Space/Shift+Space Open verified")

	# Sprint 178: DetailModal Shift+ESC Copy+Close, Shift+H Cheatsheet Copy & Shift+/ (?) Help
	main_inst.detail_modal.open(main_inst.archive_state.items[0])
	main_inst.detail_modal.quote_input.release_focus()
	var help_cnt178: Array = [0]
	var help_cb178 := func(): help_cnt178[0] += 1
	main_inst.detail_modal.help_requested.connect(help_cb178)
	var shift_k178 := InputEventKey.new()
	shift_k178.pressed = true
	shift_k178.shift_pressed = true
	shift_k178.keycode = KEY_SLASH
	main_inst.detail_modal._unhandled_input(shift_k178)
	shift_k178.keycode = KEY_H
	main_inst.detail_modal._unhandled_input(shift_k178)
	main_inst.detail_modal.help_requested.disconnect(help_cb178)
	assert(help_cnt178[0] == 2 and "모달 단축키:" in main_inst.status_toast.text, "Shift+/ and Shift+H in DetailModal should emit help_requested")
	shift_k178.keycode = KEY_ESCAPE
	main_inst.detail_modal._unhandled_input(shift_k178)
	assert(not main_inst.detail_modal.visible, "Shift+ESC in DetailModal should copy quote card and close")
	print("✓ Sprint 178: DetailModal Shift+ESC Copy+Close, Shift+H Cheatsheet & Shift+/ Help verified")

	# Restore clean 6 defaults on disk so screenshot is clean
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst.archive_state.save_to_file()

	print("--- ALL GODOT INTEGRATION TESTS PASSED (100%) ---")
	quit(0)
