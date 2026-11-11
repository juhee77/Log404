extends SceneTree

func _init() -> void:
	print("--- Running Godot ArchiveState Tests (Sprint 6) ---")
	var state = load("res://scripts/archive_state.gd").new()
	state.reset_to_rich_defaults()

	# Test 1: 6 rich defaults initialized
	assert(state.items.size() == 6, "Default items size should be 6")
	assert(state.selected_item != null, "Default selected item should not be null")
	assert(state.selected_item.title == "슬램덩크 신장재편판", "First item should be Slam Dunk")
	assert(state.selected_item.cover_color == "#e11d48", "Cover color should be crimson")
	assert(state.selected_item.obi_text != "", "Obi text should be populated")
	print("✓ Test 1: 6 rich default items with colors & Obi bands verified")

	# Test 2: Filtering
	var mangas = state.get_filtered_items(0)
	assert(mangas.size() == 4, "Should have 4 mangas")
	var gachas = state.get_filtered_items(1)
	assert(gachas.size() == 2, "Should have 2 gachas")
	var search_slam = state.get_filtered_items(-1, "슬램")
	assert(search_slam.size() == 1, "Search should return 1 item")
	print("✓ Test 2: Filtering & search verified")

	# Test 3: Total stats
	var vols = state.get_total_volumes()
	assert(vols == 10, "Total volumes should be 3 + 3 + 2 + 2 = 10")
	var firsts = state.get_first_editions_count()
	assert(firsts == 7, "Total first editions should be 7")
	print("✓ Test 3: Stats calculations verified")

	# Test 4: Web Preset Scrape & Add/Remove
	var scraped = state.scrape_web_preset(0)
	assert(state.items.size() == 7, "Items size should be 7 after web scrape")
	assert(scraped.title.contains("슬램덩크"), "Scraped preset title verified")
	state.remove_item(scraped.id)
	assert(state.items.size() == 6, "Items size should return to 6 after removal")
	print("✓ Test 4: Web Scrape & Remove operations verified")

	print("--- ALL GODOT ARCHIVE STATE TESTS PASSED (100%) ---")
	quit(0)
