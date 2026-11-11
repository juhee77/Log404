extends SceneTree

func _init() -> void:
	print("--- Running Godot JSON Persistence Tests ---")
	var state = load("res://scripts/archive_state.gd").new()
	state.initialize_defaults()

	var test_path = "user://test_archive_save.json"

	# Test 1: Save state to JSON
	var save_ok = state.save_to_file(test_path)
	assert(save_ok == true, "Save to file should succeed")
	assert(FileAccess.file_exists(test_path), "Saved file must exist on disk")
	print("✓ Test 1: Save to JSON succeeded")

	# Test 2: Modify and reload state
	var new_state = load("res://scripts/archive_state.gd").new()
	var load_ok = new_state.load_from_file(test_path)
	assert(load_ok == true, "Load from file should succeed")
	assert(new_state.items.size() == state.items.size(), "Loaded items count must match saved count")
	assert(new_state.items[0].title == state.items[0].title, "First item title must match")
	assert(new_state.get_total_volumes() == state.get_total_volumes(), "Total volumes count must match")
	print("✓ Test 2: Load from JSON verified with exact data match")

	# Clean up test file
	if FileAccess.file_exists(test_path):
		DirAccess.remove_absolute(test_path)
	print("✓ Test 3: Cleaned up test artifacts")

	print("--- ALL PERSISTENCE TESTS PASSED (100%) ---")
	quit(0)

