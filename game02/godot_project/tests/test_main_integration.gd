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

	# Restore clean 6 defaults on disk so screenshot is clean
	main_inst.archive_state.reset_to_rich_defaults()
	main_inst.archive_state.save_to_file()

	print("--- ALL GODOT INTEGRATION TESTS PASSED (100%) ---")
	quit(0)
