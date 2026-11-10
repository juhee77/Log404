extends SceneTree

func _init() -> void:
	print("--- Running Godot ArchiveState Tests ---")
	var state = load("res://scripts/archive_state.gd").new()
	state.initialize_defaults()

	# Test 1: Defaults initialized
	assert(state.items.size() == 3, "Default items size should be 3")
	assert(state.selected_item != null, "Default selected item should not be null")
	assert(state.selected_item.title == "슬램덩크 신장재편판", "First item should be Slam Dunk")
	print("✓ Test 1: Initial state verified")

	# Test 2: Filtering
	var mangas = state.get_filtered_items(0) # 0 is Category.MANGA
	assert(mangas.size() == 2, "Should have 2 mangas")
	var gachas = state.get_filtered_items(1) # 1 is Category.GACHA
	assert(gachas.size() == 1, "Should have 1 gacha")
	var search_slam = state.get_filtered_items(-1, "슬램")
	assert(search_slam.size() == 1, "Search should return 1 item")
	print("✓ Test 2: Filtering & search verified")

	# Test 3: Total stats
	var vols = state.get_total_volumes()
	assert(vols == 5, "Total volumes should be 3 + 2 = 5")
	var firsts = state.get_first_editions_count()
	assert(firsts == 3, "Total first editions should be 2 (Slam Dunk) + 1 (Frieren) = 3")
	print("✓ Test 3: Stats calculations verified")

	# Test 4: Add and remove
	var new_book = state.add_item("체인소 맨", 0, "후지모토 타츠키")
	assert(state.items.size() == 4, "Items size should be 4 after adding")
	assert(state.items[0].title == "체인소 맨", "New item should be at front")
	state.remove_item(new_book.id)
	assert(state.items.size() == 3, "Items size should return to 3 after removal")
	print("✓ Test 4: Add & Remove operations verified")

	print("--- ALL GODOT TESTS PASSED (100%) ---")
	quit(0)
