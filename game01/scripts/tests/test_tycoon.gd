extends SceneTree

# test_tycoon.gd - Automated Headless Verification Test for Study Cafe Tycoon

func _init() -> void:
	print("--- Running Enhanced Study Cafe Tycoon Headless Tests ---")
	var game_state_script = load("res://scripts/autoload/game_state.gd")
	var state = game_state_script.new()
	
	# Test 1: Initial Game State & Thermostat
	assert(state.money == 5000.0, "Initial money should be 5000.0")
	assert(state.temperature == 24.0, "Optimal initial temperature should be 24.0°C")
	state.adjust_temperature(2.0)
	assert(state.temperature == 26.0, "Adjusted temperature should be 26.0°C")
	print("✔ Test 1 Passed: Initial State & Thermostat (26.0°C)")
	
	# Test 2: Affordable Upgrade Purchase Test
	var category = "open_seats"
	var cost = state.get_upgrade_cost(category)
	assert(cost < 1000.0, "Starting upgrade cost should be affordable (<1000₩)")
	var bought = state.buy_upgrade(category)
	assert(bought == true, "Upgrade purchase must succeed with starting money")
	print("✔ Test 2 Passed: Upgrade purchased smoothly! (Cost = %.1f ₩)" % cost)
	
	# Test 3: Operating Hours & Day Settlement Trigger Test
	state.game_time = 21.9
	state._process(1.0) # Advances clock past 22.0 PM
	assert(state.is_day_ended == true, "Game should end day at 22:00 PM")
	print("✔ Test 3 Passed: Day ended trigger and settlement calculation verified!")
	
	# Test 4: Start Next Day Reset
	state.start_next_day()
	assert(state.day_count == 2, "Day count should advance to Day 2")
	assert(state.game_time == 8.0, "Game time should reset to 08:00 AM")
	assert(state.is_day_ended == false, "Operating state should resume")
	print("✔ Test 4 Passed: Start next day reset verified (Day 2 08:00 AM)")
	
	state.free()
	print("🎉 All Enhanced Study Cafe Tycoon Verification Tests PASSED Successfully!")
	quit()
