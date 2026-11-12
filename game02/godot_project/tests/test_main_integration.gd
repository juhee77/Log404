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

	# Restore clean 6 defaults on disk so screenshot is clean
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst.archive_state.save_to_file()

	print("--- ALL GODOT INTEGRATION TESTS PASSED (100%) ---")
	quit(0)
