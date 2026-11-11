extends SceneTree

func _init() -> void:
	print("--- Running Main Scene Headless Load & Integration Test ---")
	var main_packed = load("res://scenes/main.tscn")
	assert(main_packed != null, "main.tscn failed to load")
	
	var main_inst = main_packed.instantiate()
	assert(main_inst != null, "main.tscn failed to instantiate")
	root.add_child(main_inst)
	
	# Wait for ready
	if not main_inst.is_node_ready():
		await main_inst.ready

	# Check initial UI elements
	assert(main_inst.archive_state != null, "archive_state should be initialized")
	assert(main_inst.card_grid.get_child_count() == 3, "Card grid should show 3 cards initially")
	print("✓ Initial 3 cards populated in GridContainer")
	
	# Test Filter Manga
	main_inst._on_tab_manga_pressed()
	assert(main_inst.card_grid.get_child_count() == 2, "Card grid should show 2 cards when filtered to Manga")
	print("✓ Filter to Manga verified (2 cards)")

	# Test Search
	main_inst.search_input.text = "슬램"
	main_inst._on_search_text_changed("슬램")
	assert(main_inst.card_grid.get_child_count() == 1, "Card grid should show 1 card matching search")
	print("✓ Search filter verified (1 card)")

	# Test Add Item
	main_inst._on_item_submitted("귀멸의 칼날", 0, "고토게 코요하루")
	assert(main_inst.archive_state.items.size() == 4, "Total items should be 4 after submit")
	print("✓ Add item flow verified")

	print("--- ALL GODOT INTEGRATION TESTS PASSED (100%) ---")
	quit(0)
