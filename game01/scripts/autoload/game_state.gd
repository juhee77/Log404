extends Node

# GameState.gd - Master Tycoon Engine with Lounge Customer Break System & Achievements

signal money_changed(new_amount, change)
signal reputation_changed(new_reputation)
signal upgrade_purchased(category, new_level)
signal customer_arrived(customer_info)
signal customer_left(customer_info, earnings)
signal review_added(review_data)
signal order_created(customer_id, order_type)
signal order_served(customer_id, tip)
signal villain_appeared(customer_id, villain_type)
signal villain_resolved(customer_id)
signal seat_dirty(seat_index)
signal seat_cleaned(seat_index)
signal temperature_changed(new_temp)
signal time_of_day_changed(new_tod)
signal weather_changed(new_weather)
signal day_ended(summary_data)
signal zone_changed(new_zone)
signal floor_changed(new_floor)
signal decor_mode_changed(is_active)
signal achievement_unlocked(title, reward)
signal theme_changed(new_theme)
signal tech_systems_requested()


# Financial & Time Variables
# Iteration 108: Mobile Responsive Engine & Clean Build Verified

var money: float = 50000.0
var total_earnings: float = 0.0
var reputation: float = 4.2
var day_count: int = 1
var exam_d_day: int = 100
var game_time: float = 8.0
var time_of_day: String = "DAY"
var weather: String = "RAINY"
var weather_timer: float = 0.0

# Multi-Floor Building Systems (1F, 2F, 3F)
var current_floor: int = 1
var unlocked_floors: Array = [1]

# Current Active Map Zone ("study", "lounge", "front")
var current_zone: String = "study"

# Mascot Cat Position & Animated Path
var cat_pos: Vector2 = Vector2(420, 380)
var cat_target: Vector2 = Vector2(420, 380)
var cat_patrol_timer: float = 0.0

# Achievements Tracking
var achievements: Dictionary = {
	"first_10k": { "title": "🏆 누적 매출 10,000₩ 달성!", "reward": 1000.0, "unlocked": false },
	"high_reputation": { "title": "⭐ 스터디 카페 평점 4.8 돌파!", "reward": 1500.0, "unlocked": false },
	"master_visitors": { "title": "👥 누적 손님 20명 돌파!", "reward": 2000.0, "unlocked": false },
	"hall_of_fame": { "title": "👑 스터디 카페 명예의 전당 등극!", "reward": 5000.0, "unlocked": false },
	"study_marathon": { "title": "🏆 전국 스터디 마라톤 챔피언십 우승!", "reward": 10000.0, "unlocked": false }
}

# I Love Coffee Core Engine Signals & Data Structures
signal beans_changed(new_amount)
signal roaster_updated(index, data)
signal oven_updated(index, data)
signal quest_updated(quest_info)
signal intimacy_changed(guest_name, level, xp)

# 1. Bean Economy & Roasting Machines
var beans_inventory: int = 500
var roasters: Array = [
	{ "id": 0, "type": "santos", "name": "브라질 산토스", "timer": 0.0, "max_time": 45.0, "yield": 100, "xp": 10, "state": "IDLE" },
	{ "id": 1, "type": "supremo", "name": "콜롬비아 수프레모", "timer": 0.0, "max_time": 300.0, "yield": 400, "xp": 45, "state": "IDLE" },
	{ "id": 2, "type": "yirgacheffe", "name": "에티오피아 예가체프", "timer": 0.0, "max_time": 900.0, "yield": 1200, "xp": 140, "state": "IDLE" },
	{ "id": 3, "type": "antigua", "name": "과테말라 안티구아", "timer": 0.0, "max_time": 3600.0, "yield": 4500, "xp": 500, "state": "IDLE" }
]

# 2. Bakery Ovens
var bakery_ovens: Array = [
	{ "id": 0, "type": "croissant", "name": "플레인 크로와상", "timer": 0.0, "max_time": 180.0, "yield": 5, "price": 350.0, "state": "IDLE" },
	{ "id": 1, "type": "cheesecake", "name": "블루베리 치즈케이크", "timer": 0.0, "max_time": 900.0, "yield": 10, "price": 1800.0, "state": "IDLE" }
]

# 3. Regular Guests Intimacy (❤️)
var guest_intimacy: Dictionary = {
	"suhyun": { "name": "수험생 수현", "level": 1, "xp": 0, "max_xp": 100, "title": "초보 열공생" },
	"su_hyun": { "name": "수험생 수현", "level": 1, "xp": 0, "max_xp": 100, "title": "초보 열공생" },
	"minjun": { "name": "취준생 민준", "level": 1, "xp": 0, "max_xp": 100, "title": "열혈 서류 준비생" },
	"min_jun": { "name": "취준생 민준", "level": 1, "xp": 0, "max_xp": 100, "title": "열혈 서류 준비생" },
	"hyunwoo": { "name": "개발자 현우", "level": 1, "xp": 0, "max_xp": 100, "title": "코딩 에이스" },
	"hyun_woo": { "name": "개발자 현우", "level": 1, "xp": 0, "max_xp": 100, "title": "코딩 에이스" },
	"navi": { "name": "길냥이 나비", "level": 1, "xp": 0, "max_xp": 100, "title": "스터디 힐러" }
}

# 4. Decor Score (🌟) & Manager Level (XP)
var decor_score: int = 450
var manager_level: int = 1
var manager_xp: int = 0
var max_manager_xp: int = 500

# 5. Main Story Quests (50 Stages)
var current_quest_index: int = 1
var quests_data: Array = [
	{ "id": 1, "title": "☕ 브라질 산토스 원두 1회 로스팅하기", "target": 1, "current": 0, "reward_money": 1000.0, "reward_xp": 50 },
	{ "id": 2, "title": "🥐 아침 크로와상 1회 오븐 베이킹하기", "target": 1, "current": 0, "reward_money": 2000.0, "reward_xp": 100 },
	{ "id": 3, "title": "🚶 길거리 손님 캐스팅 1회 성공하기", "target": 1, "current": 0, "reward_money": 3000.0, "reward_xp": 150 },
	{ "id": 4, "title": "🌟 꾸미기 점수 600점 달성하기", "target": 600, "current": 450, "reward_money": 5000.0, "reward_xp": 300 }
]

# Interior Decorating Mode & Custom Partitions
var is_decorating_mode: bool = false
var custom_decorations: Array = []
var seat_partitions: Dictionary = {}
var seat_custom_offsets: Dictionary = {}
var lamp_states: Dictionary = {}

# Barista Special Coffee Menu & Air Quality Index
var coffee_menu_unlocked: Array = ["아메리카노", "카페라떼", "아인슈페너", "돌체라떼"]
var air_quality_score: float = 98.0

func _play_sfx_safe(type: String) -> void:
	if not is_inside_tree():
		return
	var sm = get_node_or_null("/root/SoundManager")
	if sm != null:
		if type == "click": sm.play_click_sfx()
		elif type == "coin": sm.play_coin_sfx()
		elif type == "chime": sm.play_chime_sfx()


func toggle_seat_lamp(seat_index: int) -> bool:
	var cur = lamp_states.get(seat_index, true)
	lamp_states[seat_index] = not cur
	_play_sfx_safe("click")
	return lamp_states[seat_index]

func set_seat_offset(seat_index: int, offset: Vector2) -> void:
	seat_custom_offsets[seat_index] = offset
	save_game()

func install_partition(seat_index: int, type: String = "divider") -> bool:
	var cost = 300.0
	if not can_afford(cost): return false
	add_money(-cost)
	seat_partitions[seat_index] = type
	reputation = min(5.0, reputation + 0.1)
	reputation_changed.emit(reputation)
	_play_sfx_safe("coin")
	return true

func start_roasting(roaster_idx: int) -> bool:
	if roaster_idx < 0 or roaster_idx >= roasters.size(): return false
	var r = roasters[roaster_idx]
	if r["state"] != "IDLE": return false
	r["state"] = "ROASTING"
	r["timer"] = r["max_time"]
	roaster_updated.emit(roaster_idx, r)
	_play_sfx_safe("click")
	return true

func harvest_beans(roaster_idx: int) -> bool:
	if roaster_idx < 0 or roaster_idx >= roasters.size(): return false
	var r = roasters[roaster_idx]
	if r["state"] != "READY": return false
	beans_inventory += r["yield"]
	beans_changed.emit(beans_inventory)
	add_manager_xp(r["xp"])
	r["state"] = "IDLE"
	roaster_updated.emit(roaster_idx, r)
	_play_sfx_safe("coin")
	
	if current_quest_index == 1:
		update_quest_progress(1)
	return true

func repair_burnt_beans(roaster_idx: int) -> bool:
	if roaster_idx < 0 or roaster_idx >= roasters.size(): return false
	var r = roasters[roaster_idx]
	if r["state"] != "BURNT": return false
	var cost = 100.0
	if not can_afford(cost): return false
	add_money(-cost)
	beans_inventory += int(r["yield"] * 0.5)
	beans_changed.emit(beans_inventory)
	r["state"] = "IDLE"
	roaster_updated.emit(roaster_idx, r)
	_play_sfx_safe("coin")
	return true

func add_manager_xp(xp_amount: int) -> void:
	manager_xp += xp_amount
	if manager_xp >= max_manager_xp:
		manager_xp -= max_manager_xp
		manager_level += 1
		max_manager_xp = int(max_manager_xp * 1.5)
		_play_sfx_safe("chime")

func update_quest_progress(amount: int = 1) -> void:
	if current_quest_index - 1 < quests_data.size():
		var q = quests_data[current_quest_index - 1]
		q["current"] = min(q["target"], q["current"] + amount)
		if q["current"] >= q["target"]:
			add_money(q["reward_money"])
			add_manager_xp(q["reward_xp"])
			current_quest_index += 1
			_play_sfx_safe("chime")
		quest_updated.emit(q)

# Daily Statistics Counter
var daily_seat_rev: float = 0.0
var daily_drink_rev: float = 0.0
var daily_clean_rev: float = 0.0
var daily_visitors: int = 0

# Interactive Features & Amenities
var temperature: float = 24.0
var dirty_seats: Array = []
var active_orders: Dictionary = {}
var active_villains: Dictionary = {}

# Drink Recipes Book
var drink_recipes: Array = [
	{ "id": "espresso", "name": "에스프레소", "beans": 10, "price": 3000.0, "unlocked": true },
	{ "id": "americano", "name": "아이스 아메리카노", "beans": 15, "price": 4500.0, "unlocked": true },
	{ "id": "latte", "name": "카페 라떼", "beans": 20, "price": 5500.0, "unlocked": true },
	{ "id": "macchiato", "name": "카라멜 마키아또", "beans": 25, "price": 6500.0, "unlocked": false }
]

# Study Cafe Unique Mechanics: Quietness & Equipment Rental
var quietness_score: int = 98
var exam_dday: int = 7
var equipment_stock: Dictionary = {
	"bookstand": { "name": "원목 독서대", "count": 8, "fee": 500.0 },
	"headset": { "name": "노이즈 캔슬링 헤드셋", "count": 5, "fee": 1200.0 },
	"silent_mouse": { "name": "무소음 마우스", "count": 6, "fee": 400.0 },
	"charger": { "name": "고속 멀티 충전기", "count": 10, "fee": 300.0 },
	"cushion": { "name": "인체공학 메모리폼 방석", "count": 7, "fee": 600.0 },
	"eye_lamp": { "name": "시력보호 LED 독서등", "count": 6, "fee": 800.0 }
}

func rent_equipment(eq_id: String) -> bool:
	if not equipment_stock.has(eq_id): return false
	var eq = equipment_stock[eq_id]
	if eq["count"] <= 0: return false
	eq["count"] -= 1
	add_money(eq["fee"])
	_play_sfx_safe("coin")
	return true

func return_equipment(eq_id: String) -> void:
	if equipment_stock.has(eq_id):
		equipment_stock[eq_id]["count"] += 1

func resolve_noise_villain(villain_id: int) -> void:
	if active_villains.has(villain_id):
		active_villains.erase(villain_id)
		quietness_score = clamp(quietness_score + 3, 0, 100)
		add_money(800.0)
		_play_sfx_safe("chime")

# Realistic Study Cafe Atmosphere & Equipment Engines
var white_noise_db: float = 45.0
var ice_maker_stock: int = 100
var exam_archive_count: int = 12
var exam_archive_level: int = 1
var total_exam_papers_borrowed: int = 0
var desk_lamp_mode: String = "4000K"

func upgrade_exam_archive() -> bool:
	var cost = 1200.0 * exam_archive_level
	if not can_afford(cost): return false
	add_money(-cost)
	exam_archive_level += 1
	exam_archive_count += 5
	_play_sfx_safe("chime")
	return true

func borrow_exam_paper() -> Dictionary:
	if exam_archive_count <= 0:
		return { "success": false, "msg": "❌ 기출 족보가 모두 대여 중입니다!" }
	exam_archive_count -= 1
	total_exam_papers_borrowed += 1
	add_money(1200.0)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📚 전설의 기출 족보 대여 완료! (+1,200 ₩ 팁)" }

# VIP Monthly Fixed Membership & Organic Herbal Tea Bar Subsystems
var vip_members_count: int = 5
var herbal_tea_stock: int = 50

# Meeting Module 40: 4-Person Soundproof Group Study Room Subsystem
var group_study_room_count: int = 2
var group_study_bookings: int = 0

# Meeting Module 41: 25-5 Pomodoro Focus Timer Subsystem
var pomodoro_sessions_completed: int = 0
var pomodoro_focus_boost: float = 1.0

# Meeting Module 42: 85% Sugar-Free Cacao Dark Chocolate Dispenser Subsystem
var dark_chocolate_stock: int = 40
var dark_chocolate_sales: int = 0

# Meeting Module 43: Lavender & Eucalyptus Essential Oil Aroma Diffuser Subsystem
var aroma_diffuser_active: bool = true
var aroma_scent_type: String = "EUCALYPTUS"
var aroma_refill_count: int = 10

# Meeting Module 44: SNS Timestamp Study Challenge Subsystem
var sns_posts_count: int = 0
var viral_marketing_boost: float = 1.0

# Meeting Module 45: High-Capacity Ice Maker & Gourmet Fruit Ade Station Subsystem
var ade_syrup_stock: int = 60
var ade_sales_count: int = 0

# Meeting Module 46: Past Exam Question Bank & Mock Exam Archive Subsystem
var exam_papers_borrowed: int = 0
var student_satisfaction_boost: float = 1.0

# Meeting Module 48: Rainy Day Outdoor Window Droplet Rendering
# Handled in cafe_view.gd

# Meeting Module 49: National Hall of Fame Leaderboard Subsystem
var hall_of_fame_members: Array = [
	{ "name": "수험생 수현", "achievement": "서울대 의예과 합격", "focus_hours": 1420 },
	{ "name": "개발자 현우", "achievement": "구글 수석 엔지니어 입사", "focus_hours": 1280 }
]

# Meeting Module 50: Grand 50th-Milestone Landmark Party Celebration Subsystem
var milestone_celebration_active: bool = true
var grand_trophy_unlocked: bool = true

# Meeting Module 51: AI Mock Exam Weakness Analysis & Counseling Subsystem
var exam_counseling_sessions: int = 0
var mental_care_boost: float = 1.0

# Meeting Module 52: Hand-Drip Single Origin Specialty Coffee Bar Subsystem
var handdrip_coffee_stock: int = 50
var handdrip_sales_count: int = 0

# Meeting Module 53: Premium ANC Headphones Rental Station Subsystem
var anc_headphones_stock: int = 15
var anc_rentals_count: int = 0

# Meeting Module 54: Zero-Gravity Power Nap Capsule Subsystem
var nap_capsules_installed: int = 4
var nap_sessions_count: int = 0

# Meeting Module 55: AI Parent SMS Attendance Subsystem
var parent_sms_enabled: bool = true
var total_sms_sent: int = 0

# Meeting Module 56: Morning Croissant Brunch Subsystem
var morning_croissant_stock: int = 30
var morning_brunch_served: int = 0

func bake_morning_croissant() -> Dictionary:
	morning_croissant_stock += 20
	var fee = 4200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥐 갓 구운 오가닉 버터 크로와상 브런치 셀프바 충전 완료! (+4,200 ₩ | 얼리버드 유입 +35% 🌅)" }

# Meeting Module 57: Pass Exam Book Share Library Subsystem
var pass_books_donated: int = 12

func donate_pass_book(book_title: String = "2026 합격 수험서") -> Dictionary:
	pass_books_donated += 1
	decor_score += 15
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "📚 '%s' 합격 선배 나눔 서적 기증 완료! (인테리어 점수 +15 🌟 | 명성 UP)" % book_title }

# Meeting Module 58: Ultrawide Curved Monitor Desks Subsystem
var curved_monitors_count: int = 8

func upgrade_curved_monitors() -> Dictionary:
	curved_monitors_count += 2
	decor_score += 25
	add_money(5000.0)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🖥️ 34인치 WQHD 울트라와이드 커브드 몰입형 모니터 석 추가 완료! (+5,000 ₩ | 몰입도 100% ⚡)" }

# Meeting Module 59: Botanical Air Purifying Wall Subsystem
var botanical_wall_level: int = 3

func maintain_greenhouse_wall() -> Dictionary:
	botanical_wall_level += 1
	decor_score += 30
	reputation = min(5.0, reputation + 0.06)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌿 천연 수경재배 미세먼지 정화 식물벽 영양제 공급 완료! (실내 공기 질 점수 +35% 🍃)" }

# Meeting Module 60: Franchise League TOP 10 Hall of Fame Subsystem
func get_franchise_league_rank() -> Dictionary:
	var total_score = int(reputation * 200 + decor_score * 5 + money * 0.01)
	return { "rank": 1, "tier": "👑 전국 1위 명예의 전당 갓성비 스터디카페", "score": total_score }

# Meeting Module 61: Kelvin Color Temperature Adjustable Desk Lamp Subsystem
var current_kelvin_temp: int = 4500
var kelvin_tuners_installed: int = 24

# Meeting Module 62: Organic Protein Smoothie Bar Subsystem
var smoothie_stock: int = 25
var smoothies_sold: int = 0

# Meeting Module 63: Soundproof Group Meeting Room Subsystem
var meeting_rooms_count: int = 2
var meeting_room_reservations: int = 0

# Meeting Module 64: Study Goal Badge App Subsystem
var badges_unlocked: int = 5
var total_badge_rewards_claimed: int = 0

# Meeting Module 65: Belgian Truffle Chocolate Buffet Subsystem
var truffle_stock: int = 40
var truffles_served: int = 0

# Meeting Module 66: UV Desk Mat Sterilizer Subsystem
var uv_desk_mats_installed: int = 24
var uv_sterilizations_count: int = 0

# Meeting Module 67: Mascot Cat Wood Tower Subsystem
var cat_tower_installed: bool = true
var cat_tower_clicks: int = 0
var navi_intimacy: int = 50


func interact_cat_tower() -> Dictionary:
	cat_tower_clicks += 1
	var heal_val = 20
	navi_intimacy += heal_val
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🐱 마스코트 고양이 '나비'가 원목 캣타워 구름다리를 누빕니다! (친밀도 +20 🐾 | 힐링 가산 UP)" }

# Meeting Module 68: Rain & Ocean Soundscape Acoustic Tuner Subsystem
var active_soundscape: String = "RAIN_WOODS"

func tune_soundscape(mode: String = "OCEAN_WAVES") -> Dictionary:
	active_soundscape = mode
	decor_score += 20
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎧 백색소음 입체 사운드스케이프 [%s] 설정 완료! (몰입도 +30%% 🌊)" % mode }

# Meeting Module 69: National Study Marathon Championship Event Subsystem
var marathon_participants: int = 48
var marathon_completed: bool = false

func start_study_marathon() -> Dictionary:
	marathon_completed = true
	var prize = 15000.0
	add_money(prize)
	reputation = min(5.0, reputation + 0.1)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🏃‍♂️ [전국 24시간 열공 마라톤 대회] 참가 수험생 48명 완주! (+15,000 ₩ 상금 | 명성 폭발 🏆)" }

# Meeting Module 70: Grand 70th Milestone Celebration Event Subsystem
func trigger_70th_milestone_event() -> Dictionary:
	var bonus_money = 200000.0
	add_money(bonus_money)
	reputation = 5.0
	decor_score += 100
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🎉🎉 Log404 Studio 70개 전 모듈 대단원 달성 축하 파티! (+200,000 ₩ | 최고 명성 5.0 달성 👑)" }

# Meeting Module 71: Barista Latte Art Customizer Subsystem
var latte_art_creations: int = 0

# Meeting Module 72: Morning Croissant Toaster Oven Subsystem
var toasted_croissants_count: int = 0

# Meeting Module 73: Street Casting Quiz Minigame Subsystem
var street_casting_quizzes_solved: int = 0

# Meeting Module 74: Regular Guest Suhyun Intimacy Level Subsystem
var suhyun_intimacy_level: int = 4
var suhyun_interactions_count: int = 0

# Meeting Module 75: Regular Guest Minjun Intimacy Level Subsystem
var minjun_intimacy_level: int = 5
var minjun_interactions_count: int = 0

func interact_regular_minjun() -> Dictionary:
	minjun_interactions_count += 1
	minjun_intimacy_level += 1
	var prize = 4500.0
	add_money(prize)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "👨‍💻 [단골 개발자 민준] 코딩 디버깅 상담 완료! (+4,500 ₩ | 친밀도 Lv.%d 💖 | 밤샘 개발 버프 UP)" % minjun_intimacy_level }

# Meeting Module 76: Regular Guest Hyunwoo Intimacy Level Subsystem
var hyunwoo_intimacy_level: int = 3

func interact_regular_hyunwoo() -> Dictionary:
	hyunwoo_intimacy_level += 1
	var prize = 4500.0
	add_money(prize)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🧑‍💼 [단골 기획자 현우] 사업 로드맵 상담 완료! (+4,500 ₩ | 친밀도 Lv.%d 💖)" % hyunwoo_intimacy_level }

# Meeting Module 77: Mascot Cat Navi Churu Treats Subsystem
var churu_treats_stock: int = 15

func feed_navi_churu() -> Dictionary:
	churu_treats_stock += 10
	navi_intimacy += 50
	reputation = min(5.0, reputation + 0.06)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🐱 마스코트 '나비'에게 최고급 참치 츄르 간식을 급여했습니다! (친밀도 +50 🐾 | 매장 힐링 100%)" }

# Meeting Module 78: Interior Decor Rating Score Subsystem
func get_decor_rating_tier() -> String:
	if decor_score >= 500:
		return "💎 S-Tier 최고급 럭셔리 인테리어"
	elif decor_score >= 250:
		return "🌟 A-Tier 감성 원목 인테리어"
	return "🌿 B-Tier 모던 스터디 카페"

# Meeting Module 79: Store Territory Expansion Subsystem
var territory_expansion_level: int = 2

func expand_store_territory() -> Dictionary:
	territory_expansion_level += 1
	var cost = 50000.0
	if money >= cost:
		money -= cost
		decor_score += 80
		return { "success": true, "msg": "🏢 스터디 카페 매장 층수 확장 완료! (3층 오픈 | 인테리어 +80 🌟)" }
	return { "success": false, "msg": "자금이 부족합니다. (필요 자금: 50,000 ₩)" }

# Meeting Module 80: Main Story Quests Stage 01-10 Subsystem
var story_stage: int = 10

# Meeting Module 81: Main Story Quests Stage 11-20 Subsystem
var story_stage_2: int = 15

# Meeting Module 85: Staff Uniform Apron Wardrobe Subsystem
var active_staff_uniform: String = "MAHOGANY_OAK_APRON"
var unlocked_uniforms: Array = ["MAHOGANY_OAK_APRON", "DENIM_BARISTA_APRON"]

func equip_staff_uniform(uniform_id: String = "PASTEL_PINK_APRON") -> Dictionary:
	if not unlocked_uniforms.has(uniform_id):
		unlocked_uniforms.append(uniform_id)
	active_staff_uniform = uniform_id
	decor_score += 15
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "👔 바리스타 및 알바 직원 유니폼 [%s] 교체 완료! (매장 품격 +15 🌟 | 명성 UP)" % uniform_id }

func advance_story_stage_11_20() -> Dictionary:
	story_stage_2 += 1
	var reward = 15000.0
	add_money(reward)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "📖 메인 스토리 퀘스트 Chapter 2 (Stage %d) 완수! (+15,000 ₩ 스토리 챕터 보상 🎉)" % story_stage_2 }

func complete_story_stage() -> Dictionary:
	story_stage += 1
	var reward = 10000.0
	add_money(reward)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "📖 메인 스토리 퀘스트 Stage %d 완료! (+10,000 ₩ 스토리 보상 🎉)" % story_stage }

func interact_regular_suhyun() -> Dictionary:
	suhyun_interactions_count += 1
	suhyun_intimacy_level += 1
	var prize = 4200.0
	add_money(prize)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "👩‍🎓 [단골 수험생 수현] 상담 대화 완료! (+4,200 ₩ | 친밀도 Lv.%d 💖 | 합격 확신 버프 UP)" % suhyun_intimacy_level }

func conduct_street_casting_quiz(guest_name: String = "단골 공시생 수현") -> Dictionary:
	street_casting_quizzes_solved += 1
	var prize = 3800.0
	add_money(prize)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎯 길거리 [%s] 캐스팅 3단계 대화 퀴즈 성공! (+3,800 ₩ | 친밀도 +40 💖)" % guest_name }

func toast_croissant(pastry_name: String = "🥐 스팀 바삭 버터 크로와상") -> Dictionary:
	toasted_croissants_count += 1
	var price = 4500.0
	add_money(price)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍞 발뮤다 스팀 오븐 [%s] 3분 노릇노릇 굽기 완료! (+4,500 ₩ | 브런치 만족도 +30% 🥐)" % pastry_name }

func craft_latte_art(pattern: String = "🐱 귀여운 고양이 폼 아트") -> Dictionary:
	latte_art_creations += 1
	var price = 5200.0
	add_money(price)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ 바리스타 스페셜 [%s] 라떼 아트 완성! (+5,200 ₩ | 손님 감동 만족도 +25% ✨)" % pattern }

func sterilize_desk_mat(seat_idx: int = 0) -> Dictionary:
	uv_sterilizations_count += 1
	var fee = 3200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "✨ %d번 좌석 UV-C LED 자동 99.9%% 데스크 무균 소독 완료! (+3,200 ₩ | 위생 평점 UP 🛡️)" % (seat_idx + 1) }

func dispense_truffle_chocolate() -> Dictionary:
	truffles_served += 1
	var price = 3600.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍫 벨기에 85% 수제 다크 트러플 초콜릿 디저트 제공 완료! (+3,600 ₩ | 뇌 당분 충전 몰입도 +25% 🧠)" }

func claim_study_badge(badge_name: String = "🥇 하루 8시간 집중 골드 뱃지") -> Dictionary:
	total_badge_rewards_claimed += 1
	var bonus_reward = 2500.0
	add_money(bonus_reward)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "📱 [스마트 뱃지 앱] '%s' 획득 완료! (+2,500 ₩ 보상 | 재방문 연장률 +30% 🏆)" % badge_name }

func reserve_acoustic_meeting_room(hours: int = 2) -> Dictionary:
	meeting_room_reservations += 1
	var total_fee = 6500.0 * hours
	add_money(total_fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🗣️ 4인 전용 아쿠스틱 특수 흡음 완전 방음 미팅룸 %d시간 예약 완료! (+%s ₩ | 그룹 예약율 +30% 🚪)" % [hours, format_money(total_fee)] }

func blend_protein_smoothie(flavor: String = "아보카도 망고 프로틴") -> Dictionary:
	smoothies_sold += 1
	var price = 4800.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥤 100% 무설탕 %s 스무디 제조 완료! (+4,800 ₩ | 체력&집중력 +20% 🏋️‍♂️)" % flavor }

func tune_kelvin_lamp(kelvin_val: int = 6500) -> Dictionary:
	current_kelvin_temp = kelvin_val
	add_money(3500.0)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	var mode_name = "수학/이과 집중 (6500K 주광색)" if kelvin_val == 6500 else ("언어/독서 (4500K 주백색)" if kelvin_val == 4500 else "휴식/창의 (3000K 전구색)")
	return { "success": true, "msg": "💡 독서등 켈빈 색온도 튜닝 완료! [%s] (+3,500 ₩ | 학습 몰입도 +25% ⚡)" % mode_name }

func send_parent_sms_notification(student_name: String = "김수험", action_type: String = "입실") -> Dictionary:
	total_sms_sent += 1
	var fee = 400.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📱 [학부모 안심 SMS] %s 학생 %s 안심 알림톡 발송 완료! (+400 ₩ | 매장 신뢰도 UP ✨)" % [student_name, action_type] }

func use_nap_capsule() -> Dictionary:
	nap_sessions_count += 1
	var fee = 3000.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "😴 15분 무중력 파워 냅 암막 수면 캡슐 이용 완료! (+3,000 ₩ | 뇌 피로 완화 만족도 +30% 💤)" }

# Meeting Module 69: AI Focus & Noise Camera Monitoring Subsystem
var ai_cam_installed: bool = true
var ai_focus_score: float = 95.5
var ai_scans_count: int = 0

func scan_ai_focus_zone() -> Dictionary:
	ai_scans_count += 1
	var fee = 4500.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🤖 AI 시선 & 데시벨 소음 감지 카메라 스캔 완료! (+4,500 ₩ | 몰입도 95.5%% & ANC 자동 차음 🎯)" }

# Meeting Module 70: Exam Season Burning Event Subsystem
var current_season_event: String = "NORMAL"
var exam_season_boost_active: bool = false
var season_events_triggered: int = 0

func trigger_exam_burning_season(season_mode: String = "MIDTERM_EXAM") -> Dictionary:
	season_events_triggered += 1
	current_season_event = season_mode
	exam_season_boost_active = true
	var bonus_revenue = 15000.0
	add_money(bonus_revenue)
	reputation = min(5.0, reputation + 0.06)
	_play_sfx_safe("fanfare")
	var event_name = "🔥 중간고사 올나잇 버닝 페스티벌" if season_mode == "MIDTERM_EXAM" else "☀️ 여름방학 에어컨 힐링 특수"
	return { "success": true, "msg": "🎉 [%s] 개시! (+15,000 ₩ 매출 폭발 | 만석률 100%% & 음료 수요 +100%% 🏆)" % event_name }

# Meeting Module 71: Multi-Theme Interior Decorator Subsystem
var current_theme: String = "NATURE_WOOD"
var themes_unlocked: Array = ["NATURE_WOOD", "CYBER_NEON", "NORDIC_WHITE"]

func switch_cafe_theme(theme_id: String = "CYBER_NEON") -> Dictionary:
	if theme_id in themes_unlocked:
		current_theme = theme_id
		decor_score += 50
		reputation = min(5.0, reputation + 0.05)
		theme_changed.emit(theme_id)
		_play_sfx_safe("chime")
		var theme_title = "자연 원목 힐링" if theme_id == "NATURE_WOOD" else ("사이버 퓨처 네온" if theme_id == "CYBER_NEON" else "북유럽 미니멀 화이트")
		return { "success": true, "msg": "🎨 스터디 카페 2.5D 메인 인테리어 [%s 테마] 전환 완료! (데코 스코어 +50 ✨)" % theme_title }
	return { "success": false, "msg": "해당 테마를 잠금 해제해야 합니다." }

# Meeting Module 72: High-Protein Healthy Snack Subsystem
var protein_snacks_sold: int = 0

func dispense_protein_snack(snack_name: String = "아몬드 오트 프로틴 바") -> Dictionary:
	protein_snacks_sold += 1
	var price = 3800.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥜 100%% 수제 %s 제공 완료! (+3,800 ₩ | 뇌 포도당 & 근손실 방지 🧠)" % snack_name }


# Meeting Module 73: Automated Smart Keycard Kiosk Subsystem
var kiosk_checkins_count: int = 0

func process_kiosk_checkin(seat_type: String = "1인 프리미엄 독서실") -> Dictionary:
	kiosk_checkins_count += 1
	var fee = 4200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🔑 무인 스마트 키오스크 QR 바코드 [%s] 입출입 승인 완료! (+4,200 ₩ | 회전율 UP ⚡)" % seat_type }

# Meeting Module 74: 1:1 Student Mentoring & Diagnostic Subsystem
var student_mentoring_count: int = 0

func conduct_student_mentoring(student_name: String = "김수험", subject: String = "수학") -> Dictionary:
	student_mentoring_count += 1
	var fee = 5500.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🎓 [%s] 손님 %s 과목 1:1 학습 멘토링 & 모의고사 진단서 출력 완료! (+5,500 ₩ | 정기권 연장률 +35%% 📜)" % [student_name, subject] }


# Meeting Module 75: ANC Headphone Dock Repair Subsystem
var anc_repairs_count: int = 0

func repair_anc_headphone(dock_idx: int = 1) -> Dictionary:
	anc_repairs_count += 1
	var fee = 2800.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🔧 %d번 헤드폰 도크 노이즈 캔슬링 쿠션 소독 및 튜닝 완료! (+2,800 ₩ | 청결 만족도 UP 🎧)" % dock_idx }

# Meeting Module 76: Premium Acoustic Isolation Booth Subsystem
var acoustic_booth_reservations: int = 0

func reserve_acoustic_isolation_booth(hours: int = 3) -> Dictionary:
	acoustic_booth_reservations += 1
	var total_fee = 6800.0 * hours
	add_money(total_fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🚪 1인 완전 특수 방음 어쿠스틱 프라이빗 부스 %d시간 예약 완료! (+%s ₩ | 시험 집중 효율 +40%% 🤫)" % [hours, format_money(total_fee)] }

# Meeting Module 77: Autonomous Floor Sanitation Robot Subsystem
var robot_cleans_count: int = 0

func deploy_sanitation_robot() -> Dictionary:
	robot_cleans_count += 1
	var fee = 3500.0
	add_money(fee)
	dirty_seats.clear()
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🤖 자율주행 바닥 로봇 청소기 작동 완료! (+3,500 ₩ | 전 좌석 쓱싹 즉시 청결 100%% 🧹)" }

# Meeting Module 78: Cold Brew Nitro Coffee Tap Subsystem
var nitro_cold_brews_sold: int = 0

func dispense_nitro_cold_brew() -> Dictionary:
	nitro_cold_brews_sold += 1
	var price = 4600.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ 멸균 질소 추출 나이트로 콜드브루 커피 탭 완성! (+4,600 ₩ | 부드러운 거품 뇌 각성 +30%% ⚡)" }

# Meeting Module 79: Espresso Grinder Calibration & Extraction Tuning Subsystem
var grinder_calibrations_count: int = 0

func calibrate_espresso_grinder(microns: int = 250) -> Dictionary:
	grinder_calibrations_count += 1
	var fee = 3000.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "⚙️ 초세밀 그라인더 분쇄도 %d미크론 정밀 캘리브레이션 완료! (+3,000 ₩ | 풍미 & 끄레마 점수 UP ☕)" % microns }

# Meeting Module 80: Multi-Floor VIP Lounge Expansion Subsystem
var vip_lounge_expansions: int = 0

func unlock_vip_lounge_floor(floor_num: int = 2) -> Dictionary:
	vip_lounge_expansions += 1
	if not floor_num in unlocked_floors:
		unlocked_floors.append(floor_num)
	var bonus_rev = 20000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.08)
	floor_changed.emit(floor_num)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🏢 %d층 VIP 프리미엄 라운지 콤플렉스 대규모 확장 개장! (+20,000 ₩ | 좌석 용량 +10석 & 매장 품격 🏆)" % floor_num }

# Meeting Module 81: Smart Standing Desk Ergonomic Height Subsystem
var standing_desk_tunes_count: int = 0

func tune_standing_desk_height(seat_idx: int = 1, height_cm: int = 105) -> Dictionary:
	standing_desk_tunes_count += 1
	var fee = 3600.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🪑 %d번 좌석 전동 모션 모션 스탠딩 책상 높이 %dcm 자동 셋팅 완료! (+3,600 ₩ | 요추 건강 & 바른 자세 ⚡)" % [seat_idx + 1, height_cm] }

# Meeting Module 82: Premium Aroma Essential Oil Diffuser Subsystem
var aroma_diffusions_count: int = 0

func dispense_aroma_scent(scent_name: String = "라벤더 로즈마리") -> Dictionary:
	aroma_diffusions_count += 1
	var fee = 3200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌿 천연 100%% 유기농 %s 아로마 디퓨저 향기 조율 완료! (+3,200 ₩ | 스트레스 완화 & 심신 안정 🌸)" % scent_name }

# Meeting Module 83: Zero-Sugar Homemade Fruit Sparkling Ade Subsystem
var sparkling_ades_sold: int = 0

func blend_sparkling_ade(flavor: String = "자몽 레몬 에이드") -> Dictionary:
	sparkling_ades_sold += 1
	var price = 4400.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍹 무설탕 톡톡 스파클링 %s 탄산 제조 완료! (+4,400 ₩ | 청량감 100%% 뇌 피로 회복 🍋)" % flavor }

# Meeting Module 84: High-Efficiency Solar Panel Power Generator Subsystem
var solar_power_activations: int = 0

func activate_solar_power_grid() -> Dictionary:
	solar_power_activations += 1
	var subsidy = 8500.0
	add_money(subsidy)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☀️ 옥상 태양광 자가 발전 그리드 가동 완료! (+8,500 ₩ 친환경 그린 에너지 보조금 수금 🔋)" }

# Meeting Module 85: Franchise Benchmark Accreditation Subsystem
var franchise_accreditations_count: int = 0

func claim_franchise_accreditation() -> Dictionary:
	franchise_accreditations_count += 1
	var bonus_rev = 25000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.10)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🏆 대한민국 대표 프리미엄 5스타 스터디 카페 전국 프랜차이즈 공식 인증! (+25,000 ₩ 브랜드 보상금 👑)" }

# Meeting Module 86: AI Smart Noise Cancellation Acoustic Panels Subsystem
var acoustic_panels_tuned: int = 0

func tune_acoustic_wall_panels(panel_idx: int = 1) -> Dictionary:
	acoustic_panels_tuned += 1
	var fee = 3900.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🧱 %d번 벽면 미세 타공 방음 어쿠스틱 패널 정밀 차음 조율 완료! (+3,900 ₩ | 잔향음 제거 & 데시벨 -15dB 🤫)" % panel_idx }

# Meeting Module 87: Organic Matcha Green Tea Latte Barista Brew Subsystem
var matcha_lattes_sold: int = 0

func blend_matcha_latte(milk_type: String = "오트 밀크") -> Dictionary:
	matcha_lattes_sold += 1
	var price = 4800.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍵 교토 유기농 말차 & %s 말차 라떼 제조 완료! (+4,800 ₩ | 항산화 뇌 침착 집중력 +25%% 🌿)" % milk_type }

# Meeting Module 88: High-Definition Multi-Monitor Study Dock Subsystem
var multi_monitor_docks_rented: int = 0

func setup_multi_monitor_dock(seat_idx: int = 2) -> Dictionary:
	multi_monitor_docks_rented += 1
	var fee = 5200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🖥️ %d번 좌석 듀얼 4K 암 듀얼 모니터 대여 도크 장착 완료! (+5,200 ₩ | 코딩/논문 작업 생산성 +35%% ⚡)" % (seat_idx + 1) }

# Meeting Module 89: 24/7 Smart Air Purifier HEPA Filter Subsystem
var hepa_filters_replaced: int = 0

func replace_hepa_filter() -> Dictionary:
	hepa_filters_replaced += 1
	air_quality_score = 100.0
	var fee = 3400.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍃 H14 항바이러스 초미세먼지 HEPA 필터 교체 완료! (+3,400 ₩ | 실내 공기질 100점 만점 맑음 ✨)" }

# Meeting Module 90: Master Study Cafe Hall of Fame Trophy Subsystem
var hall_of_fame_trophies: int = 0

func claim_hall_of_fame_trophy() -> Dictionary:
	hall_of_fame_trophies += 1
	var bonus_rev = 30000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.15)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "👑 전국 타이쿤 명예의 전당 전설의 마스터 스터디 카페 황금 트로피 입수! (+30,000 ₩ 최고 보상금 🏆)" }

# Meeting Module 91: Smart Ergonomic Mesh Chair Lumbar Support Subsystem
var lumbar_support_tunes_count: int = 0

func tune_lumbar_chair_support(seat_idx: int = 1) -> Dictionary:
	lumbar_support_tunes_count += 1
	var fee = 3300.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🪑 %d번 좌석 인체공학 메쉬 체어 요추 피로 완화 서포트 정밀 조정 완료! (+3,300 ₩ | 피로도 -30%% ⚡)" % (seat_idx + 1) }

# Meeting Module 92: Premium Handcrafted Honey Butter Scone Bakery Subsystem
var honey_scones_baked: int = 0

func bake_honey_butter_scone() -> Dictionary:
	honey_scones_baked += 1
	var price = 4200.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥐 천연 프랑스 고메 버터 & 꿀 갓 구운 오븐 스콘 완성! (+4,200 ₩ | 라운지 디저트 콤보 +20%% 🍯)" }

# Meeting Module 93: Noise-Canceling Silent Keyboard & Mouse Rental Subsystem
var silent_peripherals_rented: int = 0

func rent_silent_peripherals(seat_idx: int = 0) -> Dictionary:
	silent_peripherals_rented += 1
	var fee = 2900.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "⌨️ %d번 좌석 초무소음 무선 키보드 & 마우스 세트 대여 완료! (+2,900 ₩ | 정숙도 +100%% 🔇)" % (seat_idx + 1) }

# Meeting Module 94: Intelligent Micro-Climate Temperature & Humidity Controller Subsystem
var micro_climate_adjustments: int = 0

func adjust_micro_climate(target_temp: float = 24.5, humidity_pct: int = 50) -> Dictionary:
	micro_climate_adjustments += 1
	temperature = target_temp
	var fee = 3700.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌡️ 항온항습 마이크로 클라이밋 %.1f°C & 습도 %d%% 자동 쾌적 셋팅! (+3,700 ₩ | 집중 쾌적지수 100점 ❄️)" % [target_temp, humidity_pct] }

# Meeting Module 95: Nationwide Franchise Master Blueprint Subsystem
var master_blueprints_issued: int = 0

func issue_master_franchise_blueprint() -> Dictionary:
	master_blueprints_issued += 1
	var royalty_rev = 35000.0
	add_money(royalty_rev)
	reputation = min(5.0, reputation + 0.20)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "📜 전국 100호점 스터디 카페 마스터 청사진 청구 및 가맹 로열티 입수! (+35,000 ₩ 로열티 수금 👑)" }

# Meeting Module 96: Premium Wireless Fast Charger Dock Subsystem
var wireless_chargers_setup: int = 0

func setup_fast_wireless_charger(seat_idx: int = 1) -> Dictionary:
	wireless_chargers_setup += 1
	var fee = 3100.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "⚡ %d번 좌석 50W 고속 무선 충전 패드 도크 장착 완료! (+3,100 ₩ | 배터리 방전 걱정 제로 📱)" % (seat_idx + 1) }

# Meeting Module 97: Cold-Pressed Organic Passionfruit Smoothie Subsystem
var passionfruit_smoothies_sold: int = 0

func blend_passionfruit_smoothie() -> Dictionary:
	passionfruit_smoothies_sold += 1
	var price = 4900.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍹 착즙 유기농 패션후르츠 & 망고 스무디 완성! (+4,900 ₩ | 비타민 C 뇌 활력 +30%% 🥭)" }

# Meeting Module 98: Smart OLED Door Nameplate & Seat Status Indicator Subsystem
var oled_nameplates_tuned: int = 0

func tune_oled_seat_nameplate(seat_idx: int = 0, name_str: String = "열공 D-DAY 30") -> Dictionary:
	oled_nameplates_tuned += 1
	var fee = 3800.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🖥️ %d번 좌석 OLED 미니 네임플레이트 [%s] 디지털 셋팅 완료! (+3,800 ₩ | 몰입 각오 UP 🎯)" % [(seat_idx + 1), name_str] }

# Meeting Module 99: Silent Anti-Vibration Footrest Cushion Subsystem
var footrests_setup: int = 0

func setup_ergonomic_footrest(seat_idx: int = 1) -> Dictionary:
	footrests_setup += 1
	var fee = 2700.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🦶 %d번 좌석 메모리폼 저반발 발받침대 쿠션 장착 완료! (+2,700 ₩ | 하체 혈액순환 & 피로 완화 🦿)" % (seat_idx + 1) }

# Meeting Module 100: Global Franchise Hall of Fame Grand Diamond Medal Subsystem
var grand_diamond_medals_claimed: int = 0

# Meeting Module 101: Mock Exam Diagnosis Center Subsystem
var mock_exam_diagnoses_count: int = 0

# Meeting Module 102: Handdrip Single Origin Coffee Bar Subsystem
var handdrip_brews_count: int = 0

# Meeting Module 103: ANC Headphones Rental Subsystem
var anc_headphones_rented_count: int = 0

func rent_anc_headphones(brand_name: String = "🎧 Sony WH-1000XM5 노이즈 캔슬링") -> Dictionary:
	anc_headphones_rented_count += 1
	var fee = 4200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎧 [%s] 노이즈 캔슬링 헤드폰 대여 완료! (+4,200 ₩ | 소음 완전 차단 몰입 +35%% 🤫)" % brand_name }

# Meeting Module 104: Zero-Gravity Power Nap Pod Subsystem
var power_nap_pods_used: int = 0

# Meeting Module 105: AI Attendance Parent SMS Subsystem
var parent_sms_sent_count: int = 0

# Meeting Module 106: Morning Croissant Brunch Subsystem
var morning_brunch_batches: int = 0

# Meeting Module 107: Pass Exam Book Share Library Subsystem
var pass_books_donated_count: int = 0

# Meeting Module 108: Botanical Greenhouse Air Wall Subsystem
var greenhouse_wall_maintenances: int = 0

# Meeting Module 109: National Top 10 Hall of Fame League Subsystem
func get_national_league_ranking() -> Dictionary:
	var current_rank = 1 if decor_score >= 400 else 3
	return { "success": true, "rank": current_rank, "msg": "🏆 [전국 스터디 카페 프랜차이즈 리그] 현재 전국 %d위 등극! (명예의 전당 랭크 | 마스터 상패 수여 👑)" % current_rank }

# Meeting Module 110: Kelvin Light Color Tuner Subsystem
var active_kelvin_temp: int = 4500

# Meeting Module 111: Protein Smoothie Station Subsystem
var protein_smoothies_blended: int = 0

# Meeting Module 112: Acoustic Soundproof Meeting Room Subsystem
var acoustic_meeting_room_reservations: int = 0

# Meeting Module 113: Study Goal Badge App Subsystem
var study_goal_badges_claimed: int = 0

# Meeting Module 114: Belgian Truffle Chocolate Buffet Subsystem
var truffle_chocolates_dispensed: int = 0

# Meeting Module 115: UVC Desk Mat Sterilizer Subsystem
var uvc_sterilizations_count: int = 0

# Meeting Module 116: Mascot Cat Wood Tower Subsystem
var cat_towers_installed: int = 0

# Meeting Module 117: Rain & Ocean Soundscape Mixer Subsystem
var active_soundscape_mix: String = "RAIN_AND_FIREPLACE"

# Meeting Module 118: National Study Marathon Championship Subsystem
var study_marathons_held: int = 0

# Meeting Module 119: Third Branch Expansion Landmark Subsystem
var third_branch_expanded: bool = false

# Meeting Module 120: 120th Milestone Celebration Subsystem
var milestone_120_triggered: bool = false

# Iteration 109: Offline Idle Revenue Calculator Subsystem
func calc_offline_idle_revenue(hours: float = 4.0) -> Dictionary:
	var offline_rate = 1200.0 * (1.0 + float(unlocked_floors.size()) * 0.2)
	var offline_money = offline_rate * min(12.0, hours)
	add_money(offline_money)
	return { "success": true, "msg": "🌙 [오프라인 방치 보상] %0.1f시간 동안 %s ₩ 수입이 자동 적립되었습니다!" % [hours, String.num(offline_money)] }

# Iteration 110: Auto-Restock Bakery & Snack Automation Subsystem
func auto_refill_all_snacks_and_bakery() -> Dictionary:
	snack_stock = max(50, snack_stock + 50)
	bakery_stock["croissant"] = max(30, bakery_stock.get("croissant", 15) + 30)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥐 [원클릭 자동 채우기] 디저트 & 스낵 재고 풀 충전 완료! (스낵 +50, 베이커리 +30 🥨)" }

# Iteration 111: Real-Time Student Mood Floating Text Effect Subsystem
func trigger_student_mood_boost(student_name: String = "🎓 수험생 수진") -> Dictionary:
	var tip = 1800.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("coin")
	return { "success": true, "msg": "✨ [%s] 님이 몰입감 최상 상태 달성으로 팁 지급! (+1,800 ₩ | 만족도 최고 😊)" % student_name }

# Iteration 112: Master Save Data Migration & Compatibility Subsystem
var save_version: int = 112

func migrate_save_version_v112(data_dict: Dictionary) -> Dictionary:
	if not data_dict.has("save_version"):
		data_dict["save_version"] = 112
	if not data_dict.has("reputation"):
		data_dict["reputation"] = 4.5
	return data_dict

# Iteration 113: Real-Time Store Cleanliness Auto-Sweeper Staff Subsystem
func trigger_auto_sweeper_cleaning() -> Dictionary:
	var fee = 2200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🧹 [클린 스태프] 전 구역 실시간 미세먼지 수거 & 소독 청소 완료! (+2,200 ₩ | 청결도 100%% 🧹)" }

# Iteration 114: Real-Time Store Financial Analytics Report Exporter Subsystem
func export_store_financial_report() -> Dictionary:
	var bonus = 5000.0
	add_money(bonus)
	_play_sfx_safe("chime")
	return {
		"success": true,
		"total_money": money,
		"reputation": reputation,
		"unlocked_rooms": unlocked_floors.size(),
		"msg": "📊 [경영 결산 보고서] 실시간 일일 매출 및 매장 순이익 정산 리포트 생성 완료! (+5,000 ₩ 결산 보너스 📈)"
	}

# Iteration 115: Real-Time Store Safety & Emergency Alarm System Subsystem
func trigger_emergency_fire_safety_drill() -> Dictionary:
	var bonus = 4200.0
	add_money(bonus)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🚨 [소방 무균 점검] 매장 소방 안전 센서 & 비상구 정기점검 완료! (+4,200 ₩ 안전 환급금 | 매장 안전지수 100%% 🚨)" }

# Iteration 116: Real-Time Store VIP Concierge Priority Service Subsystem
var vip_concierge_members: int = 0

func register_vip_concierge_member(member_name: String = "💎 수험생 민준") -> Dictionary:
	vip_concierge_members += 1
	var fee = 7800.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "💎 [%s] 님 V.I.P 콘시어지 정기 회원 등록 완료! (+7,800 ₩ 회비 | 전용 라커 & 리클라이너 우선 배정 👑)" % member_name }

# Iteration 117: Master Store Multi-Branch Synergy Network Subsystem
func calc_multi_branch_synergy_boost() -> Dictionary:
	var bonus = 12500.0
	add_money(bonus)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🌐 [네트워크 시너지] 강남 본점 × 홍대 2호점 × 신촌 3호점 통합 통합 패스 연동! (+12,500 ₩ 브랜드 시너지 수익 🌟)" }

# Iteration 118: Real-Time Store Haptic & Audio Feedback Manager Subsystem
func trigger_haptic_audio_feedback(feedback_type: String = "SUCCESS") -> Dictionary:
	_play_sfx_safe("coin")
	var sm = get_node_or_null("/root/SoundManager")
	if sm != null and sm.has_method("play_varied_sfx"):
		sm.play_varied_sfx("coin", 0.98, 1.02)
	return { "success": true, "msg": "📳 [햅틱 피드백] 모바일 아날로그 진동 & 입체 사운드 피드백 동기화 완료! (%s 📳)" % feedback_type }

# Iteration 119: Real-Time Store Global Franchising Network Master Subsystem
var global_franchises_opened: int = 0

func launch_global_franchise_brand(city_name: String = "✈️ 도쿄 시부야 글로벌 1호점") -> Dictionary:
	global_franchises_opened += 1
	var royalty = 30000.0
	add_money(royalty)
	reputation = min(5.0, reputation + 0.15)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🌍 [글로벌 프랜차이즈] [%s] 진출 완료! (+30,000 ₩ 로열티 | 브랜드 글로벌 명성 +0.15 🗽)" % city_name }

# Iteration 120: Master Tycoon Hall of Fame & Ultimate Director Trophy Subsystem
var ultimate_trophy_unlocked: bool = false

func unlock_ultimate_director_trophy() -> Dictionary:
	ultimate_trophy_unlocked = true
	var grand_prize = 500000.0
	add_money(grand_prize)
	reputation = 5.0
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🏆 [명예의 전당] 전설의 얼티밋 타이쿤 디렉터 트로피 수상! (+500,000 ₩ 최고 포상금 | 최고 등급 달성 👑)" }

# Iteration 121: Real-Time Store VIP Lounge Coffee Beans Roasting Master Subsystem
var specialty_roasts_completed: int = 0

func roast_specialty_espresso_blend(bean_type: String = "☕ 파나마 게이샤 스페셜티 로스팅") -> Dictionary:
	specialty_roasts_completed += 1
	var revenue = 14000.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ [스페셜티 로스팅] [%s] 최고급 신선 배전 완료! (+14,000 ₩ 원두 수입 | 매장 커피 풍미 +100%% ☕)" % bean_type }

# Iteration 122: Real-Time Store AI CCTV Security & Anti-Theft Surveillance Subsystem
var ai_cctv_active: bool = true

func activate_ai_cctv_surveillance() -> Dictionary:
	ai_cctv_active = true
	var refund = 3800.0
	add_money(refund)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📹 [AI 지능형 CCTV] 24시간 실시간 무인 도난 방지 & 분실물 케어 스캔 완료! (+3,800 ₩ 안전 수수료 | 도난율 0%% 📹)" }

# Iteration 123: Real-Time Store Organic Green Plant & Botanical Air Purifier Subsystem
var botanical_plants_count: int = 0

func plant_botanical_air_purifier() -> Dictionary:
	botanical_plants_count += 1
	decor_score += 18
	var eco_grant = 2800.0
	add_money(eco_grant)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌿 [친환경 식집사] 몬스테라 & 극락조 대형 공기정화 식물 배치 완료! (인테리어 +18 🌟 | 산소농도 100%% 🌿)" }

# Iteration 124: Real-Time Customer Online Reservation App Pass Subsystem
var online_app_passes_sold: int = 0

func purchase_online_pass_mobile_app(pass_type: String = "📱 4주 정기 몰입 이용권") -> Dictionary:
	online_app_passes_sold += 1
	var revenue = 4500.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("coin")
	return { "success": true, "msg": "📱 [모바일 예약 앱] [%s] 결제 및 원스톱 입실 QR 발급 완료! (+4,500 ₩ 수입 | 편리성 만점 📱)" % pass_type }

# Iteration 125: Real-Time Store Espresso Machine Pressure Tuning Subsystem
var espresso_extraction_pressure_bar: float = 9.0

func tune_espresso_machine_pressure(target_bar: float = 9.0) -> Dictionary:
	espresso_extraction_pressure_bar = target_bar
	var tip = 3200.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ [에스프레소 머신] 추출 압력 %0.1f BAR 골든 황금 압력 세팅 완료! (+3,200 ₩ 크레마 미식 팁 ☕)" % target_bar }

# Iteration 126: Real-Time Store White Noise Soundscape Frequency Tuning Subsystem
var white_noise_frequency_hz: float = 432.0

func tune_white_noise_frequency(target_hz: float = 432.0) -> Dictionary:
	white_noise_frequency_hz = target_hz
	var tip = 2600.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎧 [아날로그 백색소음] %0.0f Hz 알파파 뇌파 유도 입체 아날로그 튜닝 완료! (+2,600 ₩ 몰입 소음 팁 🎧)" % target_hz }

# Iteration 127: Real-Time Store Smart IoT Lighting & Solar Flare Dimming Subsystem
var iot_lighting_brightness_pct: float = 85.0

func adjust_smart_iot_lighting(brightness: float = 85.0) -> Dictionary:
	iot_lighting_brightness_pct = brightness
	var grant = 3500.0
	add_money(grant)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "💡 [스마트 IoT 조명] %0.0f%% 비주얼 조도 및 시력 보호 4000K 색온도 제어 완료! (+3,500 ₩ 에코 절전 지원금 💡)" % brightness }

# Iteration 128: Real-Time Store Premium Ergo Desk & Dual Monitor Stand Support Subsystem
var ergo_monitor_arms_installed: int = 0

func install_ergo_dual_monitor_mount() -> Dictionary:
	ergo_monitor_arms_installed += 1
	var fee = 2400.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("coin")
	return { "success": true, "msg": "🖥️ [인체공학 모니터암] 개발자 & 디자이너 구역 듀얼 모니터암 셋업 완료! (+2,400 ₩ 워크스테이션 부가 수입 🖥️)" }

# Iteration 129: Real-Time Customer Noise-Canceling Sleep Pod Lounge Subsystem
var sleep_pods_unlocked: bool = true

func unlock_sleep_pod_lounge() -> Dictionary:
	sleep_pods_unlocked = true
	var fee = 3600.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🛌 [무중력 리프레시 팟] 20분 꿀잠 파워 냅(Power Nap) 캡슐 룸 입실 완료! (+3,600 ₩ 피로회복 수입 🛌)" }

# Iteration 130: Real-Time Store AI Focus Meter & Brainwave Synchronization Subsystem
var brainwave_focus_level_pct: float = 99.5

func sync_ai_focus_brainwave(freq_hz: float = 40.0) -> Dictionary:
	brainwave_focus_level_pct = 99.5
	var tip = 4200.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🧠 [AI 뇌파 동기화] %0.0f Hz 감마파 조명 & 음향 바이노럴 동기화 완료! (+4,200 ₩ 초몰입 팁 | 몰입도 99.5%% 🧠)" % freq_hz }

# Iteration 131: Real-Time Store Organic Matcha Latte Bar Subsystem
var organic_matcha_lattes_brewed: int = 0

func brew_organic_matcha_latte() -> Dictionary:
	organic_matcha_lattes_brewed += 1
	var revenue = 3400.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍵 [유기농 말차 라떼] 교토 우지 세레모니얼 다도 등급 맷돌 격불 라떼 완성! (+3,400 ₩ 매출 수입 🍵)" }

# Iteration 132: Real-Time Store Organic Lavender Essential Oil Aroma Therapy Subsystem
var aroma_diffusions_active: bool = true

func diffuse_lavender_aroma_therapy() -> Dictionary:
	aroma_diffusions_active = true
	var tip = 2800.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🪻 [아로마 테라피] 프로방스 천연 유기농 라벤더 에센셜 오일 미세 디퓨징 완료! (+2,800 ₩ 심신안정 팁 🪻)" }

# Iteration 133: Real-Time Store Organic Berry Acai Smoothie Bowl Subsystem
var acai_bowls_sold: int = 0

func blend_berry_acai_bowl() -> Dictionary:
	acai_bowls_sold += 1
	var revenue = 4800.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🫐 [슈퍼푸드 아사이볼] 유기농 블루베리 & 그래놀라 토핑 아사이 스무디 볼 완성! (+4,800 ₩ 디저트 매출 🫐)" }

# Iteration 134: Real-Time Store Smart Kiosk Facial Recognition Check-In Subsystem
var facial_recognition_active: bool = true

func activate_facial_recognition_checkin() -> Dictionary:
	facial_recognition_active = true
	var fee = 4000.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("coin")
	return { "success": true, "msg": "📸 [AI 안면인식 무인 키오스크] 0.1초 초고속 안면 인식 패스 완료! (+4,000 ₩ 패스트트랙 부가 수입 📸)" }

# Iteration 135: Real-Time Store Premium Organic Matcha Gelato Ice Cream Subsystem
var gelato_scoops_sold: int = 0

func scoop_organic_matcha_gelato() -> Dictionary:
	gelato_scoops_sold += 1
	var revenue = 3900.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍨 [수제 젤라또] 이탈리아 수제 유기농 말차 젤라또 아이스크림 스쿱 완성! (+3,900 ₩ 젤라또 매출 🍨)" }

# Iteration 136: Real-Time Store Organic Cold Brew Nitro Coffee Tap Subsystem
var nitro_cold_brews_tapped: int = 0

func tap_nitro_cold_brew() -> Dictionary:
	nitro_cold_brews_tapped += 1
	var revenue = 4500.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ [질소 나이트로 콜드브루] 크리미 질소 거품 극강 추출 완료! (+4,500 ₩ 나이트로 커피 수입 ☕)" }

# Iteration 137: Real-Time Store Premium Acoustic Noise Baffle Ceiling Panel Subsystem
var acoustic_baffle_panels_installed: int = 0

func install_acoustic_noise_baffle_ceiling() -> Dictionary:
	acoustic_baffle_panels_installed += 1
	var tip = 2600.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🔇 [흡음 바플 천장] 고밀도 친환경 펠트 흡음 패널 세팅 완료! (+2,600 ₩ 무소음 정적 팁 | 잔향시간 0.2초 🔇)" }

# Iteration 138: 2.5D Isometric Real-Time Seat Acoustic Focus & Heatmap Analytics Engine
var is_heatmap_mode: bool = false
var seat_focus_scores: Dictionary = {} # seat_index (int) -> float (0.0 to 100.0)
var seat_noise_levels: Dictionary = {} # seat_index (int) -> float (dBA decibels)

func toggle_heatmap_mode() -> bool:
	is_heatmap_mode = not is_heatmap_mode
	if is_heatmap_mode:
		recalculate_seat_acoustics_and_focus()
	_play_sfx_safe("click")
	return is_heatmap_mode

func recalculate_seat_acoustics_and_focus() -> Dictionary:
	var total_cap = get_max_capacity()
	var open_level = upgrades["open_seats"]["level"]
	var total_focus_sum = 0.0
	var total_noise_sum = 0.0
	
	for i in range(total_cap):
		var is_booth = i >= open_level * 3
		var base_noise = 38.0 if is_booth else 48.0 # dBA base noise
		
		# Acoustic baffle ceiling attenuation (-6 dBA per upgrade layer)
		if acoustic_baffle_panels_installed > 0:
			base_noise -= min(12.0, acoustic_baffle_panels_installed * 3.0)
			
		# Air purifier / HEPA acoustics (-4 dBA)
		if upgrades.has("hepa_filter") and upgrades["hepa_filter"]["level"] > 0:
			base_noise -= 4.0
			
		# Coffee bar / snack bar noise addition for front row seats (cols 0-1)
		var col = i % 3
		if col == 0:
			base_noise += 4.5 # proximity to coffee bar
			
		base_noise = clamp(base_noise, 28.0, 75.0)
		seat_noise_levels[i] = base_noise
		
		# Focus Score Calculation (100 - noise_penalty + booth_bonus + lighting_bonus)
		var focus = 100.0 - (base_noise - 30.0) * 1.5
		if is_booth:
			focus += 18.0 # Booth isolation bonus
		if upgrades.has("desk_lamp") and upgrades["desk_lamp"]["level"] > 0:
			focus += 8.0 # LED desk lamp focus bonus
			
		focus = clamp(focus, 35.0, 100.0)
		seat_focus_scores[i] = focus
		
		total_focus_sum += focus
		total_noise_sum += base_noise
		
	var avg_focus = total_focus_sum / max(1, total_cap)
	var avg_noise = total_noise_sum / max(1, total_cap)
	
	return {
		"avg_focus": avg_focus,
		"avg_noise": avg_noise,
		"total_seats": total_cap
	}

# Iteration 139: Dynamic Customer AI Behavior Tree & Real-Time Pathfinding Visualizer Engine
var selected_customer_id: int = -1
var is_customer_inspector_open: bool = false

func select_customer_for_ai_inspection(cid: int) -> Dictionary:
	selected_customer_id = cid
	is_customer_inspector_open = true
	var c = get_customer_by_id(cid)
	if c.is_empty():
		return { "success": false, "msg": "Customer not found" }
		
	var behavior_tree = calculate_customer_ai_behavior(c)
	_play_sfx_safe("click")
	return { "success": true, "data": behavior_tree }

func get_customer_by_id(cid: int) -> Dictionary:
	for c in active_customers:
		if c.get("id", -1) == cid:
			return c
	return {}

func calculate_customer_ai_behavior(c: Dictionary) -> Dictionary:
	var s_idx = c.get("seat_index", 0)
	var noise = seat_noise_levels.get(s_idx, 40.0)
	var temp_diff = abs(temperature - 22.0)
	
	var stress = 15.0 + temp_diff * 2.5 + (noise - 35.0) * 0.8
	if is_cat_buff_active():
		stress -= 15.0 # Cat healing buff reduces stress
	if upgrades.has("hepa_filter") and upgrades["hepa_filter"]["level"] > 0:
		stress -= 8.0 # HEPA air purifier reduces stress
	stress = clamp(stress, 0.0, 100.0)
	
	var ai_state = c.get("state", "STUDYING")
	var decision_node = "📖 학습 진행 중"
	if ai_state == "WALKING_IN":
		decision_node = "🚶 키오스크 입실 수속"
	elif ai_state == "WALKING_TO_SEAT":
		decision_node = "🧭 좌석으로 최단 경로 이동"
	elif ai_state == "EATING_CAKE":
		decision_node = "🍰 스낵바 피로 회복 휴식"
	elif ai_state == "LEAVING":
		decision_node = "👋 만족 퇴실 및 리뷰 작성"

	# Generate 2.5D Pathfinding Waypoints
	var waypoints = []
	var cur_pos = c.get("pos", Vector2.ZERO)
	var target_pos = c.get("target_pos", Vector2.ZERO)
	waypoints.append(cur_pos)
	
	# Intermediate A* waypoints through main aisle
	var aisle_x = 420.0
	waypoints.append(Vector2(aisle_x, cur_pos.y))
	waypoints.append(Vector2(aisle_x, target_pos.y))
	waypoints.append(target_pos)

	return {
		"id": c.get("id", 0),
		"name": c.get("name", "학생 손님"),
		"icon": c.get("icon", "🎓"),
		"state": ai_state,
		"stress": stress,
		"focus": seat_focus_scores.get(s_idx, 85.0),
		"decision_node": decision_node,
		"drink_pref": "아이스 아메리카노" if c.get("type", "") == "developer" else "말차 라떼",
		"waypoints": waypoints
	}

# Iteration 140: Real-Time Store Acoustic Frequency Equalizer & ANC Noise Cancellation Engine
var is_equalizer_hud_open: bool = false
var is_anc_system_active: bool = true

func toggle_equalizer_hud() -> bool:
	is_equalizer_hud_open = not is_equalizer_hud_open
	_play_sfx_safe("click")
	return is_equalizer_hud_open

func calculate_acoustic_equalizer_spectrum() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Frequency Band Energy Calculation (16 Bands)
	var bands = []
	var base_noise = 38.0
	if acoustic_baffle_panels_installed > 0:
		base_noise -= min(12.0, acoustic_baffle_panels_installed * 3.0)
		
	for b_idx in range(16):
		var freq_ratio = b_idx / 15.0
		var energy = 0.2 + sin(game_time * 4.0 + b_idx * 0.8) * 0.25 + randf() * 0.15
		
		# Low Frequencies (HVAC & Footsteps)
		if b_idx < 4:
			energy += 0.25 if abs(temperature - 22.0) > 3.0 else 0.1
		# Mid Frequencies (Keyboard typing & Chatter)
		elif b_idx >= 4 and b_idx < 12:
			energy += (active_cust_count * 0.04)
		# High Frequencies (Coffee grinder & Dishes)
		else:
			energy += (active_orders.size() * 0.08)
			
		if is_anc_system_active and upgrades.has("anc_headphones") and upgrades["anc_headphones"]["level"] > 0:
			energy *= 0.35 # ANC Noise Cancellation 65% attenuation
			
		energy = clamp(energy, 0.05, 1.0)
		bands.append(energy)
		
	var anc_suppression_pct = 65.0 if (is_anc_system_active and upgrades.has("anc_headphones") and upgrades["anc_headphones"]["level"] > 0) else 15.0
	
	return {
		"bands": bands,
		"bass_db": 20.0 + bands[1] * 30.0,
		"mid_db": 25.0 + bands[7] * 35.0,
		"treble_db": 18.0 + bands[14] * 25.0,
		"anc_suppression": anc_suppression_pct,
		"is_anc_active": is_anc_system_active
	}

# Iteration 141: Real-Time Store Power Grid Load & Renewable Solar/Battery Energy Engine
var is_power_grid_hud_open: bool = false
var ess_battery_kwh: float = 75.0 # Max capacity 100.0 kWh

func toggle_power_grid_hud() -> bool:
	is_power_grid_hud_open = not is_power_grid_hud_open
	_play_sfx_safe("click")
	return is_power_grid_hud_open

func calculate_power_grid_energy_status() -> Dictionary:
	var total_cap = get_max_capacity()
	
	# Base Consumption (kW)
	var load_kw = 3.2 # Base lighting & servers
	load_kw += total_cap * 0.15 # Desk lamps & laptops
	if abs(temperature - 22.0) > 3.0:
		load_kw += 4.5 # HVAC AC load
	if roasters[0]["state"] == "ROASTING":
		load_kw += 3.8 # Coffee roaster heating element
	if upgrades.has("fast_charger") and upgrades["fast_charger"]["level"] > 0:
		load_kw += 1.8 # 100W fast charging docks
		
	# Solar Generation (kW) based on time of day
	var solar_kw = 0.0
	if time_of_day == "DAY":
		solar_kw = 12.5
	elif time_of_day == "DUSK":
		solar_kw = 3.5
	else:
		solar_kw = 0.0
		
	# ESS Battery Charge/Discharge Simulation
	var net_kw = solar_kw - load_kw
	if net_kw > 0:
		ess_battery_kwh = min(100.0, ess_battery_kwh + net_kw * 0.05)
	else:
		ess_battery_kwh = max(0.0, ess_battery_kwh + net_kw * 0.05)
		
	var grid_import_kw = max(0.0, load_kw - solar_kw - (ess_battery_kwh * 0.1))
	var bill_savings_pct = clamp((solar_kw + (100.0 - ess_battery_kwh) * 0.2) / max(1.0, load_kw) * 100.0, 0.0, 95.0)
	var co2_reduced_kg = solar_kw * 0.42 # 0.42kg CO2 reduced per kWh solar
	
	return {
		"load_kw": load_kw,
		"solar_kw": solar_kw,
		"ess_battery_pct": (ess_battery_kwh / 100.0) * 100.0,
		"grid_import_kw": grid_import_kw,
		"savings_pct": bill_savings_pct,
		"co2_reduced_kg": co2_reduced_kg
	}

# Iteration 142: Real-Time Store Indoor Air Quality & Micro-Dust PM2.5 Bio-Filter Ventilation Engine
var is_air_quality_hud_open: bool = false

func toggle_air_quality_hud() -> bool:
	is_air_quality_hud_open = not is_air_quality_hud_open
	_play_sfx_safe("click")
	return is_air_quality_hud_open

func calculate_indoor_air_quality_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Base CO2 (ppm) and PM2.5 (ug/m3)
	var co2_ppm = 450.0 + active_cust_count * 45.0 # CO2 increases with occupants
	var pm25_ug = 18.0 + active_cust_count * 1.2
	
	# HEPA & Bio-Scrubber attenuation
	if upgrades.has("hepa_filter") and upgrades["hepa_filter"]["level"] > 0:
		pm25_ug *= 0.25 # 75% PM2.5 reduction
		co2_ppm -= 200.0
		
	co2_ppm = clamp(co2_ppm, 380.0, 1800.0)
	pm25_ug = clamp(pm25_ug, 3.0, 120.0)
	
	var aqi_score = int((co2_ppm - 380.0) * 0.05 + pm25_ug * 0.8)
	aqi_score = clamp(aqi_score, 10, 200)
	
	var status_str = "🩵 최상 (Good)"
	if aqi_score > 100 or co2_ppm > 1000:
		status_str = "🔴 환기 필요 (Unhealthy)"
	elif aqi_score > 50:
		status_str = "💚 보통 (Moderate)"
		
	var oxygen_focus_bonus = 12.0 if co2_ppm < 600.0 else (5.0 if co2_ppm < 900.0 else -10.0)
	
	return {
		"co2_ppm": co2_ppm,
		"pm25_ug": pm25_ug,
		"aqi": aqi_score,
		"status": status_str,
		"focus_bonus": oxygen_focus_bonus
	}

# Iteration 143: Real-Time Dynamic Store Network Bandwidth & Wi-Fi 7 Traffic Traffic Optimizer Engine
var is_network_hud_open: bool = false

func toggle_network_hud() -> bool:
	is_network_hud_open = not is_network_hud_open
	_play_sfx_safe("click")
	return is_network_hud_open

func calculate_network_bandwidth_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Bandwidth Load Calculation (Mbps)
	var load_mbps = 120.0 # Base cloud print & smart kiosk telemetry
	for c in active_customers:
		if c.get("type", "") == "developer":
			load_mbps += 140.0 # High bandwidth dev traffic (Docker, Git, IDEs)
		else:
			load_mbps += 45.0 # 4K video lectures
			
	# Ping Latency (ms) & QOS Suppression
	var ping_ms = 4.5 + (load_mbps / 100.0) * 0.8
	var is_wifi7_unlocked = upgrades.has("wifi_mesh") and upgrades["wifi_mesh"]["level"] > 0
	
	if is_wifi7_unlocked:
		ping_ms = max(2.0, ping_ms * 0.3) # Wi-Fi 7 MLO (Multi-Link Operation) 70% latency reduction
		
	var dev_speed_bonus = 15.0 if ping_ms < 8.0 else (5.0 if ping_ms < 18.0 else -5.0)
	var band_6ghz_pct = 68.0 if is_wifi7_unlocked else 0.0
	var band_5ghz_pct = 24.0 if is_wifi7_unlocked else 65.0
	var band_2g_pct = 8.0 if is_wifi7_unlocked else 35.0
	
	return {
		"load_mbps": load_mbps,
		"ping_ms": ping_ms,
		"dev_bonus": dev_speed_bonus,
		"band_6g": band_6ghz_pct,
		"band_5g": band_5ghz_pct,
		"band_2g": band_2g_pct,
		"is_wifi7": is_wifi7_unlocked
	}

# Iteration 144: Real-Time Smart Ergonomic Desk Motor Sensor & Posture Correction Engine
var is_ergonomic_hud_open: bool = false
var is_standing_desk_active: bool = false

func toggle_ergonomic_hud() -> bool:
	is_ergonomic_hud_open = not is_ergonomic_hud_open
	_play_sfx_safe("click")
	return is_ergonomic_hud_open

func calculate_ergonomic_posture_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Sitting Fatigue & Posture Score
	var posture_fatigue = clamp(active_cust_count * 5.5 + (100.0 - ai_focus_score) * 0.4, 10.0, 95.0)
	var is_ergo_unlocked = upgrades.has("vip_lounge") and upgrades["vip_lounge"]["level"] > 0
	
	if is_ergo_unlocked and posture_fatigue > 60.0:
		is_standing_desk_active = true
	else:
		is_standing_desk_active = false
		
	var desk_height_cm = 110.0 if is_standing_desk_active else 72.0
	var posture_score = 95 - int(posture_fatigue * 0.5)
	if is_ergo_unlocked:
		posture_score = min(99, posture_score + 20)
		
	var stamina_recovery_pct = 25.0 if is_standing_desk_active else (10.0 if is_ergo_unlocked else 0.0)
	var turtle_neck_alert = posture_fatigue > 70.0 and not is_standing_desk_active
	
	return {
		"fatigue": posture_fatigue,
		"desk_height": desk_height_cm,
		"is_standing": is_standing_desk_active,
		"posture_score": posture_score,
		"recovery_pct": stamina_recovery_pct,
		"turtle_neck_alert": turtle_neck_alert,
		"is_ergo_unlocked": is_ergo_unlocked
	}

# Iteration 145: Real-Time Smart Biometric Pulse & Stress Relaxation Soundscape Engine
var is_biometric_hud_open: bool = false

func toggle_biometric_hud() -> bool:
	is_biometric_hud_open = not is_biometric_hud_open
	_play_sfx_safe("click")
	return is_biometric_hud_open

func calculate_biometric_pulse_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Base Occupant BPM (60 ~ 115)
	var avg_bpm = 68.0 + active_cust_count * 2.2 + abs(temperature - 22.0) * 1.5
	if upgrades.has("espresso") and upgrades["espresso"]["level"] > 0:
		avg_bpm += 4.0 # Caffeine speedup
		
	avg_bpm = clamp(avg_bpm, 60.0, 115.0)
	
	var stress_index = clamp((avg_bpm - 65.0) * 1.8, 5.0, 95.0)
	var soundscape_mode = "432Hz 힐링 바이노럴 비트"
	
	if stress_index > 65.0:
		soundscape_mode = "🌊 심해 아쿠아 릴렉세이션"
		avg_bpm -= 8.0 # Relaxation soundscape attenuation
	elif stress_index > 40.0:
		soundscape_mode = "🌧️ 우드랜드 젠더 레인"
	else:
		soundscape_mode = "🎵 델타파 알파 부스트"
		
	var bpm_stability_bonus = 18.0 if avg_bpm < 74.0 else (8.0 if avg_bpm < 86.0 else -12.0)
	var heart_state_str = "🩵 안온 (Optimal)"
	if avg_bpm > 90.0:
		heart_state_str = "🔴 스트레스 고조 (High Stress)"
	elif avg_bpm > 76.0:
		heart_state_str = "💛 집중 각성 (Elevated)"
		
	return {
		"bpm": avg_bpm,
		"stress": stress_index,
		"soundscape": soundscape_mode,
		"stability_bonus": bpm_stability_bonus,
		"heart_state": heart_state_str
	}

# Iteration 146: Real-Time Smart Quantum Encryption Key & Digital Lock Subsystem
var is_quantum_hud_open: bool = false

func toggle_quantum_hud() -> bool:
	is_quantum_hud_open = not is_quantum_hud_open
	_play_sfx_safe("click")
	return is_quantum_hud_open

func calculate_quantum_security_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Quantum Key Entropy (0~100%)
	var qkd_entropy = 99.8
	var is_kiosk_unlocked = upgrades.has("kiosk") and upgrades["kiosk"]["level"] > 0
	if not is_kiosk_unlocked:
		qkd_entropy = 65.0
		
	var gate_latency_sec = 0.4 if is_kiosk_unlocked else 1.8
	var sec_rating = "👑 A+ (Quantum-Safe)" if is_kiosk_unlocked else "🛡️ B (Standard Keypad)"
	
	var trust_bonus_pct = 22.0 if is_kiosk_unlocked else 5.0
	var spoof_attempts_blocked = int(active_cust_count * 0.8) + 12
	
	return {
		"entropy": qkd_entropy,
		"latency": gate_latency_sec,
		"rating": sec_rating,
		"trust_bonus": trust_bonus_pct,
		"blocked_spoofs": spoof_attempts_blocked
	}

# Iteration 147: Real-Time Store Micro-Climate Humidity & Botanical Bio-Wall Transpiration Subsystem
var is_botanical_hud_open: bool = false

func toggle_botanical_hud() -> bool:
	is_botanical_hud_open = not is_botanical_hud_open
	_play_sfx_safe("click")
	return is_botanical_hud_open

func calculate_botanical_humidity_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Base Humidity (% RH)
	var humidity_rh = 40.0 - abs(temperature - 22.0) * 1.8 # AC lowers humidity
	var is_biowall_unlocked = upgrades.has("air_purifier") and upgrades["air_purifier"]["level"] > 0
	
	var transpiration_l_hr = 0.0
	if is_biowall_unlocked:
		transpiration_l_hr = 4.2
		humidity_rh += 15.0 # Bio-Wall restores optimal moisture
		
	humidity_rh = clamp(humidity_rh, 25.0, 75.0)
	
	var comfort_str = "🟢 최적 쾌적 (55% RH)"
	if humidity_rh < 40.0:
		comfort_str = "🟧 건조 경보 (Eye Dry)"
	elif humidity_rh > 65.0:
		comfort_str = "🩵 과습 (High Moisture)"
		
	var eye_relief_bonus = 14.0 if (humidity_rh >= 45.0 and humidity_rh <= 60.0) else (5.0 if humidity_rh >= 35.0 else -8.0)
	
	return {
		"humidity_rh": humidity_rh,
		"transpiration_rate": transpiration_l_hr,
		"comfort_status": comfort_str,
		"eye_relief_bonus": eye_relief_bonus,
		"is_biowall_unlocked": is_biowall_unlocked
	}

# Iteration 148: Real-Time Store Solar Circadian Spectrum Lighting & Blue-Light Filter Subsystem
var is_circadian_hud_open: bool = false

func toggle_circadian_hud() -> bool:
	is_circadian_hud_open = not is_circadian_hud_open
	_play_sfx_safe("click")
	return is_circadian_hud_open

func calculate_circadian_spectrum_metrics() -> Dictionary:
	var kelvin_k = 6500.0
	var phase_str = "🩵 각성 피크 (6500K Peak)"
	var bluelight_cut_pct = 15.0
	
	if time_of_day == "DAY":
		kelvin_k = 6500.0
		phase_str = "🩵 낮 고집중 각성 (6500K Peak)"
		bluelight_cut_pct = 20.0
	elif time_of_day == "DUSK":
		kelvin_k = 4500.0
		phase_str = "☀️ 석양 포근 집중 (4500K Warm)"
		bluelight_cut_pct = 55.0
	else:
		kelvin_k = 2700.0
		phase_str = "🌅 심야 멜라토닌 보호 (2700K Night)"
		bluelight_cut_pct = 85.0
		
	var is_lighting_unlocked = upgrades.has("vip_lounge") and upgrades["vip_lounge"]["level"] > 0
	if is_lighting_unlocked:
		bluelight_cut_pct = min(99.0, bluelight_cut_pct + 15.0)
		
	var night_endurance_bonus = 16.0 if time_of_day == "NIGHT" else 8.0
	
	return {
		"kelvin": kelvin_k,
		"phase": phase_str,
		"bluelight_cut": bluelight_cut_pct,
		"endurance_bonus": night_endurance_bonus,
		"is_lighting_unlocked": is_lighting_unlocked
	}

# Iteration 149: Real-Time Store Thermal Comfort PMV & Radiometric Floor Cooling/Heating Subsystem
var is_pmv_hud_open: bool = false

func toggle_pmv_hud() -> bool:
	is_pmv_hud_open = not is_pmv_hud_open
	_play_sfx_safe("click")
	return is_pmv_hud_open

func calculate_pmv_thermal_comfort_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# PMV Model (Fanger Thermal Comfort Model: -3.0 Cold to +3.0 Hot, 0.0 Ideal Neutral)
	var pmv_score = (temperature - 22.5) * 0.28
	var radiant_floor_temp_c = temperature - 0.5
	var ppd_discomfort_pct = clamp(5.0 + abs(pmv_score) * 22.0, 5.0, 95.0)
	
	var is_radiant_floor_unlocked = upgrades.has("hepa_filter") and upgrades["hepa_filter"]["level"] > 0
	if is_radiant_floor_unlocked:
		pmv_score *= 0.2 # Radiant floor maintains ideal neutrality
		radiant_floor_temp_c = 23.0
		ppd_discomfort_pct = 4.8
		
	var pmv_status = "🟢 중립 쾌적 (Ideal Neutral 0.0)"
	if pmv_score > 0.5:
		pmv_status = "🔴 덥고 답답함 (Warm Discomfort)"
	elif pmv_score < -0.5:
		pmv_status = "🩵 쌀쌀함 (Cool Draft)"
		
	var thermal_neutrality_bonus = 15.0 if abs(pmv_score) <= 0.2 else (6.0 if abs(pmv_score) <= 0.6 else -10.0)
	
	return {
		"pmv": pmv_score,
		"floor_temp": radiant_floor_temp_c,
		"ppd": ppd_discomfort_pct,
		"status": pmv_status,
		"neutrality_bonus": thermal_neutrality_bonus,
		"is_radiant_floor": is_radiant_floor_unlocked
	}

# Iteration 150: Real-Time Store Autonomous AI Cleaning Drone & UV-C Disinfection Robotic Subsystem
var is_cleaning_drone_hud_open: bool = false

func toggle_cleaning_drone_hud() -> bool:
	is_cleaning_drone_hud_open = not is_cleaning_drone_hud_open
	_play_sfx_safe("click")
	return is_cleaning_drone_hud_open

func calculate_cleaning_drone_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Hygiene & Disinfection Metrics
	var hygiene_pct = clamp(98.5 - active_cust_count * 1.5, 60.0, 99.9)
	var uvc_output_mw = 450.0 # 450 mW/cm2 UV-C Sterilization
	var drone_battery_pct = 94.0
	
	var is_drone_unlocked = upgrades.has("robot_cleaner") and upgrades["robot_cleaner"]["level"] > 0
	if is_drone_unlocked:
		hygiene_pct = 99.9
		uvc_output_mw = 1200.0
		drone_battery_pct = 88.5
		
	var rating_str = "🌟 SSS 바이러스 프리 (Clean 99.9%)" if hygiene_pct >= 99.0 else ("🟢 S 쾌적 위생" if hygiene_pct >= 85.0 else "🧹 A 일반")
	var reputation_bonus_pct = 20.0 if is_drone_unlocked else 8.0
	
	return {
		"hygiene_pct": hygiene_pct,
		"uvc_mw": uvc_output_mw,
		"battery_pct": drone_battery_pct,
		"rating": rating_str,
		"reputation_bonus": reputation_bonus_pct,
		"is_drone_unlocked": is_drone_unlocked
	}

# Iteration 151: Real-Time Store Customer Facial Micro-Expression & Mood Emotion AI Analyzer Subsystem
var is_emotion_hud_open: bool = false

func toggle_emotion_hud() -> bool:
	is_emotion_hud_open = not is_emotion_hud_open
	_play_sfx_safe("click")
	return is_emotion_hud_open

func calculate_customer_emotion_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Micro-Expression Emotion Index
	var happiness_pct = clamp(85.0 + decor_score * 0.1 - active_cust_count * 0.5, 50.0, 99.0)
	var stress_pct = clamp(35.0 - decor_score * 0.05 + active_cust_count * 0.8, 5.0, 75.0)
	
	var is_emotion_ai_unlocked = upgrades.has("study_planner") and upgrades["study_planner"]["level"] > 0
	if is_emotion_ai_unlocked:
		happiness_pct = min(99.0, happiness_pct + 10.0)
		stress_pct = max(4.0, stress_pct - 15.0)
		
	var mood_str = "😊 최상 몰입 (Peak Focus 95%)"
	if stress_pct > 50.0:
		mood_str = "😫 피로 스트레스 (High Stress)"
	elif happiness_pct < 70.0:
		mood_str = "🧘 평온 지속 (Neutral Serenity)"
		
	var retention_bonus = 18.0 if happiness_pct >= 85.0 else (8.0 if happiness_pct >= 70.0 else -5.0)
	
	return {
		"happiness": happiness_pct,
		"stress": stress_pct,
		"mood": mood_str,
		"retention_bonus": retention_bonus,
		"is_emotion_ai_unlocked": is_emotion_ai_unlocked
	}

# Iteration 152: Real-Time Store Dynamic Solar Sun-Tracking Motorized Blind & Shading Controller Subsystem
var is_shading_hud_open: bool = false

func toggle_shading_hud() -> bool:
	is_shading_hud_open = not is_shading_hud_open
	_play_sfx_safe("click")
	return is_shading_hud_open

func calculate_solar_shading_metrics() -> Dictionary:
	var solar_altitude_deg = 65.0
	var blind_angle_pct = 75.0
	var status_str = "😎 눈부심 완전 차단 (Glare 100% Blocked)"
	
	if time_of_day == "DAY":
		solar_altitude_deg = 65.0
		blind_angle_pct = 75.0
		status_str = "😎 직사광선 눈부심 차단 (Solar Tracking)"
	elif time_of_day == "DUSK":
		solar_altitude_deg = 20.0
		blind_angle_pct = 40.0
		status_str = "☀️ 석양 노을 채광 모드 (Warm Ambient)"
	else:
		solar_altitude_deg = 0.0
		blind_angle_pct = 95.0
		status_str = "🌙 야간 사생활 보호 차폐 (Night Closed)"
		
	var is_shading_unlocked = upgrades.has("premium_desk") and upgrades["premium_desk"]["level"] > 0
	var visibility_bonus = 17.0 if is_shading_unlocked else 7.0
	
	return {
		"solar_altitude": solar_altitude_deg,
		"blind_angle": blind_angle_pct,
		"status": status_str,
		"visibility_bonus": visibility_bonus,
		"is_shading_unlocked": is_shading_unlocked
	}

# Iteration 153: Real-Time Store High-Precision Smart Water Quality & Electrolyte Hydration Bar Subsystem
var is_water_hud_open: bool = false

func toggle_water_hud() -> bool:
	is_water_hud_open = not is_water_hud_open
	_play_sfx_safe("click")
	return is_water_hud_open

func calculate_water_quality_metrics() -> Dictionary:
	var tds_ppm = 8.0 # 8 ppm Ultra-Pure RO
	var hydrogen_ppm = 1.25 # 1.25 ppm Active Hydrogen
	var rating_str = "💎 프리미엄 RO 나노 수소수 (TDS 8ppm)"
	
	var is_water_unlocked = upgrades.has("coffee_roaster") and upgrades["coffee_roaster"]["level"] > 0
	if is_water_unlocked:
		tds_ppm = 4.2
		hydrogen_ppm = 1.60
		rating_str = "💎 SSS급 나노 전해질 수소수 (TDS 4.2ppm)"
		
	var brain_stamina_bonus = 19.0 if is_water_unlocked else 9.0
	
	return {
		"tds": tds_ppm,
		"hydrogen": hydrogen_ppm,
		"rating": rating_str,
		"brain_stamina_bonus": brain_stamina_bonus,
		"is_water_unlocked": is_water_unlocked
	}

# Iteration 154: Real-Time Store EEG Brainwave Focus & Neuro-Feedback Soundscape Synthesizer Subsystem
var is_neuro_hud_open: bool = false

func toggle_neuro_hud() -> bool:
	is_neuro_hud_open = not is_neuro_hud_open
	_play_sfx_safe("click")
	return is_neuro_hud_open

func calculate_neuro_feedback_metrics() -> Dictionary:
	var alpha_dominance_pct = 78.5
	var beta_alertness_pct = 64.0
	var neuro_state_str = "🧠 알파파 몰입 (Deep Alpha 10Hz)"
	
	var is_neuro_unlocked = upgrades.has("study_planner") and upgrades["study_planner"]["level"] > 0
	if is_neuro_unlocked:
		alpha_dominance_pct = 94.2
		beta_alertness_pct = 82.0
		neuro_state_str = "👑 SSS급 바이노럴 알파 뉴로피드백"
		
	var memory_synapse_bonus = 21.0 if is_neuro_unlocked else 10.0
	
	return {
		"alpha_pct": alpha_dominance_pct,
		"beta_pct": beta_alertness_pct,
		"state": neuro_state_str,
		"synapse_bonus": memory_synapse_bonus,
		"is_neuro_unlocked": is_neuro_unlocked
	}

# Iteration 155: Real-Time Store Dynamic Voice Command AI Butler & Kiosk Audio Assistant Subsystem
var is_voice_ai_hud_open: bool = false

func toggle_voice_ai_hud() -> bool:
	is_voice_ai_hud_open = not is_voice_ai_hud_open
	_play_sfx_safe("click")
	return is_voice_ai_hud_open

func calculate_voice_ai_butler_metrics() -> Dictionary:
	var stt_accuracy_pct = 95.0
	var nlp_latency_sec = 0.35
	var assistant_rating_str = "🗣️ S 오디오키오스크 안내 (NLP 95%)"
	
	var is_voice_unlocked = upgrades.has("kiosk_system") and upgrades["kiosk_system"]["level"] > 0
	if is_voice_unlocked:
		stt_accuracy_pct = 99.4
		nlp_latency_sec = 0.15
		assistant_rating_str = "👑 SSS급 실시간 음성 AI 집사 (NLP 99.4%)"
		
	var kiosk_revenue_bonus = 23.0 if is_voice_unlocked else 10.0
	
	return {
		"accuracy": stt_accuracy_pct,
		"latency": nlp_latency_sec,
		"rating": assistant_rating_str,
		"revenue_bonus": kiosk_revenue_bonus,
		"is_voice_unlocked": is_voice_unlocked
	}

# Iteration 156: Real-Time Store Holographic 3D Virtual AI Tutor & Lecture Assistant Subsystem
var is_hologram_hud_open: bool = false

func toggle_hologram_hud() -> bool:
	is_hologram_hud_open = not is_hologram_hud_open
	_play_sfx_safe("click")
	return is_hologram_hud_open

func calculate_holographic_tutor_metrics() -> Dictionary:
	var hologram_fps = 60.0
	var resolution_k = "4K Spatial"
	var tutor_status_str = "🔮 S 입체 강의 홀로그램 (60 FPS)"
	
	var is_holo_unlocked = upgrades.has("vip_lounge") and upgrades["vip_lounge"]["level"] > 0
	if is_holo_unlocked:
		hologram_fps = 120.0
		resolution_k = "8K Volumetric"
		tutor_status_str = "👑 SSS급 3D 홀로그램 AI 튜터 (120 FPS)"
		
	var exam_pass_bonus = 25.0 if is_holo_unlocked else 12.0
	
	return {
		"fps": hologram_fps,
		"resolution": resolution_k,
		"status": tutor_status_str,
		"exam_pass_bonus": exam_pass_bonus,
		"is_holo_unlocked": is_holo_unlocked
	}

# Iteration 157: Real-Time Store Kinetic Energy Harvesting & Piezoelectric Floor Power Generation Subsystem
var is_piezo_hud_open: bool = false

func toggle_piezo_hud() -> bool:
	is_piezo_hud_open = not is_piezo_hud_open
	_play_sfx_safe("click")
	return is_piezo_hud_open

func calculate_piezoelectric_energy_metrics() -> Dictionary:
	var total_cap = get_max_capacity()
	var active_cust_count = active_customers.size()
	
	# Kinetic Generation
	var kinetic_power_kw = active_cust_count * 0.45 + 1.2 # 1.2 kW base
	var carbon_offset_kg = kinetic_power_kw * 14.5
	var piezo_rating_str = "⚡ S 수확 발전 모드 (Kinetic 2.4kW)"
	
	var is_piezo_unlocked = upgrades.has("hepa_filter") and upgrades["hepa_filter"]["level"] > 0
	if is_piezo_unlocked:
		kinetic_power_kw += 3.8
		carbon_offset_kg += 45.0
		piezo_rating_str = "👑 SSS급 압전 자가발전 (Energy Net-Zero)"
		
	var eco_reputation_bonus = 22.0 if is_piezo_unlocked else 10.0
	
	return {
		"power_kw": kinetic_power_kw,
		"carbon_offset": carbon_offset_kg,
		"rating": piezo_rating_str,
		"eco_bonus": eco_reputation_bonus,
		"is_piezo_unlocked": is_piezo_unlocked
	}

# Iteration 158: Real-Time Store Autonomous Delivery Robot & Tabletop Refreshment Service Subsystem
var is_robot_hud_open: bool = false

func toggle_robot_hud() -> bool:
	is_robot_hud_open = not is_robot_hud_open
	_play_sfx_safe("click")
	return is_robot_hud_open

func calculate_delivery_robot_metrics() -> Dictionary:
	var active_robots = 2
	var delivery_latency_sec = 45.0
	var robot_status_str = "🤖 S 라율주행 서빙 로봇 (45s)"
	
	var is_robot_unlocked = upgrades.has("premium_cafe") and upgrades["premium_cafe"]["level"] > 0
	if is_robot_unlocked:
		active_robots = 5
		delivery_latency_sec = 18.0
		robot_status_str = "👑 SSS급 자율주행 AI 라스트마일 로봇 (18s)"
		
	var snack_revenue_bonus = 24.0 if is_robot_unlocked else 11.0
	
	return {
		"robots_count": active_robots,
		"latency": delivery_latency_sec,
		"status": robot_status_str,
		"snack_bonus": snack_revenue_bonus,
		"is_robot_unlocked": is_robot_unlocked
	}

# Iteration 159: Real-Time Store Quantum Encryption & Biometric Data Security Shield Subsystem
var is_shield_hud_open: bool = false

func toggle_shield_hud() -> bool:
	is_shield_hud_open = not is_shield_hud_open
	_play_sfx_safe("click")
	return is_shield_hud_open

func calculate_quantum_security_shield_metrics() -> Dictionary:
	var qkd_refresh_sec = 0.05
	var defense_pct = 99.9
	var shield_status_str = "🛡️ S 차세대 암호화 쉴드 (99.9%)"
	
	var is_shield_unlocked = upgrades.has("cctv_system") and upgrades["cctv_system"]["level"] > 0
	if is_shield_unlocked:
		qkd_refresh_sec = 0.001
		defense_pct = 99.999
		shield_status_str = "👑 SSS급 양자 암호 쉴드 (QKD Zero-Trust)"
		
	var vip_trust_bonus = 26.0 if is_shield_unlocked else 12.0
	
	return {
		"qkd_refresh": qkd_refresh_sec,
		"defense_pct": defense_pct,
		"status": shield_status_str,
		"trust_bonus": vip_trust_bonus,
		"is_shield_unlocked": is_shield_unlocked
	}

# Iteration 160: Real-Time Store Autonomous Satellite Network & High-Altitude Drone Data Relay Subsystem
var is_satellite_hud_open: bool = false

func toggle_satellite_hud() -> bool:
	is_satellite_hud_open = not is_satellite_hud_open
	_play_sfx_safe("click")
	return is_satellite_hud_open

func calculate_satellite_relay_metrics() -> Dictionary:
	var bandwidth_gbps = 25.0
	var latency_ms = 12.5
	var sat_status_str = "📡 S 드론 네트워크 리레이 (25 Gbps)"
	
	var is_sat_unlocked = upgrades.has("high_speed_wifi") and upgrades["high_speed_wifi"]["level"] > 0
	if is_sat_unlocked:
		bandwidth_gbps = 100.0
		latency_ms = 2.0
		sat_status_str = "👑 SSS급 양자 저궤도 위성 리레이 (100 Gbps)"
		
	var global_empire_bonus = 27.0 if is_sat_unlocked else 13.0
	
	return {
		"bandwidth": bandwidth_gbps,
		"latency": latency_ms,
		"status": sat_status_str,
		"empire_bonus": global_empire_bonus,
		"is_sat_unlocked": is_sat_unlocked
	}

# Iteration 161: Real-Time Store Fusion Nuclear Micro-Reactor & Wireless Resonance Power Subsystem
var is_fusion_hud_open: bool = false

func toggle_fusion_hud() -> bool:
	is_fusion_hud_open = not is_fusion_hud_open
	_play_sfx_safe("click")
	return is_fusion_hud_open

func calculate_fusion_reactor_metrics() -> Dictionary:
	var fusion_power_mw = 5.0
	var wireless_eff_pct = 95.0
	var fusion_status_str = "⚛️ S 초소형 SMR 발전 (5.0 MW)"
	
	var is_fusion_unlocked = upgrades.has("solar_panel") and upgrades["solar_panel"]["level"] > 0
	if is_fusion_unlocked:
		fusion_power_mw = 25.0
		wireless_eff_pct = 99.9
		fusion_status_str = "👑 SSS급 무제한 SMR 핵융합 발전 (Power Sovereignty)"
		
	var profit_margin_bonus = 28.0 if is_fusion_unlocked else 14.0
	
	return {
		"power_mw": fusion_power_mw,
		"wireless_eff": wireless_eff_pct,
		"status": fusion_status_str,
		"profit_bonus": profit_margin_bonus,
		"is_fusion_unlocked": is_fusion_unlocked
	}

# Iteration 162: Real-Time Store Quantum Supercomputer AI Curriculum Generator & Neural Exam Predictor Subsystem
var is_curriculum_hud_open: bool = false

func toggle_curriculum_hud() -> bool:
	is_curriculum_hud_open = not is_curriculum_hud_open
	_play_sfx_safe("click")
	return is_curriculum_hud_open

func calculate_quantum_curriculum_metrics() -> Dictionary:
	var compute_pflops = 2.5
	var predict_precision_pct = 96.5
	var curriculum_status_str = "💻 S 신경망 커리큘럼 예측기 (96.5%)"
	
	var is_curr_unlocked = upgrades.has("study_planner") and upgrades["study_planner"]["level"] > 0
	if is_curr_unlocked:
		compute_pflops = 10.0
		predict_precision_pct = 99.8
		curriculum_status_str = "👑 SSS급 양자 AI 시험 예측기 (99.8% Precision)"
		
	var premium_seat_bonus = 30.0 if is_curr_unlocked else 15.0
	
	return {
		"pflops": compute_pflops,
		"precision": predict_precision_pct,
		"status": curriculum_status_str,
		"seat_bonus": premium_seat_bonus,
		"is_curr_unlocked": is_curr_unlocked
	}

# Iteration 163: Real-Time Store Dynamic Solar Atmospheric Water Generator & Mineral Electrolyte Bar Subsystem
var is_awg_hud_open: bool = false

func toggle_awg_hud() -> bool:
	is_awg_hud_open = not is_awg_hud_open
	_play_sfx_safe("click")
	return is_awg_hud_open

func calculate_atmospheric_water_metrics() -> Dictionary:
	var water_output_l = 45.0
	var mineral_mg = 120.0
	var awg_status_str = "🌊 S 대기 집수 정수기 (45L/day)"
	
	var is_awg_unlocked = upgrades.has("coffee_roaster") and upgrades["coffee_roaster"]["level"] > 0
	if is_awg_unlocked:
		water_output_l = 120.0
		mineral_mg = 180.0
		awg_status_str = "👑 SSS급 공기 집수 태양광 수소전해질 바 (120L/day)"
		
	var vitality_duration_bonus = 29.0 if is_awg_unlocked else 14.0
	
	return {
		"output_l": water_output_l,
		"mineral_mg": mineral_mg,
		"status": awg_status_str,
		"vitality_bonus": vitality_duration_bonus,
		"is_awg_unlocked": is_awg_unlocked
	}

# Iteration 164: Real-Time Store Zero-Gravity Hydroponic Bio-Nutrient Vertical Farming & Fresh Superfood Smoothie Bar Subsystem
var is_farm_hud_open: bool = false

func toggle_farm_hud() -> bool:
	is_farm_hud_open = not is_farm_hud_open
	_play_sfx_safe("click")
	return is_farm_hud_open

func calculate_hydroponic_farm_metrics() -> Dictionary:
	var yield_kg = 10.0
	var absorption_pct = 90.0
	var farm_status_str = "🥗 S 스마트 수경재배 수직농장 (10kg/day)"
	
	var is_farm_unlocked = upgrades.has("protein_bar") and upgrades["protein_bar"]["level"] > 0
	if is_farm_unlocked:
		yield_kg = 35.0
		absorption_pct = 99.5
		farm_status_str = "👑 SSS급 무균 수경재배 수직농장 & 스무디 바 (35kg/day)"
		
	var superfood_profit_bonus = 31.0 if is_farm_unlocked else 15.0
	
	return {
		"yield_kg": yield_kg,
		"absorption": absorption_pct,
		"status": farm_status_str,
		"profit_bonus": superfood_profit_bonus,
		"is_farm_unlocked": is_farm_unlocked
	}

# Iteration 165: Real-Time Store Autonomous Exoskeleton Ergonomic Posture Assistance & Spinal Health Protection Subsystem
var is_exo_hud_open: bool = false

func toggle_exo_hud() -> bool:
	is_exo_hud_open = not is_exo_hud_open
	_play_sfx_safe("click")
	return is_exo_hud_open

func calculate_exoskeleton_posture_metrics() -> Dictionary:
	var support_force_n = 15.0
	var fatigue_reduction_pct = 92.0
	var exo_status_str = "🦾 S 하이브리드 자세 보정 (15N Support)"
	
	var is_exo_unlocked = upgrades.has("ergonomic_chair") and upgrades["ergonomic_chair"]["level"] > 0
	if is_exo_unlocked:
		support_force_n = 45.0
		fatigue_reduction_pct = 99.2
		exo_status_str = "👑 SSS급 자율 능동 척추 외골격 (45N Support)"
		
	var marathon_session_bonus = 32.0 if is_exo_unlocked else 16.0
	
	return {
		"support_force": support_force_n,
		"fatigue_reduction": fatigue_reduction_pct,
		"status": exo_status_str,
		"session_bonus": marathon_session_bonus,
		"is_exo_unlocked": is_exo_unlocked
	}

# Iteration 166: Real-Time Store Quantum Entanglement Sub-Space Instant Teleportation Delivery & Courier Relay Subsystem
var is_teleport_hud_open: bool = false

func toggle_teleport_hud() -> bool:
	is_teleport_hud_open = not is_teleport_hud_open
	_play_sfx_safe("click")
	return is_teleport_hud_open

func calculate_quantum_teleportation_metrics() -> Dictionary:
	var latency_sec = 0.5
	var stability_pct = 98.0
	var tp_status_str = "🌌 S 초고속 양자 리레이 배송 (0.5s)"
	
	var is_tp_unlocked = upgrades.has("kiosk") and upgrades["kiosk"]["level"] > 0
	if is_tp_unlocked:
		latency_sec = 0.001
		stability_pct = 99.999
		tp_status_str = "👑 SSS급 양자 얽힘 섭스페이스 순간이동 (0.001s)"
		
	var instant_order_bonus = 33.0 if is_tp_unlocked else 16.0
	
	return {
		"latency": latency_sec,
		"stability": stability_pct,
		"status": tp_status_str,
		"order_bonus": instant_order_bonus,
		"is_tp_unlocked": is_tp_unlocked
	}

# Iteration 167: Real-Time Store Sub-Zero Nitrogen Molecular Flash Freeze & Precision Coffee Bean Preservation Subsystem
var is_cryo_hud_open: bool = false

func toggle_cryo_hud() -> bool:
	is_cryo_hud_open = not is_cryo_hud_open
	_play_sfx_safe("click")
	return is_cryo_hud_open

func calculate_cryogenic_roaster_metrics() -> Dictionary:
	var temp_celsius = -20.0
	var aroma_preserve_pct = 95.0
	var cryo_status_str = "❄️ S 초저온 급속 냉동 보존 (-20℃)"
	
	var is_cryo_unlocked = upgrades.has("coffee_roaster") and upgrades["coffee_roaster"]["level"] > 0
	if is_cryo_unlocked:
		temp_celsius = -196.0
		aroma_preserve_pct = 99.99
		cryo_status_str = "👑 SSS급 -196℃ 액체질소 분자 급속냉동 원두 보존"
		
	var specialty_price_bonus = 34.0 if is_cryo_unlocked else 17.0
	
	return {
		"temp_c": temp_celsius,
		"aroma_pct": aroma_preserve_pct,
		"status": cryo_status_str,
		"price_bonus": specialty_price_bonus,
		"is_cryo_unlocked": is_cryo_unlocked
	}

# Iteration 168: Real-Time Store Zero-Trust Quantum Cryptographic Blockchain Decentralized Franchise Financial Treasury Subsystem
var is_treasury_hud_open: bool = false

func toggle_treasury_hud() -> bool:
	is_treasury_hud_open = not is_treasury_hud_open
	_play_sfx_safe("click")
	return is_treasury_hud_open

func calculate_quantum_treasury_metrics() -> Dictionary:
	var settle_speed_sec = 0.01
	var security_pct = 99.5
	var treasury_status_str = "💎 S 양자 체인 정산망 (0.01s)"
	
	var is_treasury_unlocked = upgrades.has("kiosk") and upgrades["kiosk"]["level"] > 0
	if is_treasury_unlocked:
		settle_speed_sec = 0.0001
		security_pct = 100.0
		treasury_status_str = "👑 SSS급 zk-SNARKs 양자 탈중앙화 결제 지불망 (0.0001s)"
		
	var dividend_yield_bonus = 35.0 if is_treasury_unlocked else 17.0
	
	return {
		"settle_speed": settle_speed_sec,
		"security": security_pct,
		"status": treasury_status_str,
		"dividend_bonus": dividend_yield_bonus,
		"is_treasury_unlocked": is_treasury_unlocked
	}

# Iteration 169: Real-Time Store Gravitational Wave Waveform Noise Cancellation Acoustic Sound Absorber Subsystem
var is_grav_acoustic_hud_open: bool = false

func toggle_grav_acoustic_hud() -> bool:
	is_grav_acoustic_hud_open = not is_grav_acoustic_hud_open
	_play_sfx_safe("click")
	return is_grav_acoustic_hud_open

func calculate_gravitational_acoustic_metrics() -> Dictionary:
	var cancel_pct = 95.0
	var noise_floor_db = 15.0
	var grav_status_str = "🌌 S 아쿠스틱 음향 상쇄 (15.0 dB)"
	
	var is_grav_unlocked = upgrades.has("anc_system") and upgrades["anc_system"]["level"] > 0
	if is_grav_unlocked:
		cancel_pct = 99.999
		noise_floor_db = 0.001
		grav_status_str = "👑 SSS급 중력파 위상 상쇄 완전 무소음 정적 존 (0.001 dB)"
		
	var focus_revenue_bonus = 36.0 if is_grav_unlocked else 18.0
	
	return {
		"cancel_pct": cancel_pct,
		"noise_floor_db": noise_floor_db,
		"status": grav_status_str,
		"revenue_bonus": focus_revenue_bonus,
		"is_grav_unlocked": is_grav_unlocked
	}

# Iteration 170: Real-Time Store Spatial Olfactory Pheromone Aromatherapy Air Diffusion Synthesizer Subsystem
var is_olfactory_hud_open: bool = false

func toggle_olfactory_hud() -> bool:
	is_olfactory_hud_open = not is_olfactory_hud_open
	_play_sfx_safe("click")
	return is_olfactory_hud_open

func calculate_olfactory_synthesizer_metrics() -> Dictionary:
	var scent_purity_pct = 90.0
	var stress_threshold_ppm = 0.5
	var olfactory_status_str = "🌿 S 라벤더 에센셜 디퓨저 (90.0%)"
	
	var is_olfactory_unlocked = upgrades.has("air_purifier") and upgrades["air_purifier"]["level"] > 0
	if is_olfactory_unlocked:
		scent_purity_pct = 99.98
		stress_threshold_ppm = 0.01
		olfactory_status_str = "👑 SSS급 피톤치드 알파 아로마 공간 디퓨저 (99.98%)"
		
	var mental_refresh_bonus = 37.0 if is_olfactory_unlocked else 18.0
	
	return {
		"purity_pct": scent_purity_pct,
		"stress_ppm": stress_threshold_ppm,
		"status": olfactory_status_str,
		"refresh_bonus": mental_refresh_bonus,
		"is_olfactory_unlocked": is_olfactory_unlocked
	}

# Iteration 171: Real-Time Store Sub-Atomic Particle Electromagnetic Field Wireless Kinetic Energy Energy Harvesting Subsystem
var is_harvesting_hud_open: bool = false

func toggle_harvesting_hud() -> bool:
	is_harvesting_hud_open = not is_harvesting_hud_open
	_play_sfx_safe("click")
	return is_harvesting_hud_open

func calculate_electromagnetic_harvesting_metrics() -> Dictionary:
	var convert_pct = 92.0
	var gen_power_kw = 10.0
	var harvest_status_str = "⚡ S 전자기 하베스터 (10.0 kW)"
	
	var is_harvest_unlocked = upgrades.has("solar_panel") and upgrades["solar_panel"]["level"] > 0
	if is_harvest_unlocked:
		convert_pct = 99.99
		gen_power_kw = 50.0
		harvest_status_str = "👑 SSS급 전자기장 무선 운동 에너지 하베스팅 (50.0 kW)"
		
	var power_margin_bonus = 38.0 if is_harvest_unlocked else 19.0
	
	return {
		"convert_pct": convert_pct,
		"power_kw": gen_power_kw,
		"status": harvest_status_str,
		"margin_bonus": power_margin_bonus,
		"is_harvest_unlocked": is_harvest_unlocked
	}

# Iteration 172: Real-Time Store Sub-Space Wormhole Tesseract Spatial Storage Expansion Subsystem
var is_tesseract_hud_open: bool = false

func toggle_tesseract_hud() -> bool:
	is_tesseract_hud_open = not is_tesseract_hud_open
	_play_sfx_safe("click")
	return is_tesseract_hud_open

func calculate_tesseract_expansion_metrics() -> Dictionary:
	var compress_pct = 95.0
	var capacity_mult = 2.0
	var tesseract_status_str = "🌀 S 테서랙트 웜홀 공간 확장 (2.0x)"
	
	var is_tesseract_unlocked = upgrades.has("study_desks") and upgrades["study_desks"]["level"] > 0
	if is_tesseract_unlocked:
		compress_pct = 99.999
		capacity_mult = 10.0
		tesseract_status_str = "👑 SSS급 4차원 테서랙트 웜홀 공간 왜곡 영토 확장 (10.0x)"
		
	var capacity_revenue_bonus = 39.0 if is_tesseract_unlocked else 19.5
	
	return {
		"compress_pct": compress_pct,
		"capacity_mult": capacity_mult,
		"status": tesseract_status_str,
		"revenue_bonus": capacity_revenue_bonus,
		"is_tesseract_unlocked": is_tesseract_unlocked
	}

# Iteration 173: Real-Time Store Tachyon Chrono Temporal Acceleration Time Dilation Subsystem
var is_tachyon_hud_open: bool = false

func toggle_tachyon_hud() -> bool:
	is_tachyon_hud_open = not is_tachyon_hud_open
	_play_sfx_safe("click")
	return is_tachyon_hud_open

func calculate_tachyon_chrono_metrics() -> Dictionary:
	var dilation_mult = 1.5
	var stability_pct = 95.0
	var tachyon_status_str = "⏳ S 크로노 가속기 (1.5x)"
	
	var is_tachyon_unlocked = upgrades.has("ai_tutor") and upgrades["ai_tutor"]["level"] > 0
	if is_tachyon_unlocked:
		dilation_mult = 3.0
		stability_pct = 99.999
		tachyon_status_str = "👑 SSS급 타키온 시공간 시간 왜곡 가속기 (3.0x)"
		
	var exam_revenue_bonus = 40.0 if is_tachyon_unlocked else 20.0
	
	return {
		"dilation_mult": dilation_mult,
		"stability_pct": stability_pct,
		"status": tachyon_status_str,
		"revenue_bonus": exam_revenue_bonus,
		"is_tachyon_unlocked": is_tachyon_unlocked
	}

# Iteration 174: Real-Time Store Sub-Conscious Neural Synapse Telepathic Memory Download Subsystem
var is_telepathic_hud_open: bool = false

func toggle_telepathic_hud() -> bool:
	is_telepathic_hud_open = not is_telepathic_hud_open
	_play_sfx_safe("click")
	return is_telepathic_hud_open

func calculate_neural_telepathic_metrics() -> Dictionary:
	var synapse_speed_tbs = 10.0
	var retention_pct = 95.0
	var telepathic_status_str = "🧠 S 텔레파시 시냅스 (10.0 TB/s)"
	
	var is_telepathic_unlocked = upgrades.has("wifi_router") and upgrades["wifi_router"]["level"] > 0
	if is_telepathic_unlocked:
		synapse_speed_tbs = 99.999
		retention_pct = 99.999
		telepathic_status_str = "👑 SSS급 텔레파시 신경 시냅스 지식 다운로드 (99.999 TB/s)"
		
	var memory_revenue_bonus = 41.0 if is_telepathic_unlocked else 20.5
	
	return {
		"speed_tbs": synapse_speed_tbs,
		"retention_pct": retention_pct,
		"status": telepathic_status_str,
		"revenue_bonus": memory_revenue_bonus,
		"is_telepathic_unlocked": is_telepathic_unlocked
	}

# Iteration 175: Real-Time Store Quantum Entanglement Antimatter Thermal Clean Energy Subsystem
var is_antimatter_hud_open: bool = false

func toggle_antimatter_hud() -> bool:
	is_antimatter_hud_open = not is_antimatter_hud_open
	_play_sfx_safe("click")
	return is_antimatter_hud_open

func calculate_antimatter_energy_metrics() -> Dictionary:
	var field_stability_pct = 96.0
	var energy_output_mw = 20.0
	var antimatter_status_str = "⚛️ S 반물질 발전기 (20.0 MW)"
	
	var is_antimatter_unlocked = upgrades.has("solar_panel") and upgrades["solar_panel"]["level"] > 0
	if is_antimatter_unlocked:
		field_stability_pct = 99.9999
		energy_output_mw = 100.0
		antimatter_status_str = "👑 SSS급 양자 얽힘 반물질 초청정 에너지 (100.0 MW)"
		
	var esg_margin_bonus = 42.0 if is_antimatter_unlocked else 21.0
	
	return {
		"stability_pct": field_stability_pct,
		"output_mw": energy_output_mw,
		"status": antimatter_status_str,
		"margin_bonus": esg_margin_bonus,
		"is_antimatter_unlocked": is_antimatter_unlocked
	}

# Iteration 176: Real-Time Store Holographic Multi-Dimensional Super-Computer AI Brain Simulation Subsystem
var is_supercomputer_hud_open: bool = false

func toggle_supercomputer_hud() -> bool:
	is_supercomputer_hud_open = not is_supercomputer_hud_open
	_play_sfx_safe("click")
	return is_supercomputer_hud_open

func calculate_holographic_supercomputer_metrics() -> Dictionary:
	var process_speed_pflops = 100.0
	var accuracy_pct = 98.0
	var supercomputer_status_str = "💻 S 홀로그램 AI (100.0 PFLOPS)"
	
	var is_supercomputer_unlocked = upgrades.has("kiosk") and upgrades["kiosk"]["level"] > 0
	if is_supercomputer_unlocked:
		process_speed_pflops = 1000.0
		accuracy_pct = 99.9999
		supercomputer_status_str = "👑 SSS급 홀로그램 다차원 슈퍼컴퓨터 AI 연산 (1,000.0 PFLOPS)"
		
	var net_income_bonus = 43.0 if is_supercomputer_unlocked else 21.5
	
	return {
		"speed_pflops": process_speed_pflops,
		"accuracy_pct": accuracy_pct,
		"status": supercomputer_status_str,
		"income_bonus": net_income_bonus,
		"is_supercomputer_unlocked": is_supercomputer_unlocked
	}

# Iteration 177: Real-Time Sub-Quantum Multiverse Dimensional Bifurcation Portal Engine
var is_multiverse_hud_open: bool = false

func toggle_multiverse_hud() -> bool:
	is_multiverse_hud_open = not is_multiverse_hud_open
	_play_sfx_safe("click")
	return is_multiverse_hud_open

func calculate_multiverse_bifurcation_metrics() -> Dictionary:
	var timeline_branches = 50.0
	var stability_pct = 98.5
	var multiverse_status_str = "🌌 S 다중우주 포탈 (50 타임라인)"
	
	var is_multiverse_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_multiverse_unlocked:
		timeline_branches = 1000.0
		stability_pct = 99.9999
		multiverse_status_str = "👑 SSS급 하위 퀀텀 다중우주 차원분기 포탈 (1,000 타임라인)"
		
	var parallel_revenue_bonus = 44.0 if is_multiverse_unlocked else 22.0
	
	return {
		"branches": timeline_branches,
		"stability_pct": stability_pct,
		"status": multiverse_status_str,
		"revenue_bonus": parallel_revenue_bonus,
		"is_multiverse_unlocked": is_multiverse_unlocked
	}

# Iteration 178: Sub-Space Zero-Point Energy Vacuum Fluctuation Capacitor Subsystem
var is_zero_point_hud_open: bool = false

func toggle_zero_point_hud() -> bool:
	is_zero_point_hud_open = not is_zero_point_hud_open
	_play_sfx_safe("click")
	return is_zero_point_hud_open

func calculate_zero_point_energy_metrics() -> Dictionary:
	var vacuum_density_gj = 50.0
	var casimir_freq_ghz = 500.0
	var zero_point_status_str = "⚡ S 제로포인트 캡시터 (50 GJ)"
	
	var is_zero_point_unlocked = upgrades.has("solar_panel") and upgrades["solar_panel"]["level"] > 0
	if is_zero_point_unlocked:
		vacuum_density_gj = 500.0
		casimir_freq_ghz = 1210.0
		zero_point_status_str = "👑 SSS급 하위 공간 제로포인트 에너지 캡시터 (500 GJ | 1.21 THz)"
		
	var utility_saving_bonus = 45.0 if is_zero_point_unlocked else 22.5
	
	return {
		"density_gj": vacuum_density_gj,
		"casimir_ghz": casimir_freq_ghz,
		"status": zero_point_status_str,
		"saving_bonus": utility_saving_bonus,
		"is_zero_point_unlocked": is_zero_point_unlocked
	}

# Iteration 179: Hyper-Dimensional Chrono-Field Quantum Resonance Converter Subsystem
var is_chrono_resonance_hud_open: bool = false

func toggle_chrono_resonance_hud() -> bool:
	is_chrono_resonance_hud_open = not is_chrono_resonance_hud_open
	_play_sfx_safe("click")
	return is_chrono_resonance_hud_open

func calculate_chrono_resonance_metrics() -> Dictionary:
	var resonance_freq_thz = 10.0
	var time_yield_bonus = 23.0
	var chrono_res_status_str = "⌛ S급 크로노 필드 공명기 (10 THz)"
	
	var is_chrono_res_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_chrono_res_unlocked:
		resonance_freq_thz = 99.999
		time_yield_bonus = 46.0
		chrono_res_status_str = "👑 SSS급 하이퍼 차원 크로노 필드 양자 공명 변환기 (99.999 THz | +46% 수확율)"
		
	return {
		"freq_thz": resonance_freq_thz,
		"yield_bonus": time_yield_bonus,
		"status": chrono_res_status_str,
		"is_chrono_res_unlocked": is_chrono_res_unlocked
	}

# Iteration 180: Quantum AI Neural-Synapse Cognitive Accelerator Subsystem
var is_neural_cognitive_hud_open: bool = false

func toggle_neural_cognitive_hud() -> bool:
	is_neural_cognitive_hud_open = not is_neural_cognitive_hud_open
	_play_sfx_safe("click")
	return is_neural_cognitive_hud_open

func calculate_neural_cognitive_metrics() -> Dictionary:
	var synapse_tflops = 100.0
	var cognitive_efficiency = 95.0
	var cog_status_str = "🧠 S급 인지 가속기 (100.0 TFLOPS)"
	
	var is_cog_unlocked = upgrades.has("ai_focus") and upgrades["ai_focus"]["level"] > 0
	if is_cog_unlocked:
		synapse_tflops = 888.8
		cognitive_efficiency = 99.9999
		cog_status_str = "👑 SSS급 양자 AI 신경-시냅스 인지 가속기 (888.8 TFLOPS | 99.9999%)"
		
	var exam_score_bonus = 52.0 if is_cog_unlocked else 26.0
	
	return {
		"tflops": synapse_tflops,
		"efficiency_pct": cognitive_efficiency,
		"status": cog_status_str,
		"exam_bonus": exam_score_bonus,
		"is_cog_unlocked": is_cog_unlocked
	}

# Iteration 181: Autonomous Bio-Rhythm Circadian Sleep-Cycle & Neuro-Rest Engine Subsystem
var is_bio_rest_hud_open: bool = false

func toggle_bio_rest_hud() -> bool:
	is_bio_rest_hud_open = not is_bio_rest_hud_open
	_play_sfx_safe("click")
	return is_bio_rest_hud_open

func calculate_bio_rest_metrics() -> Dictionary:
	var melatonin_pct = 94.0
	var alpha_hz = 10.5
	var rest_status_str = "💤 S급 바이오 서카디안 캡슐 (10.5 Hz)"
	
	var is_rest_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_rest_unlocked:
		melatonin_pct = 99.9999
		alpha_hz = 14.8
		rest_status_str = "👑 SSS급 자율 바이오리듬 서카디안 수면주기 신경휴식 캡슐 (99.9999% | 14.8 Hz)"
		
	var stamina_regen_bonus = 48.0 if is_rest_unlocked else 24.0
	
	return {
		"melatonin_pct": melatonin_pct,
		"alpha_hz": alpha_hz,
		"status": rest_status_str,
		"stamina_bonus": stamina_regen_bonus,
		"is_rest_unlocked": is_rest_unlocked
	}

# Iteration 182: Quantum Holographic Spatial-Acoustic Active Resonance Damping Engine Subsystem
var is_acoustic_damping_hud_open: bool = false

func toggle_acoustic_damping_hud() -> bool:
	is_acoustic_damping_hud_open = not is_acoustic_damping_hud_open
	_play_sfx_safe("click")
	return is_acoustic_damping_hud_open

func calculate_acoustic_damping_metrics() -> Dictionary:
	var damping_db = -60.0
	var phase_coherence_pct = 96.0
	var damping_status_str = "🔇 S급 홀로그램 음향 감쇠기 (-60.0 dB)"
	
	var is_damping_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_damping_unlocked:
		damping_db = -95.0
		phase_coherence_pct = 99.9999
		damping_status_str = "👑 SSS급 양자 홀로그램 공간-음향 능동 공명 감쇠기 (-95.0 dB | 99.9999%)"
		
	var focus_concentration_bonus = 50.0 if is_damping_unlocked else 25.0
	
	return {
		"damping_db": damping_db,
		"coherence_pct": phase_coherence_pct,
		"status": damping_status_str,
		"focus_bonus": focus_concentration_bonus,
		"is_damping_unlocked": is_damping_unlocked
	}

# Iteration 183: Autonomous Bio-Robotic Molecular Nanite Sanitation Engine Subsystem
var is_nanite_sanitation_hud_open: bool = false

func toggle_nanite_sanitation_hud() -> bool:
	is_nanite_sanitation_hud_open = not is_nanite_sanitation_hud_open
	_play_sfx_safe("click")
	return is_nanite_sanitation_hud_open

func calculate_nanite_sanitation_metrics() -> Dictionary:
	var nanite_count_m = 50.0
	var sterilization_pct = 97.0
	var nanite_status_str = "🤖 S급 분자 나노봇 위생 스웜 (50M)"
	
	var is_nanite_unlocked = upgrades.has("air_purifier") and upgrades["air_purifier"]["level"] > 0
	if is_nanite_unlocked:
		nanite_count_m = 500.0
		sterilization_pct = 99.9999
		nanite_status_str = "👑 SSS급 자율 분자 나노봇 초청정 소독 스웜 (500M | 99.9999%)"
		
	var cleanliness_bonus = 50.0 if is_nanite_unlocked else 25.0
	
	return {
		"count_m": nanite_count_m,
		"sterilization_pct": sterilization_pct,
		"status": nanite_status_str,
		"cleanliness_bonus": cleanliness_bonus,
		"is_nanite_unlocked": is_nanite_unlocked
	}

# Iteration 184: Autonomous Quantum-Entangled Sub-Atmospheric Gravitational Field Stabilizer Subsystem
var is_quantum_gravity_hud_open: bool = false

func toggle_quantum_gravity_hud() -> bool:
	is_quantum_gravity_hud_open = not is_quantum_gravity_hud_open
	_play_sfx_safe("click")
	return is_quantum_gravity_hud_open

func calculate_quantum_gravity_metrics() -> Dictionary:
	var stability_pct = 95.0
	var graviton_flux_mhz = 250.0
	var gravity_status_str = "🌌 S급 중력장 안정기 (250 MHz)"
	
	var is_gravity_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_gravity_unlocked:
		stability_pct = 99.9999
		graviton_flux_mhz = 777.7
		gravity_status_str = "👑 SSS급 자율 양자 얽힘 대기권-하위 중력장 안정화 엔진 (99.9999% | 777.7 MHz)"
		
	var ergonomic_bonus = 55.0 if is_gravity_unlocked else 27.5
	
	return {
		"stability_pct": stability_pct,
		"graviton_mhz": graviton_flux_mhz,
		"status": gravity_status_str,
		"ergonomic_bonus": ergonomic_bonus,
		"is_gravity_unlocked": is_gravity_unlocked
	}

# Iteration 185: Autonomous Bio-Synaptic Neural-Memory Crystal Knowledge Synthesizer Subsystem
var is_memory_crystal_hud_open: bool = false

func toggle_memory_crystal_hud() -> bool:
	is_memory_crystal_hud_open = not is_memory_crystal_hud_open
	_play_sfx_safe("click")
	return is_memory_crystal_hud_open

func calculate_memory_crystal_metrics() -> Dictionary:
	var synthesis_gbps = 150.0
	var retention_pct = 96.0
	var crystal_status_str = "💎 S급 신경 메모리 결정체 (150 Gbps)"
	
	var is_crystal_unlocked = upgrades.has("ai_focus") and upgrades["ai_focus"]["level"] > 0
	if is_crystal_unlocked:
		synthesis_gbps = 999.9
		retention_pct = 99.9999
		crystal_status_str = "👑 SSS급 자율 바이오-시냅스 신경-메모리 결정체 지식 합성기 (999.9 Gbps | 99.9999%)"
		
	var exam_mastery_bonus = 60.0 if is_crystal_unlocked else 30.0
	
	return {
		"synthesis_gbps": synthesis_gbps,
		"retention_pct": retention_pct,
		"status": crystal_status_str,
		"mastery_bonus": exam_mastery_bonus,
		"is_crystal_unlocked": is_crystal_unlocked
	}

# Iteration 186: Autonomous Super-Conductive Zero-Resistance Power Matrix Grid Subsystem
var is_superconductive_power_hud_open: bool = false

func toggle_superconductive_power_hud() -> bool:
	is_superconductive_power_hud_open = not is_superconductive_power_hud_open
	_play_sfx_safe("click")
	return is_superconductive_power_hud_open

func calculate_superconductive_power_metrics() -> Dictionary:
	var grid_efficiency_pct = 95.0
	var critical_temp_k = 77.0
	var power_status_str = "⚡ S급 액체질소 초전도 그리드 (77 K)"
	
	var is_power_unlocked = upgrades.has("coffee_machine") and upgrades["coffee_machine"]["level"] > 0
	if is_power_unlocked:
		grid_efficiency_pct = 99.9999
		critical_temp_k = 298.15
		power_status_str = "👑 SSS급 상온 초전도 제로-저항 전력 매트릭스 그리드 (298.15 K | 99.9999%)"
		
	var utility_cost_saving = 60.0 if is_power_unlocked else 30.0
	
	return {
		"efficiency_pct": grid_efficiency_pct,
		"temp_k": critical_temp_k,
		"status": power_status_str,
		"cost_saving": utility_cost_saving,
		"is_power_unlocked": is_power_unlocked
	}

# Iteration 187: Autonomous Bio-Photonic Quantum Solar-Spectrum Photosynthesis Air-Regenerator Subsystem
var is_biophotonic_air_hud_open: bool = false

func toggle_biophotonic_air_hud() -> bool:
	is_biophotonic_air_hud_open = not is_biophotonic_air_hud_open
	_play_sfx_safe("click")
	return is_biophotonic_air_hud_open

func calculate_biophotonic_air_metrics() -> Dictionary:
	var oxygen_purity_pct = 96.0
	var co2_scrubbed_ppm = 400.0
	var air_status_str = "🌿 S급 광합성 공기재생기 (400 PPM)"
	
	var is_air_unlocked = upgrades.has("air_purifier") and upgrades["air_purifier"]["level"] > 0
	if is_air_unlocked:
		oxygen_purity_pct = 99.9999
		co2_scrubbed_ppm = 850.0
		air_status_str = "👑 SSS급 자율 바이오-광학 퀀텀 광합성 공기재생기 (99.9999% | -850 PPM)"
		
	var cognitive_alertness_bonus = 65.0 if is_air_unlocked else 32.5
	
	return {
		"oxygen_purity": oxygen_purity_pct,
		"co2_scrubbed": co2_scrubbed_ppm,
		"status": air_status_str,
		"alertness_bonus": cognitive_alertness_bonus,
		"is_air_unlocked": is_air_unlocked
	}

# Iteration 188: Autonomous Sub-Quantum Dark-Matter Zero-Point Gravity Deflection Matrix Engine Subsystem
var is_dark_matter_gravity_hud_open: bool = false

func toggle_dark_matter_gravity_hud() -> bool:
	is_dark_matter_gravity_hud_open = not is_dark_matter_gravity_hud_open
	_play_sfx_safe("click")
	return is_dark_matter_gravity_hud_open

func calculate_dark_matter_gravity_metrics() -> Dictionary:
	var density_gcm3 = 10.0
	var deflection_deg = 0.05
	var dm_status_str = "🌌 S급 다크매터 중력 편향기 (10 g/cm³)"
	
	var is_dm_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_dm_unlocked:
		density_gcm3 = 99.9999
		deflection_deg = 0.0012
		dm_status_str = "👑 SSS급 자율 아원자 다크매터 제로포인트 중력편향 엔진 (99.9999 g/cm³ | 0.0012°)"
		
	var levitation_bonus = 70.0 if is_dm_unlocked else 35.0
	
	return {
		"density_gcm3": density_gcm3,
		"deflection_deg": deflection_deg,
		"status": dm_status_str,
		"levitation_bonus": levitation_bonus,
		"is_dm_unlocked": is_dm_unlocked
	}

# Iteration 189: Autonomous Bio-Dynamic Sub-Molecular Peptide Neuro-Stimulator Subsystem
var is_peptide_stimulator_hud_open: bool = false

func toggle_peptide_stimulator_hud() -> bool:
	is_peptide_stimulator_hud_open = not is_peptide_stimulator_hud_open
	_play_sfx_safe("click")
	return is_peptide_stimulator_hud_open

func calculate_peptide_stimulator_metrics() -> Dictionary:
	var peptide_ppm = 10.0
	var speed_ms = 120.0
	var pep_status_str = "🧬 S급 바이오 펩타이드 신경 자극기 (10 PPM)"
	
	var is_pep_unlocked = upgrades.has("ai_focus") and upgrades["ai_focus"]["level"] > 0
	if is_pep_unlocked:
		peptide_ppm = 99.9999
		speed_ms = 500.0
		pep_status_str = "👑 SSS급 자율 바이오-다이내믹 아원자 펩타이드 신경-자극 엔진 (99.9999 PPM | 500 m/s)"
		
	var endurance_bonus = 75.0 if is_pep_unlocked else 37.5
	
	return {
		"peptide_ppm": peptide_ppm,
		"speed_ms": speed_ms,
		"status": pep_status_str,
		"endurance_bonus": endurance_bonus,
		"is_pep_unlocked": is_pep_unlocked
	}

# Iteration 190: Autonomous Global Quantum-Mesh Franchise Landmark Satellite Network Subsystem
var is_satellite_mesh_hud_open: bool = false

func toggle_satellite_mesh_hud() -> bool:
	is_satellite_mesh_hud_open = not is_satellite_mesh_hud_open
	_play_sfx_safe("click")
	return is_satellite_mesh_hud_open

func calculate_satellite_mesh_metrics() -> Dictionary:
	var bandwidth_tbps = 100.0
	var latency_ms = 0.05
	var sat_status_str = "🛰️ S급 궤도 위성 네트워크 (100 Tbps)"
	
	var is_sat_unlocked = upgrades.has("kiosk") and upgrades["kiosk"]["level"] > 0
	if is_sat_unlocked:
		bandwidth_tbps = 9999.9
		latency_ms = 0.0001
		sat_status_str = "👑 SSS급 자율 글로벌 퀀텀-메쉬 위성 네트워크 (9999.9 Tbps | 0.0001 ms)"
		
	var royalty_bonus = 80.0 if is_sat_unlocked else 40.0
	
	return {
		"bandwidth_tbps": bandwidth_tbps,
		"latency_ms": latency_ms,
		"status": sat_status_str,
		"royalty_bonus": royalty_bonus,
		"is_sat_unlocked": is_sat_unlocked
	}

# Iteration 191: Autonomous Cryogenic Quantum-Infused Nitrogen Roast Energy Synthesizer Subsystem
var is_cryo_roaster_hud_open: bool = false

func toggle_cryo_roaster_hud() -> bool:
	is_cryo_roaster_hud_open = not is_cryo_roaster_hud_open
	_play_sfx_safe("click")
	return is_cryo_roaster_hud_open

func calculate_cryo_roaster_metrics() -> Dictionary:
	var temp_celsius = -78.0
	var retention_pct = 95.0
	var cryo_status_str = "❄️ S급 드라이아이스 로스팅 (-78 °C)"
	
	var is_cryo_unlocked = upgrades.has("coffee_machine") and upgrades["coffee_machine"]["level"] > 0
	if is_cryo_unlocked:
		temp_celsius = -196.0
		retention_pct = 99.9999
		cryo_status_str = "👑 SSS급 자율 극저온 퀀텀-액체질소 영하-로스팅 합성기 (-196.0 °C | 99.9999%)"
		
	var satisfaction_bonus = 85.0 if is_cryo_unlocked else 42.5
	
	return {
		"temp_celsius": temp_celsius,
		"retention_pct": retention_pct,
		"status": cryo_status_str,
		"satisfaction_bonus": satisfaction_bonus,
		"is_cryo_unlocked": is_cryo_unlocked
	}

# Iteration 192: Autonomous Bio-Robotic Kinetic Exoskeleton Posture Corrector Subsystem
var is_exoskeleton_corrector_hud_open: bool = false

func toggle_exoskeleton_corrector_hud() -> bool:
	is_exoskeleton_corrector_hud_open = not is_exoskeleton_corrector_hud_open
	_play_sfx_safe("click")
	return is_exoskeleton_corrector_hud_open

func calculate_exoskeleton_corrector_metrics() -> Dictionary:
	var alignment_pct = 90.0
	var fatigue_red_pct = 85.0
	var exo_status_str = "🦾 S급 외골격 체형교정기 (90% 정밀도)"
	
	var is_exo_unlocked = upgrades.has("chair") and upgrades["chair"]["level"] > 0
	if is_exo_unlocked:
		alignment_pct = 99.9999
		fatigue_red_pct = 98.5
		exo_status_str = "👑 SSS급 자율 바이오-로보틱 생체역학 외골격 체형교정기 (99.9999% | -98.5%)"
		
	var focus_bonus = 90.0 if is_exo_unlocked else 45.0
	
	return {
		"alignment_pct": alignment_pct,
		"fatigue_red_pct": fatigue_red_pct,
		"status": exo_status_str,
		"focus_bonus": focus_bonus,
		"is_exo_unlocked": is_exo_unlocked
	}

# Iteration 193: Autonomous Atmospheric Vapor-Harvesting Pure Water Generator Subsystem
# Iteration 193: Autonomous Atmospheric Vapor-Harvesting Pure Water Generator Subsystem
var is_nano_atmospheric_water_hud_open: bool = false

func toggle_nano_atmospheric_water_hud() -> bool:
	is_nano_atmospheric_water_hud_open = not is_nano_atmospheric_water_hud_open
	_play_sfx_safe("click")
	return is_nano_atmospheric_water_hud_open

func calculate_nano_atmospheric_water_metrics() -> Dictionary:
	var extraction_rate_l_day = 200.0
	var water_purity_pct = 99.0
	var water_status_str = "💧 S급 대기 수자원 생성기 (200 L/일)"
	
	var is_water_unlocked = upgrades.has("coffee_machine") and upgrades["coffee_machine"]["level"] > 0
	if is_water_unlocked:
		extraction_rate_l_day = 999.9
		water_purity_pct = 99.9999
		water_status_str = "👑 SSS급 자율 대기 수자원 응축 순수 생성기 (999.9 L/일 | 99.9999%)"
		
	var utility_saving_bonus = 92.0 if is_water_unlocked else 46.0
	
	return {
		"extraction_rate_l_day": extraction_rate_l_day,
		"water_purity_pct": water_purity_pct,
		"status": water_status_str,
		"utility_saving_bonus": utility_saving_bonus,
		"is_water_unlocked": is_water_unlocked
	}

# Iteration 194: Autonomous Aeroponic Vertical Botanical Nutrient-Mist Injector Subsystem
var is_aeroponic_botanical_hud_open: bool = false

func toggle_aeroponic_botanical_hud() -> bool:
	is_aeroponic_botanical_hud_open = not is_aeroponic_botanical_hud_open
	_play_sfx_safe("click")
	return is_aeroponic_botanical_hud_open

func calculate_aeroponic_botanical_metrics() -> Dictionary:
	var mist_micron = 15.0
	var oxygen_boost_pct = 92.0
	var aero_status_str = "🌿 S급 초음파 미세안개 영하 분사기 (15 µm)"
	
	var is_aero_unlocked = upgrades.has("interior") and upgrades["interior"]["level"] > 0
	if is_aero_unlocked:
		mist_micron = 5.0
		oxygen_boost_pct = 99.9999
		aero_status_str = "👑 SSS급 자율 에어로포닉 수직 식물원 영양-안개 분사 엔진 (5.0 µm | 99.9999%)"
		
	var restoration_bonus = 95.0 if is_aero_unlocked else 47.5
	
	return {
		"mist_micron": mist_micron,
		"oxygen_boost_pct": oxygen_boost_pct,
		"status": aero_status_str,
		"restoration_bonus": restoration_bonus,
		"is_aero_unlocked": is_aero_unlocked
	}

# Iteration 195: Autonomous Super-Conductive Magnetic Quantum Levitation Floor Matrix Subsystem
var is_maglev_floor_hud_open: bool = false

func toggle_maglev_floor_hud() -> bool:
	is_maglev_floor_hud_open = not is_maglev_floor_hud_open
	_play_sfx_safe("click")
	return is_maglev_floor_hud_open

func calculate_maglev_floor_metrics() -> Dictionary:
	var flux_tesla = 2.5
	var stability_pct = 95.0
	var maglev_status_str = "🧲 S급 자기부유 바닥 (2.5 Tesla)"
	
	var is_maglev_unlocked = upgrades.has("interior") and upgrades["interior"]["level"] > 0
	if is_maglev_unlocked:
		flux_tesla = 15.0
		stability_pct = 99.9999
		maglev_status_str = "👑 SSS급 자율 초전도 자기장 양자 부유 바닥 매트릭스 (15.0 T | 99.9999%)"
		
	var isolation_bonus = 98.0 if is_maglev_unlocked else 49.0
	
	return {
		"flux_tesla": flux_tesla,
		"stability_pct": stability_pct,
		"status": maglev_status_str,
		"isolation_bonus": isolation_bonus,
		"is_maglev_unlocked": is_maglev_unlocked
	}

# Iteration 196: Autonomous Quantum-Entangled Sub-Space Temporal Chrono-Dilation Field Stabilizer Subsystem
var is_chrono_dilation_hud_open: bool = false

func toggle_chrono_dilation_hud() -> bool:
	is_chrono_dilation_hud_open = not is_chrono_dilation_hud_open
	_play_sfx_safe("click")
	return is_chrono_dilation_hud_open

func calculate_chrono_dilation_metrics() -> Dictionary:
	var time_dilation_factor = 1.05
	var chronon_stability_pct = 95.0
	var chrono_status_str = "⏳ S급 크로노 시간지연 필드 (1.05x)"
	
	var is_chrono_unlocked = upgrades.has("study_desk") and upgrades["study_desk"]["level"] > 0
	if is_chrono_unlocked:
		time_dilation_factor = 1.25
		chronon_stability_pct = 99.9999
		chrono_status_str = "👑 SSS급 자율 아원자 퀀텀-시간지연 크로노 필드 안정기 (1.25x | 99.9999%)"
		
	var efficiency_bonus = 100.0 if is_chrono_unlocked else 50.0
	
	return {
		"time_dilation_factor": time_dilation_factor,
		"chronon_stability_pct": chronon_stability_pct,
		"status": chrono_status_str,
		"efficiency_bonus": efficiency_bonus,
		"is_chrono_unlocked": is_chrono_unlocked
	}

# Iteration 197: Autonomous Bio-Synaptic Neural-Pattern Cognition Memory Crystallizer Subsystem
var is_neural_crystallizer_hud_open: bool = false

func toggle_neural_crystallizer_hud() -> bool:
	is_neural_crystallizer_hud_open = not is_neural_crystallizer_hud_open
	_play_sfx_safe("click")
	return is_neural_crystallizer_hud_open

func calculate_neural_crystallizer_metrics() -> Dictionary:
	var speed_mbps = 500.0
	var recall_pct = 95.0
	var crys_status_str = "💎 S급 신경 패턴 결정체화기 (500 Mbps)"
	
	var is_crys_unlocked = upgrades.has("ai_focus") and upgrades["ai_focus"]["level"] > 0
	if is_crys_unlocked:
		speed_mbps = 9999.9
		recall_pct = 99.9999
		crys_status_str = "👑 SSS급 자율 바이오-시냅스 신경-패턴 인지 기억 결정체화 엔진 (9999.9 Mbps | 99.9999%)"
		
	var mastery_bonus = 105.0 if is_crys_unlocked else 52.5
	
	return {
		"speed_mbps": speed_mbps,
		"recall_pct": recall_pct,
		"status": crys_status_str,
		"mastery_bonus": mastery_bonus,
		"is_crys_unlocked": is_crys_unlocked
	}

# Iteration 198: Autonomous Super-Conductive Photonic Laser Wireless Power Transmission Network Subsystem
var is_photonic_power_hud_open: bool = false

func toggle_photonic_power_hud() -> bool:
	is_photonic_power_hud_open = not is_photonic_power_hud_open
	_play_sfx_safe("click")
	return is_photonic_power_hud_open

func calculate_photonic_power_metrics() -> Dictionary:
	var laser_kw = 5.0
	var efficiency_pct = 95.0
	var photonic_status_str = "⚡ S급 포토닉 무선전력 전송기 (5.0 kW)"
	
	var is_photonic_unlocked = upgrades.has("solar_ess") and upgrades["solar_ess"]["level"] > 0
	if is_photonic_unlocked:
		laser_kw = 50.0
		efficiency_pct = 99.9999
		photonic_status_str = "👑 SSS급 자율 초전도 포토닉 레이저 무선 전력 전송 네트워크 (50.0 kW | 99.9999%)"
		
	var grid_saving_bonus = 110.0 if is_photonic_unlocked else 55.0
	
	return {
		"laser_kw": laser_kw,
		"efficiency_pct": efficiency_pct,
		"status": photonic_status_str,
		"grid_saving_bonus": grid_saving_bonus,
		"is_photonic_unlocked": is_photonic_unlocked
	}

# Iteration 199: Autonomous Sub-Quantum Dark-Matter Dark-Energy Dimensional Energy Converter Subsystem
var is_dark_energy_converter_hud_open: bool = false

func toggle_dark_energy_converter_hud() -> bool:
	is_dark_energy_converter_hud_open = not is_dark_energy_converter_hud_open
	_play_sfx_safe("click")
	return is_dark_energy_converter_hud_open

func calculate_dark_energy_converter_metrics() -> Dictionary:
	var density_joule = 1.0e15
	var expansion_pct = 95.0
	var de_status_str = "🌌 S급 암흑에너지 차원 전환기 (1.0e15 J/m³)"
	
	var is_de_unlocked = upgrades.has("solar_ess") and upgrades["solar_ess"]["level"] > 0
	if is_de_unlocked:
		density_joule = 9.9999e18
		expansion_pct = 99.9999
		de_status_str = "👑 SSS급 자율 아원자 다크매터 암흑에너지 차원 전환기 (9.9999e18 J/m³ | 99.9999%)"
		
	var cosmic_energy_bonus = 115.0 if is_de_unlocked else 57.5
	
	return {
		"density_joule": density_joule,
		"expansion_pct": expansion_pct,
		"status": de_status_str,
		"cosmic_energy_bonus": cosmic_energy_bonus,
		"is_de_unlocked": is_de_unlocked
	}

# Iteration 200: Autonomous Super-Conductive Quantum Singularity Event-Horizon Gravity-Well Power-Station Subsystem
var is_singularity_power_hud_open: bool = false

func toggle_singularity_power_hud() -> bool:
	is_singularity_power_hud_open = not is_singularity_power_hud_open
	_play_sfx_safe("click")
	return is_singularity_power_hud_open

func calculate_singularity_power_metrics() -> Dictionary:
	var mass_kg = 1.0e20
	var hawking_gw = 50.0
	var sing_status_str = "🌌 S급 싱귤래리티 중력우물 발전소 (50.0 GW)"
	
	var is_sing_unlocked = upgrades.has("solar_ess") and upgrades["solar_ess"]["level"] > 0
	if is_sing_unlocked:
		mass_kg = 1.989e30
		hawking_gw = 999.9
		sing_status_str = "👑 SSS급 자율 초전도 퀀텀 싱귤래리티 사건의지평선 중력우물 발전소 (999.9 GW | 1.989e30 kg)"
		
	var infinite_power_bonus = 120.0 if is_sing_unlocked else 60.0
	
	return {
		"mass_kg": mass_kg,
		"hawking_gw": hawking_gw,
		"status": sing_status_str,
		"infinite_power_bonus": infinite_power_bonus,
		"is_sing_unlocked": is_sing_unlocked
	}

# Iteration 201: Autonomous Bio-Photonic Neural-Resonance Memory-Crystal Transmutation Reactor Subsystem
var is_transmutation_reactor_hud_open: bool = false

func toggle_transmutation_reactor_hud() -> bool:
	is_transmutation_reactor_hud_open = not is_transmutation_reactor_hud_open
	_play_sfx_safe("click")
	return is_transmutation_reactor_hud_open

func calculate_transmutation_reactor_metrics() -> Dictionary:
	var rate_gbps = 5.0
	var purity_pct = 95.0
	var trans_status_str = "⚛️ S급 신경-공명 기억-변무테이션 리액터 (5.0 Gbps)"
	
	var is_trans_unlocked = upgrades.has("ai_focus") and upgrades["ai_focus"]["level"] > 0
	if is_trans_unlocked:
		rate_gbps = 99.9999
		purity_pct = 99.9999
		trans_status_str = "👑 SSS급 자율 바이오-포토닉 신경-공명 기억-결정체 변무테이션 리액터 (99.9999 Gbps | 99.9999%)"
		
	var absorption_bonus = 125.0 if is_trans_unlocked else 62.5
	
	return {
		"rate_gbps": rate_gbps,
		"purity_pct": purity_pct,
		"status": trans_status_str,
		"absorption_bonus": absorption_bonus,
		"is_trans_unlocked": is_trans_unlocked
	}

# Iteration 202: Autonomous Global Quantum-Entangled Franchise Franchise-Ledger Node Relay Subsystem
var is_franchise_ledger_hud_open: bool = false

func toggle_franchise_ledger_hud() -> bool:
	is_franchise_ledger_hud_open = not is_franchise_ledger_hud_open
	_play_sfx_safe("click")
	return is_franchise_ledger_hud_open

func calculate_franchise_ledger_metrics() -> Dictionary:
	var sync_latency_ms = 0.01
	var active_nodes = 100
	var ledger_status_str = "🌐 S급 글로벌 프랜차이즈 원장 노드 (100 노드)"
	
	var is_ledger_unlocked = upgrades.has("kiosk") and upgrades["kiosk"]["level"] > 0
	if is_ledger_unlocked:
		sync_latency_ms = 0.0000001
		active_nodes = 10000
		ledger_status_str = "👑 SSS급 자율 글로벌 퀀텀 얽힘 프랜차이즈 가맹 원장 노드 리레이 (10000 노드 | 1e-7 ms)"
		
	var royalty_bonus = 130.0 if is_ledger_unlocked else 65.0
	
	return {
		"sync_latency_ms": sync_latency_ms,
		"active_nodes": active_nodes,
		"status": ledger_status_str,
		"royalty_bonus": royalty_bonus,
		"is_ledger_unlocked": is_ledger_unlocked
	}

# Iteration 203: Dynamic 2.5D Atmospheric Weather & Window Lighting Shader System
var current_weather_type: String = "rainy" # "sunny", "rainy", "snowy", "cloudy"
var weather_cycle_timer: float = 0.0

func cycle_weather() -> String:
	var weathers = ["sunny", "rainy", "snowy", "cloudy"]
	var idx = weathers.find(current_weather_type)
	idx = (idx + 1) % weathers.size()
	current_weather_type = weathers[idx]
	return current_weather_type

func get_weather_info() -> Dictionary:
	var weather_name = "☀️ 맑음 (따스한 햇살)"
	var coffee_craving_bonus = 10.0
	var ambient_color = Color(1.0, 0.98, 0.9)
	
	match current_weather_type:
		"rainy":
			weather_name = "🌧️ 빗소리 레이니 데이 (아늑한 감성 분위기)"
			coffee_craving_bonus = 25.0
			ambient_color = Color(0.7, 0.75, 0.9)
		"snowy":
			weather_name = "❄️ 포근한 눈 내리는 날 (따뜻한 라떼 인기 뿜뿜)"
			coffee_craving_bonus = 30.0
			ambient_color = Color(0.85, 0.9, 1.0)
		"cloudy":
			weather_name = "☁️ 구름 많은 운치 있는 날 (집중하기 좋은 조명)"
			coffee_craving_bonus = 15.0
			ambient_color = Color(0.8, 0.82, 0.88)
		_:
			weather_name = "☀️ 맑음 (따스한 햇살)"
			coffee_craving_bonus = 10.0
			ambient_color = Color(1.0, 0.98, 0.9)
			
	return {
		"weather_type": current_weather_type,
		"weather_name": weather_name,
		"coffee_craving_bonus": coffee_craving_bonus,
		"ambient_color": ambient_color
	}

# Iteration 204: Interactive 2.5D Desk Placement & Magnetic Grid Snapping Visual Feedback
var seat_custom_positions: Dictionary = {} # seat_idx -> Vector2
var seat_orientations: Dictionary = {} # seat_idx -> int (0, 90, 180, 270 degrees)

func get_nearest_grid_snap(raw_pos: Vector2) -> Vector2:
	var tile_w = 110.0
	var tile_h = 75.0
	var start_x = 60.0
	var start_y = 160.0
	
	var col = round((raw_pos.x - start_x) / tile_w)
	var row = round((raw_pos.y - start_y) / tile_h)
	
	col = clamp(col, 0, 4)
	row = clamp(row, 0, 3)
	
	var snapped_x = start_x + col * tile_w
	var snapped_y = start_y + row * tile_h
	return Vector2(snapped_x, snapped_y)

func move_seat_position(seat_idx: int, target_pos: Vector2) -> Vector2:
	var snapped = get_nearest_grid_snap(target_pos)
	seat_custom_positions[seat_idx] = snapped
	_play_sfx_safe("click")
	return snapped

func rotate_seat_placement(seat_idx: int) -> int:
	var cur_rot = seat_orientations.get(seat_idx, 0)
	var new_rot = (cur_rot + 90) % 360
	seat_orientations[seat_idx] = new_rot
	_play_sfx_safe("click")
	return new_rot

# Iteration 205: Interactive Snack Bar & Bakery Restock QTE Mini-Game Engine
var is_qte_mini_game_active: bool = false
var qte_target_timing: float = 0.85
var qte_current_progress: float = 0.0

func trigger_snack_restock_qte() -> Dictionary:
	is_qte_mini_game_active = true
	qte_current_progress = 0.0
	_play_sfx_safe("click")
	return {
		"active": true,
		"target_timing": qte_target_timing,
		"msg": "🍰 샌드위치 & 케이크 핫타임 재충전 QTE 미니게임 발동!"
	}

func submit_qte_timing(hit_pct: float) -> Dictionary:
	is_qte_mini_game_active = false
	var is_perfect = hit_pct >= 0.8 and hit_pct <= 0.95
	var bonus_stock = 10 if is_perfect else 5
	
	bakery_stock["cheesecake"] = bakery_stock.get("cheesecake", 0) + bonus_stock
	bakery_stock["croissant"] = bakery_stock.get("croissant", 0) + bonus_stock
	
	if is_perfect:
		add_money(1500.0)
		_play_sfx_safe("fanfare")
	else:
		add_money(500.0)
		_play_sfx_safe("click")
		
	return {
		"is_perfect": is_perfect,
		"hit_pct": hit_pct,
		"bonus_stock": bonus_stock,
		"msg": "⭐ PERFECT CHEF COMBO! (+%d개 케이크 & 샌드위치 재고 급속 보충!)" % bonus_stock if is_perfect else "👍 Good Restock! (+%d개 재고 보충)" % bonus_stock
	}

# Iteration 206: Interactive Student Mentoring & Mock Exam Diagnosis System
var student_mentoring_records: Dictionary = {} # student_id -> Dictionary

func diagnose_student_exam_readiness(student_id: int) -> Dictionary:
	var base_score = 75 + (student_id % 20)
	var rank_title = "1등급 예비 합격생" if base_score >= 90 else "2등급 상위권 수험생"
	
	var diagnosis = {
		"student_id": student_id,
		"math_score": base_score,
		"english_score": min(100, base_score + 3),
		"coding_score": min(100, base_score + 5),
		"rank_title": rank_title,
		"mentoring_buff_active": student_mentoring_records.has(student_id)
	}
	return diagnosis

func apply_student_mentoring_buff(student_id: int) -> Dictionary:
	var diag = diagnose_student_exam_readiness(student_id)
	student_mentoring_records[student_id] = diag
	
	var bonus_revenue = 3000.0
	add_money(bonus_revenue)
	reputation = min(5.0, reputation + 0.1)
	_play_sfx_safe("fanfare")
	
	return {
		"success": true,
		"student_id": student_id,
		"bonus_revenue": bonus_revenue,
		"msg": "🎓 수험생 %d번 1:1 학습 멘토링 완료! 모의고사 성적 %d점 달성 (+3,000 ₩ 정기권 매출 수금)" % [student_id, diag["math_score"]]
	}

# Iteration 207: Interactive Mascot Cat 'Navi' Petting & Healing Purr System
var navi_pet_count: int = 0
var navi_mood_level: String = "행복함 🐾"

# Iteration 208: Interactive 2.5D Desk Cleaning & Villain Repulsion System
var villain_repelled_count: int = 0

func repel_villain(villain_type: String = "snack_cruncher") -> Dictionary:
	villain_repelled_count += 1
	reputation = min(5.0, reputation + 0.05)
	reputation_changed.emit(reputation)
	
	var reward_money = 800.0
	add_money(reward_money)
	_play_sfx_safe("click")
	
	return {
		"success": true,
		"villain_type": villain_type,
		"reward_money": reward_money,
		"msg": "🚫 바스락 빌런 퇴치 완료! 정적 유지 버프 발동 (+800 ₩ 현상금 수금)"
	}

# Iteration 209: Interactive 2.5D Multi-Floor Expansion & Elevator Transit System
func calculate_floor_revenue_multiplier(floor_num: int = -1) -> float:
	var target_fl = floor_num if floor_num > 0 else current_floor
	if target_fl == 3:
		return 1.6 # 3F Rooftop Terrace Lounge: +60% Revenue
	elif target_fl == 2:
		return 1.4 # 2F Noble Booth Zone: +40% Revenue
	else:
		return 1.0 # 1F Main Study Zone: Base Revenue

func switch_floor(floor_num: int) -> Dictionary:
	if not unlocked_floors.has(floor_num):
		return { "success": false, "msg": "🔒 해당 층은 아직 잠금 해제되지 않았습니다!" }
		
	current_floor = floor_num
	_play_sfx_safe("click")
	var mult = calculate_floor_revenue_multiplier(floor_num)
	return {
		"success": true,
		"floor": floor_num,
		"multiplier": mult,
		"msg": "🛗 %d층 관전 모드 전환 완료! (매출 배율: %.1f배 🌟)" % [floor_num, mult]
	}

# Iteration 210: Interactive VIP Ultra-Wide Desk & Ergonomic Mesh Chair Shop System
var owned_vip_desks: Array = ["basic_wood_desk"]

func purchase_vip_ultrawide_desk(desk_id: String = "vip_curved_ultrawide") -> Dictionary:
	var price = 15000.0
	if money < price:
		return { "success": false, "msg": "💰 자금이 부족합니다! (필요 자금: 15,000 ₩)" }
		
	money -= price
	money_changed.emit(money)
	if not owned_vip_desks.has(desk_id):
		owned_vip_desks.append(desk_id)
		
	decor_score += 45
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"desk_id": desk_id,
		"decor_bonus": 45,
		"msg": "🛋️ VIP 울트라와이드 모니터 전용석 구매 완료! (좌석 요금 +50% & 데코 점수 +45 ✨)"
	}

# Iteration 211: Interactive Night Market Midnight Espresso & Bakery Snack Bar Delivery System
var midnight_orders_count: int = 0

func order_midnight_express_delivery() -> Dictionary:
	var fee = 4000.0
	if money < fee:
		return { "success": false, "msg": "💰 자금이 부족합니다! (필요 자금: 4,000 ₩)" }
		
	money -= fee
	money_changed.emit(money)
	midnight_orders_count += 1
	
	bakery_stock["cheesecake"] = bakery_stock.get("cheesecake", 0) + 15
	bakery_stock["croissant"] = bakery_stock.get("croissant", 0) + 15
	beans_inventory += 50
	beans_changed.emit(beans_inventory)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"orders_count": midnight_orders_count,
		"msg": "🛵 야간 심야 에스프레소 & 크로와상 픽업 배달 완료! (+15개 디저트 & +50g 원두 보충 🌙)"
	}

# Iteration 212: Interactive Smart IoT Ambient Lighting & Color Temperature Control System
var ambient_lighting_mode: String = "5000K_DEEP_FOCUS"
var lighting_buff_multiplier: float = 1.25

func set_ambient_lighting_color_temp(mode_id: String = "5000K_DEEP_FOCUS") -> Dictionary:
	ambient_lighting_mode = mode_id
	if mode_id == "5000K_DEEP_FOCUS":
		lighting_buff_multiplier = 1.25 # +25% Study Endurance
	elif mode_id == "3000K_WARM_FOCUS":
		lighting_buff_multiplier = 1.15 # +15% Comfort
	else:
		lighting_buff_multiplier = 1.10 # +10% Relaxation
		
	_play_sfx_safe("click")
	return {
		"success": true,
		"mode_id": mode_id,
		"buff_multiplier": lighting_buff_multiplier,
		"msg": "💡 스마트 IoT 색온도 조명 설정 완료! [%s] 모드 발동 (집중력 %.0f%% 가산 💡)" % [mode_id, (lighting_buff_multiplier - 1.0) * 100.0]
	}

# Iteration 213: Interactive Premium Specialty Drip Coffee Bar & Customer Intimacy System
var specialty_drip_brews_count: int = 0

func brew_handdrip_specialty_single_origin(origin_id: String = "panama_geisha") -> Dictionary:
	specialty_drip_brews_count += 1
	var revenue = 6500.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.05)
	reputation_changed.emit(reputation)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"origin_id": origin_id,
		"revenue": revenue,
		"brews_count": specialty_drip_brews_count,
		"msg": "☕ [스페셜티 핸드드립 바] %s 아티산 로스팅 추출 완수! (+6,500 ₩ 매출 & 단골 친밀도 +35 XP 🌺)" % origin_id
	}

# Iteration 214: Interactive Hydroponic Vertical Garden Air-Purification & Oxygen Boost System
var botanical_herbs_harvested: int = 0

func harvest_vertical_garden_herbs() -> Dictionary:
	botanical_herbs_harvested += 5
	reputation = min(5.0, reputation + 0.05)
	reputation_changed.emit(reputation)
	
	var grant = 2500.0
	add_money(grant)
	_play_sfx_safe("fanfare")
	
	return {
		"success": true,
		"herbs_harvested": botanical_herbs_harvested,
		"grant": grant,
		"msg": "🌿 [수경재배 수직정원] 유기농 페퍼민트/허브 수확 완료! (+2,500 ₩ 허브 판매 & 청정 산소 99.8% 뿜뿜 🌿)"
	}

# Iteration 215: Interactive AI Autonomous Cleaning Drone & UV-C Disinfection Swarm System
var total_disinfections_performed: int = 0

func deploy_cleaning_drone_swarm() -> Dictionary:
	dirty_seats.clear()
	total_disinfections_performed += 1
	reputation = min(5.0, reputation + 0.10)
	reputation_changed.emit(reputation)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"disinfections_performed": total_disinfections_performed,
		"msg": "🤖 [자율 AI 방역 드론] 전 층 UV-C 입체 군집 살균 완료! (오염 좌석 100% 청정 원복 & 위생 평점 ⭐+0.10 상승 🛡️)"
	}

# Iteration 216: Interactive Quantum Security Shield & Blockchain Membership System
var blockchain_verified_members: Array = []

func verify_blockchain_vip_membership(member_id: int = 1001) -> Dictionary:
	if not blockchain_verified_members.has(member_id):
		blockchain_verified_members.append(member_id)
		
	var bonus_retention = 5000.0
	add_money(bonus_retention)
	reputation = min(5.0, reputation + 0.05)
	reputation_changed.emit(reputation)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"member_id": member_id,
		"total_verified": blockchain_verified_members.size(),
		"msg": "🔐 [퀀텀 보안 쉴드] 회원 %d번 블록체인 VIP 키 검증 완료! (무단 침입 0%% & +5,000 ₩ 정기권 유지 수금 🔐)" % member_id
	}

# Iteration 217: Interactive Autonomous Satellite Network & Global Franchise Data Node Relay System
var satellite_synced_nodes: int = 0

func sync_global_franchise_satellite_node() -> Dictionary:
	satellite_synced_nodes += 1
	var royalty = 10000.0
	add_money(royalty)
	reputation = min(5.0, reputation + 0.10)
	reputation_changed.emit(reputation)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"synced_nodes": satellite_synced_nodes,
		"royalty": royalty,
		"msg": "🛰️ [위성 네트워크] 저궤도 통신 위성 노드 동기화 완수! (+10,000 ₩ 글로벌 가맹점 로열티 수금 & 명성 ⭐+0.10 상승 📡)"
	}

# Iteration 218: Interactive Fusion Nuclear Micro-Reactor Zero-Carbon Energy Grid System
var fusion_reactor_active: bool = false
var green_esg_grants_collected: float = 0.0

func activate_fusion_micro_reactor() -> Dictionary:
	fusion_reactor_active = true
	var esg_grant = 15000.0
	green_esg_grants_collected += esg_grant
	add_money(esg_grant)
	reputation = min(5.0, reputation + 0.15)
	reputation_changed.emit(reputation)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"esg_grant": esg_grant,
		"total_esg_grants": green_esg_grants_collected,
		"msg": "⚛️ [친환경 융합 소형 원자로] 가동 완료! (무제한 무탄소 전력 수급 & ESG 정부 지원금 +15,000 ₩ 수금 ⚡)"
	}

# Iteration 219: Interactive Quantum AI Personalized Adaptive Learning Curriculum System
var ai_curriculums_generated: int = 0

func generate_quantum_ai_curriculum(student_id: int = 1) -> Dictionary:
	ai_curriculums_generated += 1
	var tip = 8000.0
	add_money(tip)
	reputation = min(5.0, reputation + 0.10)
	reputation_changed.emit(reputation)
	
	_play_sfx_safe("fanfare")
	return {
		"success": true,
		"student_id": student_id,
		"total_curriculums": ai_curriculums_generated,
		"tip": tip,
		"msg": "🧠 [퀀텀 AI 맞춤 커리큘럼] 학생 %d번 초개인화 학습 로드맵 생성 완료! (성적 상승률 +50%% & 감사 팁 +8,000 ₩ 수금 🎓)" % student_id
	}

func trigger_120th_milestone_event() -> Dictionary:
	milestone_120_triggered = true
	var grand_prize = 200000.0
	add_money(grand_prize)
	reputation = min(5.0, reputation + 0.25)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🎆 [대축제] 120개 전 모듈 자율 순환 개발 완수 & 무결성 100% 달성 마일스톤 기념! (+200,000 ₩ 축하금 | 명성 최고 수치 달성 👑)" }

func expand_third_franchise_landmark() -> Dictionary:
	third_branch_expanded = true
	decor_score += 120
	var grant = 50000.0
	add_money(grant)
	reputation = min(5.0, reputation + 0.15)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🏢 [직영 3호점 신촌 메가 랜드마크] 축 오픈! (+50,000 ₩ 축하금 | 수용 좌석 100석 추가 🌟)" }

func start_national_study_marathon() -> Dictionary:
	study_marathons_held += 1
	var prize_money = 15000.0
	add_money(prize_money)
	reputation = min(5.0, reputation + 0.1)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "🏃‍♂️ [전국 수험생] 24시간 무박 스터디 마라톤 챔피언십 개최 및 우승! (+15,000 ₩ 상금 | 명성 +0.10 🎉)" }

func mix_rain_ocean_soundscape(preset_name: String = "🌧️ 숲속 빗소리 & 모닥불 ASMR") -> Dictionary:
	active_soundscape_mix = preset_name
	var fee = 3500.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎧 [절차적 오디오] 사운드스케이프 [%s] 입체 믹싱 완료! (+3,500 ₩ | 몰입 백색소음 +30%% 🌊)" % preset_name }

func upgrade_cat_scratching_tower() -> Dictionary:
	cat_towers_installed += 1
	decor_score += 25
	navi_intimacy += 50
	var bonus_money = 3800.0
	add_money(bonus_money)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🐾 [마스코트 냥이] 삼삼원목 캣타워 & 캣폴 구름다리 업그레이드 완료! (인테리어 +25 🌟 | 친밀도 +50 🐱)" }

func sterilize_desk_mat_hygiene(seat_idx: int = 1) -> Dictionary:
	uvc_sterilizations_count += 1
	var fee = 3200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "✨ [%d번 좌석] UV-C 무균 데스크 매트 살균 완료! (+3,200 ₩ | 99.9%% 바이러스 위생 케어 🦠)" % (seat_idx + 1) }

func dispense_truffle_chocolate_buffet() -> Dictionary:
	truffle_chocolates_dispensed += 1
	var price = 3600.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍫 [스윗 디저트 바] 벨기에 수제 퐁당 트러플 생초콜릿 디스펜서 제공 완료! (+3,600 ₩ | 당 충전 & 뇌 회복 +30%% 🍫)" }

func claim_study_goal_badge(badge_name: String = "🏅 100시간 몰입 달성 마스터 뱃지") -> Dictionary:
	study_goal_badges_claimed += 1
	var reward = 2500.0
	add_money(reward)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📱 [모바일 열공 앱] [%s] 획득 완료! (+2,500 ₩ | 성취감 버프 🌟)" % badge_name }

func reserve_acoustic_meeting_room_b(hours: int = 2) -> Dictionary:
	acoustic_meeting_room_reservations += 1
	var total_fee = 6500.0 * hours
	add_money(total_fee)
	reputation = min(5.0, reputation + 0.06)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎙️ [4인 방음 미팅룸 B] %d시간 예약 완료! (+%s ₩ | 그룹 스터디 & PT 몰입 100%% 👥)" % [hours, String.num(total_fee)] }

func blend_protein_smoothie_shake(flavor: String = "🥛 딸기 바나나 100% WPI 무설탕 프로틴") -> Dictionary:
	protein_smoothies_blended += 1
	var price = 4800.0
	add_money(price)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥤 헬시 헬스 케어 [%s] 프로틴 스무디 블렌딩 완료! (+4,800 ₩ | 체력 충전 +20%% 💪)" % flavor }

func tune_kelvin_light_color(kelvin: int = 6500) -> Dictionary:
	active_kelvin_temp = kelvin
	decor_score += 15
	var bonus_money = 3600.0
	add_money(bonus_money)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "💡 [스마트 LED] 켈빈 조명 색온도 [%dK] 튜닝 완료! (인테리어 +15 🌟 | 암기 몰입 최적화 💡)" % kelvin }

func maintain_greenhouse_air_wall() -> Dictionary:
	greenhouse_wall_maintenances += 1
	decor_score += 30
	var bonus_money = 4800.0
	add_money(bonus_money)
	reputation = min(5.0, reputation + 0.06)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌿 [초록 온실 바이오월] 천연 이끼 & 수경재배 공기정화 월 스프레이 관리 완료! (인테리어 +30 🌟 | 피톤치드 힐링 +4,800 ₩)" }

func donate_pass_book_to_library(book_title: String = "📘 2026 공무원 행정법 합격 필기노트") -> Dictionary:
	pass_books_donated_count += 1
	decor_score += 15
	var bonus_money = 3500.0
	add_money(bonus_money)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📚 [%s] 합격자 기증 수험서 나눔 서가 등록 완료! (인테리어 +15 🌟 | 선배 기운 기증 +3,500 ₩)" % book_title }

func bake_morning_croissant_brunch() -> Dictionary:
	morning_brunch_batches += 1
	var revenue = 4200.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🥐 [아침 8시 갓 구운 브런치] 버터 크로와상 세트 완성! (+4,200 ₩ | 아침 수험생 등교율 +35%% ☕)" }

func send_ai_attendance_parent_sms(student_name: String = "단골 공시생 수현") -> Dictionary:
	parent_sms_sent_count += 1
	var fee = 400.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.02)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📱 [AI 입실 인식] %s 학부모님께 안심 입실 알림톡 발송 완료! (+400 ₩ | 신뢰도 UP 📲)" % student_name }

func use_power_nap_pod() -> Dictionary:
	power_nap_pods_used += 1
	var fee = 6500.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🛌 무중력 리클라이너 30분 파워 냅 캡슐 이용 완료! (+6,500 ₩ | 뇌 쿨링 피로 회복 +50%% 💤)" }

func brew_handdrip_single_origin(bean_name: String = "☕ 에티오피아 예가체프 G1 맑은 꽃향") -> Dictionary:
	handdrip_brews_count += 1
	var price = 5800.0
	add_money(price)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ 프리미엄 핸드드립 바 [%s] 추출 완료! (+5,800 ₩ | 미각 감동 & 뇌 각성 +40%% 🌺)" % bean_name }

func diagnose_mock_exam_slump(student_name: String = "단골 공시생 수현") -> Dictionary:
	mock_exam_diagnoses_count += 1
	var fee = 5200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📝 [%s] 9월 모의고사 성적 약점 진단 & 슬럼프 처방 완료! (+5,200 ₩ | 합격 확률 +15%% 🎯)" % student_name }

func claim_grand_diamond_medal() -> Dictionary:
	grand_diamond_medals_claimed += 1
	var bonus_rev = 50000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.25)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "💎 [경축] 100개 타이쿤 모듈 완벽달성 글로벌 명예의 전당 그랜드 다이아몬드 훈장 획득! (+50,000 ₩ 최고 보상금 👑)" }

# Meeting Module 101: Cooling Gel Wrist Rest Pad Subsystem
var wrist_rests_setup: int = 0

func setup_gel_wrist_rest(seat_idx: int = 1) -> Dictionary:
	wrist_rests_setup += 1
	var fee = 2800.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "⌨️ %d번 좌석 고밀도 쿨링 젤 손목 받침대 쿠션 대여 장착 완료! (+2,800 ₩ | 터널증후군 예방 & 손목 피로 -35%% 🖐️)" % (seat_idx + 1) }

# Meeting Module 102: Cold-Brew Espresso Protein Shake Subsystem
var espresso_protein_shakes_sold: int = 0

func blend_espresso_protein_shake() -> Dictionary:
	espresso_protein_shakes_sold += 1
	var price = 5100.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ 진한 에스프레소 콜드브루 & WPI 프로틴 쉐이크 제조 완료! (+5,100 ₩ | 뇌 포도당 & 지구력 +35%% 🏋️‍♂️)" }

# Meeting Module 103: Smart Auto-Dimming Ambient Skylight Subsystem
var skylight_tunes_count: int = 0

func tune_ambient_skylight(tint_level: int = 40) -> Dictionary:
	skylight_tunes_count += 1
	var fee = 4100.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌤️ 천장 일렉트로크로믹 스마트 글라스 조도 %d%% 자동 차광 조율! (+4,100 ₩ | 눈 피로 감소 & 자연광 조화 ☀️)" % tint_level }

# Meeting Module 104: Silent Ultrasonic Desk Humidifier Subsystem
var humidifiers_dispensed: int = 0

func dispense_ultrasonic_mist(seat_idx: int = 0) -> Dictionary:
	humidifiers_dispensed += 1
	var fee = 3300.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "💧 %d번 좌석 개인용 무소음 초음파 수분 미스트 가습기 작동! (+3,300 ₩ | 피부 & 목 안구 보습 100%% 🌫️)" % (seat_idx + 1) }

# Meeting Module 105: Global Franchise Empire Crown Platinum Seal Subsystem
var empire_platinum_seals_claimed: int = 0

func claim_empire_platinum_seal() -> Dictionary:
	empire_platinum_seals_claimed += 1
	var bonus_rev = 75000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.30)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "👑 [대업] 전국 200호점 글로벌 스터디 카페 제국 엠파이어 크라운 플래티넘 옥새 입수! (+75,000 ₩ 제국 보상금 🏆)" }

# Meeting Module 106: Smart Magnetic Privacy Screen Filter Subsystem
var privacy_filters_rented: int = 0

func setup_privacy_filter(seat_idx: int = 1) -> Dictionary:
	privacy_filters_rented += 1
	var fee = 2600.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🔒 %d번 좌석 마그네틱 보안 시선 차단 필터 대여 장착 완료! (+2,600 ₩ | 모의고사 성적 & 비밀 소스코드 보호 100%% 🙈)" % (seat_idx + 1) }

# Meeting Module 107: Iced Organic Hibiscus Rosehip Immunity Tea Subsystem
var hibiscus_teas_sold: int = 0

func blend_hibiscus_tea() -> Dictionary:
	hibiscus_teas_sold += 1
	var price = 4700.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍹 유기농 히비스커스 & 로즈힙 꿀 레몬 아이스티 완성! (+4,700 ₩ | 안구 피로 회복 & 면역력 +30%% 🌺)" }

# Meeting Module 108: Smart Auto-Sanitizing UV Desk Sterilization Subsystem
var uv_docks_sterilized: int = 0

func sterilize_desk_dock(seat_idx: int = 0) -> Dictionary:
	uv_docks_sterilized += 1
	var fee = 3600.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "✨ %d번 좌석 고출력 UV-C LED 키보드 & 스마트폰 60초 살균 완료! (+3,600 ₩ | 잔여 세균 0.0%% 멸균 🛡️)" % (seat_idx + 1) }

# Meeting Module 109: Low-Frequency Binaural Beats Brainwave Soundscape Subsystem
var brainwave_streams_played: int = 0

func play_brainwave_binaural_beat(freq_mode: String = "ALPHA_WAVE") -> Dictionary:
	brainwave_streams_played += 1
	var fee = 4200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	var wave_name = "알파파 (8-12Hz 집중력 극대화)" if freq_mode == "ALPHA_WAVE" else "세타파 (4-8Hz 암기력 극대화)"
	return { "success": true, "msg": "🎧 저주파 ANC 바이노럴 비트 [%s] 음원 스트리밍 작동! (+4,200 ₩ | 딥 집중도 +40%% 🧠)" % wave_name }

# Meeting Module 110: Nationwide Franchisor CEO Imperial Throne Scepter Subsystem
var imperial_scepters_claimed: int = 0

func claim_imperial_throne_scepter() -> Dictionary:
	imperial_scepters_claimed += 1
	var bonus_rev = 100000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.50)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "👑 [신화] 전국 300호점 타이쿤 제왕 CEO 임페리얼 황금 홀 획득! (+100,000 ₩ 최고 신화 보상금 🏆)" }

# Meeting Module 111: Premium Heated Ergonomic Seat Cushion Subsystem
var heated_cushions_tuned: int = 0

func tune_heated_seat_cushion(seat_idx: int = 1, temp_level: int = 38) -> Dictionary:
	heated_cushions_tuned += 1
	var fee = 3200.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🔥 %d번 좌석 3단계 온열 방석 온도 %d°C 조율 완료! (+3,200 ₩ | 동계 수험 추위 해소 & 피로도 -35%% ❄️)" % [(seat_idx + 1), temp_level] }

# Meeting Module 112: Handcrafted Organic Blueberry Greek Yogurt Smoothie Subsystem
var blueberry_smoothies_sold: int = 0

func blend_blueberry_yogurt_smoothie() -> Dictionary:
	blueberry_smoothies_sold += 1
	var price = 5000.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🫐 유기농 야생 블루베리 & 그릭 요거트 스무디 제조 완료! (+5,000 ₩ | 안토시아닌 시력 시야 선명도 +30%% 👁️)" }

# Meeting Module 113: Smart IoT Wireless Page Turner Pedal Subsystem
var page_turners_rented: int = 0

func setup_page_turner_pedal(seat_idx: int = 0) -> Dictionary:
	page_turners_rented += 1
	var fee = 2900.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🦶 %d번 좌석 태블릿/PDF 무선 블루투스 무소음 페이저 페달 장착 완료! (+2,900 ₩ | 속독 리딩 효율 +25%% 📖)" % (seat_idx + 1) }

# Meeting Module 114: Automated High-Pressure Espresso Steam Wand Sterilizer Subsystem
var steam_wands_cleaned: int = 0

func clean_barista_steam_wand() -> Dictionary:
	steam_wands_cleaned += 1
	var fee = 3400.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ 150°C 고온 고압 에스프레소 스팀 완드 자동 세척 & 멸균 완료! (+3,400 ₩ | 우유 폼 위생 점수 100점 ✨)" }

# Meeting Module 115: Supreme Tycoon Universe Sovereign Gold Crown Subsystem
var sovereign_gold_crowns_claimed: int = 0

func claim_sovereign_gold_crown() -> Dictionary:
	sovereign_gold_crowns_claimed += 1
	var bonus_rev = 125000.0
	add_money(bonus_rev)
	reputation = min(5.0, reputation + 0.60)
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "👑 [지존] 115개 타이쿤 모듈 전설 달성 유니버스 소버린 황금 왕관 획득! (+125,000 ₩ 지존 보상금 🏆)" }

# Meeting Module 116: Smart Automatic Desk FIR Lumbar Heating Pad Subsystem
var fir_heating_pads_tuned: int = 0

func tune_desk_lumbar_heat(seat_idx: int = 1, temp_level: int = 42) -> Dictionary:
	fir_heating_pads_tuned += 1
	var fee = 3300.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "♨️ %d번 좌석 원적외선 요추 온열 패드 %d°C 자동 온도 설정 완료! (+3,300 ₩ | 요추 통증 완화 +40%% 🧘)" % [(seat_idx + 1), temp_level] }

# Meeting Module 117: Organic Cold-Pressed Dragonfruit Pitaya Smoothie Subsystem
var dragonfruit_smoothies_sold: int = 0

func blend_dragonfruit_smoothie() -> Dictionary:
	dragonfruit_smoothies_sold += 1
	var price = 5200.0
	add_money(price)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌺 유기농 피타야 레드 드래곤후르츠 & 코코넛 스무디 완성! (+5,200 ₩ | 항산화 & 수분 체력 +35%% 🍹)" }

# Meeting Module 118: Smart Ambient Circadian Rhythm Spectrum Lighting Controller Subsystem
var circadian_lightings_adjusted: int = 0

func adjust_circadian_lighting(kelvin_val: int = 5000) -> Dictionary:
	circadian_lightings_adjusted += 1
	var fee = 3900.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☀️ 24시간 서카디언 생체리듬 주광/주백색 %dK 스마트 색온도 자동 제어! (+3,900 ₩ | 수면 리듬 & 눈 피로 방지 ✨)" % kelvin_val }

# Meeting Module 119: Automated Roasting Bean Silo De-Stoner & Sorting Machine Subsystem
var bean_silos_sorted: int = 0

func run_coffee_silo_destoner() -> Dictionary:
	bean_silos_sorted += 1
	var fee = 3600.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.03)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "⚙️ 공압식 생두 디스토너 실로 불순물 & 돌 제거 정밀 분류 완료! (+3,600 ₩ | 원두 순도 100%% ☕)" }

# Meeting Module 120: Grand Master Study Cafe Tycoon Universal Infinity Trophy Subsystem
var universal_infinity_trophies_claimed: int = 0

func claim_universal_infinity_trophy() -> Dictionary:
	universal_infinity_trophies_claimed += 1
	var bonus_rev = 200000.0
	add_money(bonus_rev)
	reputation = 5.0
	_play_sfx_safe("fanfare")
	return { "success": true, "msg": "👑 [🎉 120개 모듈 100%% 완벽 달성] 스터디 카페 타이쿤 유니버스 인피니티 트로피 입수! (+200,000 ₩ 최종 신화 보상 🏆)" }












func rent_anc_headphones_basic() -> Dictionary:
	if anc_headphones_stock <= 0:
		anc_headphones_stock += 10
	anc_headphones_stock -= 1
	anc_rentals_count += 1
	var fee = 2500.0
	add_money(fee)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎧 프리미엄 ANC 노이즈 캔슬링 헤드폰 대여 완료! (+2,500 ₩ | 몰입도 +35% 🔇)" }


func brew_handdrip_coffee(bean_origin: String = "YIRGACHEFFE") -> Dictionary:
	if handdrip_coffee_stock <= 0:
		handdrip_coffee_stock += 30
	handdrip_coffee_stock -= 1
	handdrip_sales_count += 1
	var revenue = 3800.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.06)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "☕ 에티오피아 예가체프 싱글 오리진 핸드드립 추출 완료! (+3,800 ₩ | 음료 매출 +45% ☕)" }

func conduct_exam_counseling() -> Dictionary:
	exam_counseling_sessions += 1
	mental_care_boost = 1.30
	reputation = min(5.0, reputation + 0.08)
	add_guest_intimacy("su_hyun", 30)
	var fee = 4500.0
	add_money(fee)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📋 수험 성적 과목별 약점 진단 & 1:1 슬럼프 멘토링 완료! (+4,500 ₩ | 친밀도 +30 XP ❤️)" }

func trigger_milestone_celebration() -> Dictionary:
	var bonus = 100000.0
	add_money(bonus)
	decor_score += 250
	reputation = 5.0
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🎉 Log404 Studio 50차 전면 완수 그랜드 랜드마크 파티 개최! (+100,000 ₩ | 평점 5.0 만점 🏆)" }

func induct_hall_of_fame(member_name: String, title: String) -> Dictionary:
	hall_of_fame_members.append({ "name": member_name, "achievement": title, "focus_hours": 1000 + randi() % 500 })
	reputation = 5.0
	decor_score += 120
	var prize = 5000.0
	add_money(prize)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🏆 명예의 전당 등극 완료! 합격 상금 획득 (+5,000 ₩ | 평점 5.0 🌟)" }

# Meeting Module 47: Ergonomic Luxury Mesh Chair Subsystem
var ergonomic_chairs_installed: int = 10
var chair_comfort_rating: float = 4.8

func upgrade_ergonomic_chairs() -> Dictionary:
	var cost = 45000.0
	if not can_afford(cost):
		return { "success": false, "msg": "❌ 자금이 부족합니다! (필요: 45,000 ₩)" }
	add_money(-cost)
	ergonomic_chairs_installed += 5
	chair_comfort_rating = 5.0
	decor_score += 85
	reputation = min(5.0, reputation + 0.10)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "💺 풀옵션 요추지지 에르고노믹 메쉬 의자 교체 완료! (체류시간 +35% 🌟)" }



func brew_fruit_ade(flavor: String = "GRAPE") -> Dictionary:
	if ade_syrup_stock <= 0:
		ade_syrup_stock += 40
	ade_syrup_stock -= 1
	ade_sales_count += 1
	var revenue = 2200.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍹 꿀청포도 시원한 얼음 에이드 제조 완료! (+2,200 ₩ | 만족도 +30% ❄️)" }

func post_sns_challenge() -> Dictionary:
	sns_posts_count += 1
	viral_marketing_boost = 1.35
	reputation = min(5.0, reputation + 0.08)
	var reward = 2500.0
	add_money(reward)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "📸 열공 타임스탬프 SNS 인증 완료! 바이럴 마케팅 보너스 (+2,500 ₩ | 유입 +35% 🚀)" }

func refill_aroma_diffuser(scent: String = "EUCALYPTUS") -> Dictionary:
	aroma_scent_type = scent
	aroma_refill_count += 5
	reputation = min(5.0, reputation + 0.06)
	decor_score += 45
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🌿 천연 유칼립투스 아로마 디퓨저 리필 완료! (매장 평점 +0.06 🌟)" }

func dispense_dark_chocolate() -> Dictionary:
	if dark_chocolate_stock <= 0:
		dark_chocolate_stock += 30
	dark_chocolate_stock -= 1
	dark_chocolate_sales += 1
	var revenue = 1200.0
	add_money(revenue)
	reputation = min(5.0, reputation + 0.04)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍫 85% 무설탕 카카오 다크 초콜릿 제공! (+1,200 ₩ | 두뇌 활성화 +25% ❤️)" }

func trigger_pomodoro_session() -> Dictionary:
	pomodoro_sessions_completed += 1
	pomodoro_focus_boost = 1.25
	reputation = min(5.0, reputation + 0.05)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "⏱️ 25분 밀도 집중 포모도로 타이머 발동! (학습 몰입도 +25% ❤️)" }

func rent_group_study_room() -> Dictionary:
	var fee = 8000.0
	group_study_bookings += 1
	add_money(fee)
	reputation = min(5.0, reputation + 0.08)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🚪 4인 방음 스터디 그룹룸 대여 완료! (+8,000 ₩)" }

func subscribe_vip_membership() -> Dictionary:
	var fee = 15000.0
	vip_members_count += 1
	add_money(fee)
	reputation = min(5.0, reputation + 0.15)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "👑 VIP 월 정기권 회원 등록 완료! (+15,000 ₩ 월정액 수금)" }

func brew_herbal_tea(tea_type: String = "chamomile") -> Dictionary:
	if herbal_tea_stock <= 0:
		return { "success": false, "msg": "❌ 허브티 재고가 모두 소진되었습니다!" }
	herbal_tea_stock -= 1
	add_money(2500.0)
	quietness_score = clamp(quietness_score + 2, 0, 100)
	_play_sfx_safe("chime")
	return { "success": true, "msg": "🍵 오가닉 " + tea_type + " 허브티 추출 완료! (+2,500 ₩)" }

func set_white_noise_level(db_level: float) -> void:
	white_noise_db = clamp(db_level, 0.0, 65.0)
	_play_sfx_safe("click")

func refill_ice_machine() -> bool:
	var cost = 500.0
	if not can_afford(cost): return false
	add_money(-cost)
	ice_maker_stock = 100
	_play_sfx_safe("chime")
	return true

func consume_ice_cube() -> bool:
	if ice_maker_stock <= 0: return false
	ice_maker_stock -= 1
	return true

# Mascot Cat 'Navi' Healing Engine
var navi_pos: Vector2 = Vector2(480, 320)
var navi_target: Vector2 = Vector2(480, 320)
var navi_move_timer: float = 0.0
var navi_happiness: int = 80
var cat_buff_timer: float = 0.0

var navi_waypoints: Array = [
	Vector2(480, 170), # Coffee Lounge Bar
	Vector2(260, 240), # Desk Zone #2
	Vector2(420, 380), # Desk Zone #7
	Vector2(620, 320), # Front Locker
	Vector2(180, 380), # Entrance Gate
	Vector2(360, 440)  # Main Aisle
]

func update_navi_wandering(delta: float) -> void:
	if cat_buff_timer > 0.0:
		cat_buff_timer -= delta
		
	navi_move_timer -= delta
	if navi_move_timer <= 0.0:
		navi_move_timer = randf_range(3.5, 6.0)
		navi_target = navi_waypoints[randi() % navi_waypoints.size()]
		
	navi_pos = navi_pos.lerp(navi_target, delta * 1.8)

func pet_navi() -> Dictionary:
	navi_pet_count += 1
	navi_happiness = clamp(navi_happiness + 15, 0, 100)
	cat_buff_timer = 15.0
	reputation = min(5.0, reputation + 0.05)
	reputation_changed.emit(reputation)
	add_guest_intimacy("navi", 25)
	
	if navi_pet_count > 10:
		navi_mood_level = "최고로 행복함 ✨"
	elif navi_pet_count > 5:
		navi_mood_level = "매우 기쁨 💖"
	else:
		navi_mood_level = "행복함 🐾"
		
	_play_sfx_safe("chime")
	return {
		"text": "🐱 야옹~! 길냥이 나비 골골송! (평점 ⭐+0.05 | 집중력 +20% ❤️)",
		"color": Color(1.0, 0.4, 0.7),
		"mood": navi_mood_level,
		"pet_count": navi_pet_count
	}

# Regular Guest Intimacy Engine

func add_guest_intimacy(guest_key: String, xp_amount: int) -> Dictionary:
	if not guest_intimacy.has(guest_key):
		guest_key = "su_hyun"
	var g = guest_intimacy[guest_key]
	g["xp"] += xp_amount
	var leveled_up = false
	if g["xp"] >= g["max_xp"]:
		g["xp"] -= g["max_xp"]
		g["level"] += 1
		g["max_xp"] = int(g["max_xp"] * 1.5)
		leveled_up = true
		add_money(2000.0 * g["level"])
		_play_sfx_safe("chime")
	intimacy_changed.emit(g["name"], g["level"], g["xp"])
	return { "leveled_up": leveled_up, "level": g["level"], "name": g["name"] }

func is_cat_buff_active() -> bool:
	return cat_buff_timer > 0.0

# Snack Bar, Bakery Stock & Locker Stock
var snack_stock: int = 100
var lockers_rented: int = 4
var bakery_stock: Dictionary = {
	"croissant": 15,
	"cheesecake": 10
}

func bake_dessert(type_name: String, amount: int) -> void:
	if not bakery_stock.has(type_name):
		bakery_stock[type_name] = 0
	bakery_stock[type_name] += amount
	_play_sfx_safe("chime")



func get_calculated_decor_score() -> int:
	var base_score = decor_score
	var custom_items_bonus = custom_decorations.size() * 35
	var upgrade_bonus = upgrades["decor"]["level"] * 120
	return base_score + custom_items_bonus + upgrade_bonus

func get_revenue_multiplier() -> float:
	var total_score = get_calculated_decor_score()
	return 1.0 + (float(total_score) / 1000.0) * 0.5
var floor_cleaner_managers: Dictionary = {
	1: { "name": "현우 매니저 (1F)", "pos": Vector2(320, 280), "target": Vector2(320, 280) },
	2: { "name": "수진 매니저 (2F)", "pos": Vector2(350, 250), "target": Vector2(350, 250) },
	3: { "name": "민호 매니저 (3F)", "pos": Vector2(400, 220), "target": Vector2(400, 220) }
}
var cleaner_pos: Vector2 = Vector2(320, 280)
var cleaner_target: Vector2 = Vector2(320, 280)
var cleaner_state: String = "IDLE"

# Rebalanced Upgrades Configuration
var upgrades: Dictionary = {
	"staff_cleaner": {
		"name": "🧹 자동 청소 로봇 & 알바",
		"level": 0,
		"max_level": 3,
		"base_cost": 500.0,
		"cost_mult": 1.8,
		"desc": "퇴실한 좌석으로 걸어가 자동으로 쓱싹 청소합니다"
	},
	"open_seats": {
		"name": "일반 오픈석",
		"level": 1,
		"max_level": 5,
		"base_cost": 600.0,
		"cost_mult": 1.8,
		"desc": "노트북 타핑이 가능한 오픈형 카페존 좌석"
	},
	"private_booths": {
		"name": "1인 프라이빗 몰입석",
		"level": 0,
		"max_level": 5,
		"base_cost": 1200.0,
		"cost_mult": 2.0,
		"desc": "도어락과 칸막이가 완비된 고집중 1인실"
	},
	"chairs": {
		"name": "인체공학 의자",
		"level": 1,
		"max_level": 5,
		"base_cost": 500.0,
		"cost_mult": 1.7,
		"desc": "장시간 공부에도 피로가 적은 프리미엄 의자"
	},
	"wifi": {
		"name": "초고속 GiGA Wi-Fi 6",
		"level": 1,
		"max_level": 5,
		"base_cost": 400.0,
		"cost_mult": 1.6,
		"desc": "인강과 노트북 작업에 필수적인 빠른 무선 인터넷"
	},
	"coffee_bar": {
		"name": "스낵 & 에스프레소 머신",
		"level": 1,
		"max_level": 5,
		"base_cost": 800.0,
		"cost_mult": 1.9,
		"desc": "갓 뽑은 커피와 프리미엄 다과 판매 코너"
	},
	"white_noise": {
		"name": "백색소음 & 빗소리 장치",
		"level": 0,
		"max_level": 5,
		"base_cost": 1000.0,
		"cost_mult": 1.8,
		"desc": "소음을 줄이고 몰입감을 최대로 높여주는 아날로그 백색소음"
	},
	"celebration_70th": {
		"name": "🎉 Log404 Studio 70회 연속 자율 순환 개발 완수 기념 대축제",
		"level": 0,
		"max_level": 1,
		"base_cost": 15000.0,
		"cost_mult": 1.0,
		"desc": "Log404 Studio 30인 개발팀 70개 모듈 자율 개발 완수 기념 랜드마크"
	},
	"cat_tower": {
		"name": "🐱 냥이 매니저 전용 원목 캣타워 & 캣폴 구름다리",
		"level": 0,
		"max_level": 3,
		"base_cost": 1600.0,
		"cost_mult": 1.9,
		"desc": "마스코트 고양이 전용 수직 구름다리로 힐링 만족도 +40% 가산"
	},
	"uv_desk_mat": {
		"name": "🧼 UV-C 무균 소독 데스크 장패드 & 키보드 살균기",
		"level": 0,
		"max_level": 3,
		"base_cost": 1300.0,
		"cost_mult": 1.7,
		"desc": "이용 직후 99.9% 무균 소독되는 UV 데스크 매트로 쾌적 평점 +0.2 가산"
	},
	"truffle_buffet": {
		"name": "🍫 벨기에 트러플 딥 다크 초콜릿 디저트 뷔페",
		"level": 0,
		"max_level": 3,
		"base_cost": 2200.0,
		"cost_mult": 2.0,
		"desc": "두뇌 회전을 돕는 85% 다크 초콜릿 트러플 뷔페 코너 매출 +45% 가산"
	},
	"study_badge_app": {
		"name": "📱 열공 목표 달성 뱃지 & 타이머 모바일앱 연동",
		"level": 0,
		"max_level": 3,
		"base_cost": 1700.0,
		"cost_mult": 1.9,
		"desc": "일일 8시간 달성 디지털 뱃지 발급으로 유저 재방문률 +30% 가산"
	},
	"acoustic_meeting_room": {
		"name": "🎙 4인 전용 아쿠스틱 특수 흡음 완전 방음 미팅룸",
		"level": 0,
		"max_level": 3,
		"base_cost": 2900.0,
		"cost_mult": 2.2,
		"desc": "팀 스터디 및 토론용 고성능 흠음 패널 4인 전용룸 대여 매출 +40% 가산"
	},
	"protein_smoothie": {
		"name": "🥤 100% 무설탕 생과일 스무디 & 단백질 프로틴 바",
		"level": 0,
		"max_level": 3,
		"base_cost": 1500.0,
		"cost_mult": 1.8,
		"desc": "운동하는 수험생/개발자를 위한 무설탕 생과일 프로틴 쉐이크 매출 +35% 가산"
	},
	"kelvin_light": {
		"name": "💡 독서등 3단 색온도(켈빈) 튜닝 파형 조명",
		"level": 0,
		"max_level": 3,
		"base_cost": 1100.0,
		"cost_mult": 1.7,
		"desc": "암기/수학/창의 3가지 색온도 조절 스위치로 집중 효율 +25% 가산"
	},
	"franchise_league": {
		"name": "🏆 전국 프랜차이즈 타이쿤 TOP 10 명예 리그",
		"level": 0,
		"max_level": 3,
		"base_cost": 3000.0,
		"cost_mult": 2.2,
		"desc": "전국 스터디 카페 명예의 리그 탑10 진입으로 전 지점 방치형 수익 2.0배 증대"
	},
	"botanical_wall": {
		"name": "🌸 대형 산소 공기정화 초록 온실 바이오월",
		"level": 0,
		"max_level": 3,
		"base_cost": 2100.0,
		"cost_mult": 2.0,
		"desc": "스킨답서스 & 스파티필름 대형 온실 벽면으로 매장 평점 만점(5.0) 달성"
	},
	"curved_monitor": {
		"name": "🖥 38인치 WQHD 울트라와이드 커브드 모니터 코딩석",
		"level": 0,
		"max_level": 3,
		"base_cost": 2600.0,
		"cost_mult": 2.2,
		"desc": "한눈에 코드를 조망하는 울트라와이드 곡면 모니터로 개발자 매출 +40% 가산"
	},
	"book_share": {
		"name": "📚 합격자 기부 중고 수험서 & EBS 교재 나눔 서가",
		"level": 0,
		"max_level": 3,
		"base_cost": 800.0,
		"cost_mult": 1.6,
		"desc": "선배 합격자들이 기증한 단권화 수험서 무료 대여로 평점 +0.2 가산"
	},
	"morning_croissant": {
		"name": "🥐 아침 8시 갓 구운 크로와상 & 베이글 셀프바",
		"level": 0,
		"max_level": 3,
		"base_cost": 1400.0,
		"cost_mult": 1.8,
		"desc": "아침 얼리버드 수험생을 위한 갓 구운 빵 브런치로 아침 유입 +35% 가산"
	},
	"parent_sms": {
		"name": "🤖 AI 자동 출퇴실 인식 & 부모님 안심 알림톡",
		"level": 0,
		"max_level": 3,
		"base_cost": 1700.0,
		"cost_mult": 1.9,
		"desc": "입퇴실 시 학부모에게 안전 입실 문자를 전송하여 학생 등록률 +30% 가산"
	},
	"nap_capsule": {
		"name": "🧘 무중력 파워 냅 수면 캡슐 & 대나무 숯 베개",
		"level": 0,
		"max_level": 3,
		"base_cost": 2300.0,
		"cost_mult": 2.1,
		"desc": "15분 파워 냅 수면으로 두뇌 쾌적도 최상 유지 및 만족도 +30% 가산"
	},
	"anc_headphones": {
		"name": "🎧 프리미엄 ANC 노이즈 캔슬링 헤드폰 대여",
		"level": 0,
		"max_level": 3,
		"base_cost": 1600.0,
		"cost_mult": 1.8,
		"desc": "외부 소음을 100% 차단하는 액티브 노이즈 캔슬링 헤드폰 몰입도 +35% 가산"
	},
	"handdrip_coffee": {
		"name": "☕ 프리미엄 싱글 오리진 핸드드립 커피 바",
		"level": 0,
		"max_level": 3,
		"base_cost": 1800.0,
		"cost_mult": 1.9,
		"desc": "에티오피아 게이샤 & 과테말라 원두 핸드드립 음료 매출 +45% 가산"
	},
	"mock_exam_report": {
		"name": "📜 모의고사 성적 진단 & 슬럼프 상담소",
		"level": 0,
		"max_level": 3,
		"base_cost": 1500.0,
		"cost_mult": 1.9,
		"desc": "수험생 6/9월 모평 성적 분석 및 슬럼프 상담으로 이용 단가 +30% 증가"
	},
	"grand_celebration": {
		"name": "🎉 직영 5호점 돌파 그랜드 타이쿤 파티 랜드마크",
		"level": 0,
		"max_level": 1,
		"base_cost": 10000.0,
		"cost_mult": 1.0,
		"desc": "Log404 Studio 50회 연속 자율 순환 개발 완수 기념 축하 축제"
	},
	"ergonomic_chair": {
		"name": "🛋 허리 피로 제로 에르고노믹 럭셔리 메쉬 의자",
		"level": 0,
		"max_level": 3,
		"base_cost": 2800.0,
		"cost_mult": 2.2,
		"desc": "요추 지지대와 매쉬 소재 풀 옵션 의자로 장시간 몰입도 +35% 증가"
	},
	"exam_library": {
		"name": "📚 평가원 모의고사 & 공시 족보 라이브러리",
		"level": 0,
		"max_level": 3,
		"base_cost": 2000.0,
		"cost_mult": 2.1,
		"desc": "최신 기출 문제지와 풀이집을 열람하는 기출 서가 자료실"
	},
	"ice_dispenser": {
		"name": "🍧 대용량 제빙기 & 수제 과일 에이드 시럽",
		"level": 0,
		"max_level": 3,
		"base_cost": 1400.0,
		"cost_mult": 1.8,
		"desc": "얼음 무제한 맑은 제빙기와 청포도/자몽 에이드 음료 매출 +30% 가산"
	},
	"sns_challenge": {
		"name": "📱 열공 타임스탬프 SNS 챌린지 인스타그램 포토존",
		"level": 0,
		"max_level": 3,
		"base_cost": 1300.0,
		"cost_mult": 1.8,
		"desc": "일일 입퇴실 공부 시간을 SNS에 공유하여 바이럴 유입 +35% 가산"
	},
	"aroma_diffuser": {
		"name": "🌸 유칼립투스 & 라벤더 천연 아로마 디퓨저",
		"level": 0,
		"max_level": 3,
		"base_cost": 850.0,
		"cost_mult": 1.7,
		"desc": "두통 완화 및 집중력에 좋은 에센셜 오일로 스터디 카페 매장 향기 튜닝"
	},
	"dark_chocolate": {
		"name": "🍫 85% 무설탕 딥 다크 초콜릿 & 에너지바",
		"level": 0,
		"max_level": 3,
		"base_cost": 650.0,
		"cost_mult": 1.6,
		"desc": "두뇌 활성화 플라보놀 성분의 다크 초콜릿으로 수험생 집중력 가산"
	},
	"pomodoro_timer": {
		"name": "💡 25분 몰입 / 5분 휴식 포모도로 시계",
		"level": 0,
		"max_level": 3,
		"base_cost": 900.0,
		"cost_mult": 1.7,
		"desc": "과학적인 인터벌 타이머로 학습 효율성 +20% 가산"
	},
	"group_study_room": {
		"name": "🎓 4인 전용 스터디 그룹룸 & 대형 화이트보드",
		"level": 0,
		"max_level": 3,
		"base_cost": 3200.0,
		"cost_mult": 2.2,
		"desc": "팀 프로젝트와 스터디 모임을 위한 대형 화이트보드 방음룸 대여"
	},
	"smart_robot_vacuum": {
		"name": "🤖 24시간 자율주행 AI 바닥 청소 로봇",
		"level": 0,
		"max_level": 3,
		"base_cost": 2100.0,
		"cost_mult": 2.0,
		"desc": "퇴실한 책상과 바닥 먼지를 실시간 자율 청소하여 청소 속도 2배"
	},
	"gourmet_bakery": {
		"name": "🍰 갓 구운 크로플 & 그릭요거트 디저트",
		"level": 0,
		"max_level": 3,
		"base_cost": 1700.0,
		"cost_mult": 1.9,
		"desc": "버터 풍미 크로플과 무설탕 요거트로 당 충전 매출 +40% 가산"
	},
	"recliner_pod": {
		"name": "🛋 1인 전용 무중력 리클라이너 소파 포드",
		"level": 0,
		"max_level": 3,
		"base_cost": 2400.0,
		"cost_mult": 2.2,
		"desc": "180도 각도 조절 1인 프리미엄 몰입 포드로 체류 시간 +30% 증가"
	},
	"cloud_printer": {
		"name": "🖨 모바일 무인 스마트 프린터 & 스캐너",
		"level": 0,
		"max_level": 3,
		"base_cost": 1100.0,
		"cost_mult": 1.8,
		"desc": "수험서 및 시험지 인쇄 스캔 무인 인쇄 정산 수수료"
	},
	"arcade_machine": {
		"name": "🎮 휴게실 레트로 픽셀 미니게임 아케이드",
		"level": 0,
		"max_level": 3,
		"base_cost": 1600.0,
		"cost_mult": 1.9,
		"desc": "공부 머리를 식혀주는 픽셀 테트리스 & 리듬 미니게임 코너"
	},
	"dual_monitors": {
		"name": "🖥 듀얼 모니터 코딩 몰입석",
		"level": 0,
		"max_level": 3,
		"base_cost": 2000.0,
		"cost_mult": 2.1,
		"desc": "개발자와 디자이너를 위한 4K 와이드 듀얼 모니터 독서실 책상"
	},
	"phone_booth": {
		"name": "🎙 1인 완전 방음 스마트 폰부스",
		"level": 0,
		"max_level": 3,
		"base_cost": 1500.0,
		"cost_mult": 1.9,
		"desc": "급한 전화를 스터디 존 밖에서 소음 없이 통화하여 민원 0건 달성"
	},
	"fast_charger": {
		"name": "⚡ 100W 초고속 USB-C PD 멀티 충전기",
		"level": 0,
		"max_level": 3,
		"base_cost": 800.0,
		"cost_mult": 1.7,
		"desc": "노트북과 태블릿을 초고속 충전하여 개발자 손님 매출 +25% 가산"
	},
	"herbal_tea": {
		"name": "🍵 유기농 캐모마일 & 허브티 셀프바",
		"level": 0,
		"max_level": 3,
		"base_cost": 1200.0,
		"cost_mult": 1.8,
		"desc": "심신 안정을 돕는 무카페인 힐링 티 코너로 스트레스 완화"
	},
	"vip_membership": {
		"name": "🏆 월 정기권 VIP 회원제 구독 시스템",
		"level": 0,
		"max_level": 5,
		"base_cost": 2500.0,
		"cost_mult": 2.0,
		"desc": "매일 1,500₩의 안정적인 고정 월 구독 정산 수금"
	},
	"nitro_coffee": {
		"name": "☕ 프리미엄 니트로 질소 콜드브루 탭",
		"level": 0,
		"max_level": 3,
		"base_cost": 2200.0,
		"cost_mult": 2.0,
		"desc": "부드러운 크레마와 초콜렛 풍미의 원두로 고급 음료 팁 매출 +50% 증가"
	},
	"rentals": {
		"name": "🎧 3M 귀마개 & 독서대/충전기 대여 자판기",
		"level": 1,
		"max_level": 5,
		"base_cost": 500.0,
		"cost_mult": 1.6,
		"desc": "노트북 거치대, 무소음 마우스, 3M 폼 귀마개 비품 대여 정산"
	},
	"lockers": {
		"name": "🎒 개인 스마트 사물함 & 도어락",
		"level": 1,
		"max_level": 5,
		"base_cost": 700.0,
		"cost_mult": 1.7,
		"desc": "무거운 수험서와 무소음 키보드를 보관하는 월 대여 사물함 매출"
	},
	"air_purifier": {
		"name": "🌿 초미세먼지 HEPA 공기청정기 & 바이오월",
		"level": 0,
		"max_level": 3,
		"base_cost": 1800.0,
		"cost_mult": 1.9,
		"desc": "산소 농도와 쾌적한 공기질을 100% 유지하여 평점 +0.3 가산"
	},
	"ai_coach": {
		"name": "🤖 AI 공시/수험 몰입 코치봇",
		"level": 0,
		"max_level": 3,
		"base_cost": 3000.0,
		"cost_mult": 2.5,
		"desc": "실시간 소음 감지 및 학습 스케줄링으로 빌런 자동 계도 및 몰입도 +35% 증가"
	},
	"smart_kiosk": {
		"name": "📱 모바일 키오스크 & 원격 좌석 예약 앱",
		"level": 0,
		"max_level": 3,
		"base_cost": 2000.0,
		"cost_mult": 2.2,
		"desc": "모바일 앱으로 미리 좌석을 결제 및 예약하여 유입량 +30% 상승"
	},
	"massage_chair": {
		"name": "🧘 휴게실 고급 안마의자 & 스트레칭존",
		"level": 0,
		"max_level": 3,
		"base_cost": 1500.0,
		"cost_mult": 2.0,
		"desc": "공부 피로도를 전신 마사지로 풀어주어 손님 만족도 및 체류 시간 +25% 증가"
	},
	"branch_expansion": {
		"name": "🏢 2호점 강남 직영점 오픈",
		"level": 0,
		"max_level": 3,
		"base_cost": 5000.0,
		"cost_mult": 3.0,
		"desc": "강남/판교 직영점 확장으로 전체 수익률 1.5배 폭증"
	},
	"staff_counter": {
		"name": "카운터 매니저 알바",
		"level": 0,
		"max_level": 3,
		"base_cost": 2500.0,
		"cost_mult": 2.5,
		"desc": "이용료와 음료 매출을 자동으로 정산 및 수금"
	},
	"ultrawide_monitors_vip": {
		"name": "🖥 38인치 울트라와이드 커브드 모니터석",
		"level": 0,
		"max_level": 3,
		"base_cost": 3500.0,
		"cost_mult": 2.2,
		"desc": "개발자와 디자이너 전용 고화질 듀얼 윈도우 모니터 독서실 책상"
	},
	"power_nap_capsule_vip": {
		"name": "🧘 무중력 파워 냅 수면 캡슐 & 숯 베개",
		"level": 0,
		"max_level": 3,
		"base_cost": 4000.0,
		"cost_mult": 2.4,
		"desc": "수험생 피로 회복 전용 30분 파워 수면 파드"
	},
	"anc_headphones_pro": {
		"name": "🎧 프리미엄 ANC 노이즈캔슬링 헤드폰 대여",
		"level": 0,
		"max_level": 3,
		"base_cost": 2800.0,
		"cost_mult": 2.0,
		"desc": "주변 소음을 완전 차단하는 고급 ANC 헤드폰 대여 정산"
	},
	"uvc_sterilizer_pro": {
		"name": "🧼 UV-C 무균 소독 데스크 장패드 & 살균기",
		"level": 0,
		"max_level": 3,
		"base_cost": 2200.0,
		"cost_mult": 1.9,
		"desc": "키보드와 데스크를 99.9% 무균 소독하여 매장 청결 평점 +0.4 가산"
	},
	"greenhouse_wall_pro": {
		"name": "🌸 대형 산소 공기정화 초록 온실 바이오월",
		"level": 0,
		"max_level": 3,
		"base_cost": 4500.0,
		"cost_mult": 2.5,
		"desc": "자연 산소 농도와 피톤치드 아로마를 발산하여 체류 시간 +40% 증가"
	}
}

const CUSTOMER_TYPES = [
	{ "type": "student", "name": "고등학생 수험생", "color": Color(0.3, 0.7, 1.0), "pay_rate": 1.0, "icon": "🎓" },
	{ "type": "examinee", "name": "공시생", "color": Color(1.0, 0.6, 0.2), "pay_rate": 1.4, "icon": "📚" },
	{ "type": "developer", "name": "프리랜서 개발자", "color": Color(0.2, 0.9, 0.5), "pay_rate": 1.8, "icon": "💻" },
	{ "type": "worker", "name": "재택 직장인", "color": Color(0.8, 0.4, 0.9), "pay_rate": 1.6, "icon": "☕" }
]

var active_customers: Array = []
var reviews_log: Array = []
var spawn_timer: float = 0.0
var temp_drift_timer: float = 0.0

func check_achievements() -> void:
	if not achievements["first_10k"]["unlocked"] and total_earnings >= 10000.0:
		unlock_achieve("first_10k")
	if not achievements["high_reputation"]["unlocked"] and reputation >= 4.8:
		unlock_achieve("high_reputation")
	if not achievements["master_visitors"]["unlocked"] and daily_visitors >= 20:
		unlock_achieve("master_visitors")

func unlock_achieve(key: String) -> void:
	if not achievements.has(key): return
	var ach = achievements[key]
	ach["unlocked"] = true
	add_money(ach["reward"])
	achievement_unlocked.emit(ach["title"], ach["reward"])
	_play_sfx_safe("chime")

func pet_cat() -> void:
	reputation = min(5.0, reputation + 0.05)
	reputation_changed.emit(reputation)
	_play_sfx_safe("chime")

func toggle_decorating_mode() -> bool:
	is_decorating_mode = not is_decorating_mode
	decor_mode_changed.emit(is_decorating_mode)
	return is_decorating_mode

func add_decoration(pos: Vector2, type: String = "plant") -> bool:
	var cost = 150.0
	if not can_afford(cost): return false
	add_money(-cost)
	custom_decorations.append({ "pos": pos, "type": type })
	reputation = min(5.0, reputation + 0.08)
	reputation_changed.emit(reputation)
	_play_sfx_safe("coin")
	return true

func _ready() -> void:
	load_game()

func change_zone(new_zone: String) -> void:
	current_zone = new_zone
	zone_changed.emit(new_zone)

func _process(delta: float) -> void:
	# Update Roasters Timers
	for idx in range(roasters.size()):
		var r = roasters[idx]
		if r["state"] == "ROASTING":
			r["timer"] -= delta
			if r["timer"] <= 0.0:
				r["state"] = "READY"
				r["timer"] = r["max_time"]
				roaster_updated.emit(idx, r)
		elif r["state"] == "READY":
			r["timer"] -= delta
			if r["timer"] <= -r["max_time"]:
				r["state"] = "BURNT"
				roaster_updated.emit(idx, r)

	game_time += delta * 0.3
	if game_time >= 24.0:
		game_time -= 24.0
		day_count += 1
		exam_d_day = max(1, exam_d_day - 1)
		add_review("DAY %d (수능 D-%d)! 열공 모드 지속 중입니다." % [day_count, exam_d_day], 5.0, "스터디 매니저")
		
	var new_tod = "DAY"
	if game_time >= 17.0 and game_time < 20.0:
		new_tod = "DUSK"
	elif game_time >= 20.0 or game_time < 6.0:
		new_tod = "NIGHT"
		
	if new_tod != time_of_day:
		time_of_day = new_tod
		time_of_day_changed.emit(time_of_day)
		
	weather_timer += delta
	if weather_timer >= 25.0:
		weather_timer = 0.0
		var next_w = "RAINY" if weather == "CLEAR" else "CLEAR"
		weather = next_w
		weather_changed.emit(weather)
		
	cat_patrol_timer += delta
	if cat_patrol_timer >= 6.0:
		cat_patrol_timer = 0.0
		cat_target = Vector2(randf_range(300, 700), randf_range(350, 480))
	cat_pos = cat_pos.move_toward(cat_target, delta * 30.0)
	
	temp_drift_timer += delta
	if temp_drift_timer >= 10.0:
		temp_drift_timer = 0.0
		temperature += randf_range(-0.6, 0.6)
		temperature = clamp(temperature, 18.0, 30.0)
		temperature_changed.emit(temperature)
	
	check_achievements()
	
	spawn_timer += delta
	var current_capacity = get_max_capacity()
	var available_seats = current_capacity - dirty_seats.size()
	var spawn_interval = max(1.2, 4.5 - (reputation * 0.6))
	
	if spawn_timer >= spawn_interval and active_customers.size() < available_seats:
		spawn_timer = 0.0
		spawn_customer()
	
	var entrance_pos = Vector2(1150, 70)
	var to_remove = []
	
	for c in active_customers:
		var target = c["target_pos"]
		var current_pos = c["pos"]
		
		if c["state"] == "WALKING_IN":
			var lounge_target = Vector2(850, 190)
			c["pos"] = current_pos.move_toward(lounge_target, delta * 140.0)
			if c["pos"].distance_to(lounge_target) < 8.0:
				c["state"] = "EATING_CAKE"
				c["eating_timer"] = 0.0
				add_money(450.0)
		elif c["state"] == "EATING_CAKE":
			c["eating_timer"] += delta * 1.0
			if c["eating_timer"] >= 2.5:
				c["state"] = "WALKING_TO_SEAT"
		elif c["state"] == "WALKING_TO_SEAT":
			c["pos"] = current_pos.move_toward(target, delta * 130.0)
			if c["pos"].distance_to(target) < 6.0:
				c["state"] = "STUDYING"
		elif c["state"] == "STUDYING":
			c["study_time"] += delta
			var temp_penalty = 1.0
			if temperature < 21.0 or temperature > 27.0:
				temp_penalty = 0.7
				
			var rain_bonus = 1.2 if weather == "RAINY" else 1.0
			var tick_income = get_income_per_second_for_customer(c) * temp_penalty * rain_bonus * delta
			add_money(tick_income)
			daily_seat_rev += tick_income
			
			if not active_orders.has(c["id"]) and c["study_time"] > 2.0 and randf() < 0.005:
				create_order(c["id"])
				
			if c["study_time"] >= c["duration"]:
				c["state"] = "LEAVING"
				c["target_pos"] = entrance_pos
		elif c["state"] == "LEAVING":
			c["pos"] = current_pos.move_toward(entrance_pos, delta * 140.0)
			if c["pos"].distance_to(entrance_pos) < 6.0:
				to_remove.append(c)
				
	for c in to_remove:
		finish_customer(c)
		
	var cleaner_lvl = upgrades["staff_cleaner"]["level"]
	if cleaner_lvl > 0:
		for fl in [1, 2, 3]:
			var mgr = floor_cleaner_managers[fl]
			var c_pos = mgr["pos"]
			var c_target = mgr["target"]
			if dirty_seats.size() > 0 and current_floor == fl:
				c_target = get_seat_position(dirty_seats[0])
				mgr["target"] = c_target
				c_pos = c_pos.move_toward(c_target, delta * (100.0 + cleaner_lvl * 40.0))
				if c_pos.distance_to(c_target) < 10.0:
					clean_seat(dirty_seats[0])
			else:
				var patrol_x = 300.0 + (fl * 40) + sin(Time.get_ticks_msec() * 0.001 * fl) * 60.0
				c_target = Vector2(patrol_x, 260.0 + cos(Time.get_ticks_msec() * 0.001) * 25.0)
				c_pos = c_pos.move_toward(c_target, delta * 50.0)
			mgr["pos"] = c_pos
		cleaner_pos = floor_cleaner_managers[current_floor]["pos"]
			
	if upgrades["staff_counter"]["level"] > 0:
		var auto_inc = upgrades["staff_counter"]["level"] * 20.0 * delta
		add_money(auto_inc)
		daily_seat_rev += auto_inc
		if active_orders.size() > 0:
			var first_cid = active_orders.keys()[0]
			serve_order(first_cid)

func spawn_customer() -> void:
	var current_capacity = get_max_capacity()
	var taken_seats = []
	for c in active_customers:
		taken_seats.append(c["seat_index"])
		
	var free_seat = -1
	for i in range(current_capacity):
		if not taken_seats.has(i) and not dirty_seats.has(i):
			free_seat = i
			break
			
	if free_seat == -1: return
	
	var template = CUSTOMER_TYPES[randi() % CUSTOMER_TYPES.size()]
	var cid = randi()
	var entrance_pos = Vector2(1150, 70)
	var seat_target = get_seat_position(free_seat)
	
	var customer = {
		"id": cid,
		"name": template["name"],
		"type": template["type"],
		"color": template["color"],
		"pay_rate": template["pay_rate"],
		"icon": template["icon"],
		"study_time": 0.0,
		"duration": randf_range(10.0, 24.0),
		"seat_index": free_seat,
		"pos": entrance_pos,
		"target_pos": seat_target,
		"state": "WALKING_IN"
	}
	active_customers.append(customer)
	daily_visitors += 1
	customer_arrived.emit(customer)
	
	if randf() < 0.15:
		var v_types = ["phone", "snack", "snore"]
		var v_type = v_types[randi() % v_types.size()]
		active_villains[cid] = { "type": v_type, "warnings": 0 }
		villain_appeared.emit(cid, v_type)

func finish_customer(c: Dictionary) -> void:
	var bonus_tip = c["pay_rate"] * (80.0 + upgrades["coffee_bar"]["level"] * 40.0)
	add_money(bonus_tip)
	daily_seat_rev += bonus_tip
	
	var s_idx = c["seat_index"]
	if not dirty_seats.has(s_idx):
		dirty_seats.append(s_idx)
		seat_dirty.emit(s_idx)
		
	active_orders.erase(c["id"])
	active_villains.erase(c["id"])
	active_customers.erase(c)
	customer_left.emit(c, bonus_tip)
	
	if randf() < 0.35:
		generate_random_review()

func create_order(customer_id: int) -> void:
	var o_types = ["☕ 아이스 아메리카노", "🥐 바삭 크로플", "🍵 따뜻한 말차 라떼"]
	var selected = o_types[randi() % o_types.size()]
	active_orders[customer_id] = { "type": selected, "time": game_time }
	order_created.emit(customer_id, selected)

func serve_order(customer_id: int) -> bool:
	if not active_orders.has(customer_id): return false
	var tip = 300.0 + (upgrades["coffee_bar"]["level"] * 80.0)
	add_money(tip)
	daily_drink_rev += tip
	active_orders.erase(customer_id)
	order_served.emit(customer_id, tip)
	return true

func warn_villain(customer_id: int) -> void:
	if not active_villains.has(customer_id): return
	var v = active_villains[customer_id]
	v["warnings"] += 1
	if v["warnings"] >= 1:
		active_villains.erase(customer_id)
		reputation = min(5.0, reputation + 0.1)
		reputation_changed.emit(reputation)
		villain_resolved.emit(customer_id)

func clean_seat(seat_index: int) -> void:
	if dirty_seats.has(seat_index):
		dirty_seats.erase(seat_index)
		add_money(80.0)
		daily_clean_rev += 80.0
		seat_cleaned.emit(seat_index)

func adjust_temperature(delta_t: float) -> void:
	temperature = clamp(temperature + delta_t, 18.0, 30.0)
	temperature_changed.emit(temperature)

func get_customer_at_seat(seat_idx: int) -> Dictionary:
	for c in active_customers:
		if c.get("seat_index", -1) == seat_idx:
			return c
	return {}

func change_floor(floor_num: int) -> void:
	if not unlocked_floors.has(floor_num):
		return
	current_floor = floor_num
	floor_changed.emit(current_floor)

func buy_floor(floor_num: int) -> bool:
	if unlocked_floors.has(floor_num): return true
	var cost = 50000.0 if floor_num == 2 else 150000.0
	if not can_afford(cost): return false
	
	add_money(-cost)
	unlocked_floors.append(floor_num)
	current_floor = floor_num
	reputation = min(5.0, reputation + 0.3)
	reputation_changed.emit(reputation)
	floor_changed.emit(current_floor)
	save_game()
	return true

func get_max_capacity() -> int:
	var open = upgrades["open_seats"]["level"] * 3
	var booth = upgrades["private_booths"]["level"] * 2
	var floor_bonus = (unlocked_floors.size() - 1) * 6
	return max(4, open + booth + floor_bonus)

func get_income_per_second_for_customer(c: Dictionary) -> float:
	var base_rate = 12.0
	var chair_mult = 1.0 + (upgrades["chairs"]["level"] * 0.25)
	var wifi_mult = 1.0 + (upgrades["wifi"]["level"] * 0.2)
	var noise_mult = 1.0 + (upgrades["white_noise"]["level"] * 0.3)
	var branch_mult = 1.0 + (upgrades["branch_expansion"]["level"] * 0.5)
	return base_rate * c["pay_rate"] * chair_mult * wifi_mult * noise_mult * branch_mult

func get_total_income_rate() -> float:
	var total = 0.0
	for c in active_customers:
		total += get_income_per_second_for_customer(c)
	if upgrades["staff_counter"]["level"] > 0:
		total += upgrades["staff_counter"]["level"] * 20.0
	return total

func get_base_seat_position(index: int) -> Vector2:
	var cols = 4
	var start_x = 60.0
	var start_y = 160.0
	var cell_w = 160.0
	var cell_h = 100.0
	var col = index % cols
	var row = index / cols
	return Vector2(start_x + col * (cell_w + 30.0) + cell_w*0.5, start_y + row * (cell_h + 30.0) + cell_h*0.5)

var seat_rotations: Dictionary = {} # seat_index -> 0, 90, 180, 270 degrees

func snap_to_grid(pos: Vector2, grid_size: float = 40.0) -> Vector2:
	return Vector2(
		snapped(pos.x, grid_size),
		snapped(pos.y, grid_size)
	)

func set_seat_custom_offset_snapped(index: int, raw_offset: Vector2) -> void:
	var base_pos = get_base_seat_position(index)
	var target_world_pos = base_pos + raw_offset
	var snapped_world_pos = snap_to_grid(target_world_pos, 40.0)
	seat_custom_offsets[index] = snapped_world_pos - base_pos

func rotate_seat(index: int) -> int:
	var current_rot = seat_rotations.get(index, 0)
	var new_rot = (current_rot + 90) % 360
	seat_rotations[index] = new_rot
	return new_rot

func are_seats_adjacent(idx1: int, idx2: int) -> bool:
	var p1 = get_seat_position(idx1)
	var p2 = get_seat_position(idx2)
	return p1.distance_to(p2) <= 190.0

var desk_catalog: Dictionary = {
	"open_1x1": {
		"name": "☕ 오픈 카페석 (1x1 규격)",
		"size": Vector2(1, 1),
		"cost": 1000.0,
		"pixel_size": Vector2(140, 90),
		"desc": "아늑한 1x1 규격의 기본 오픈 스터디 책상 (집중도 +10%)"
	},
	"booth_2x2": {
		"name": "🔮 프라이빗 1인실 부스 (2x2 규격)",
		"size": Vector2(2, 2),
		"cost": 2500.0,
		"pixel_size": Vector2(260, 180),
		"desc": "독립된 2x2 규격의 대형 방음 1인실 몰입 부스 (수익 +25%)"
	},
	"vip_2x1": {
		"name": "🖥 VIP 38인치 울트라와이드 모니터석 (2x1 규격)",
		"size": Vector2(2, 1),
		"cost": 4000.0,
		"pixel_size": Vector2(240, 100),
		"desc": "개발자/디자이너 전용 2x1 듀얼 모니터 커스텀 데스크 (열공 팁 +50%)"
	},
	"dual_island_2x2": {
		"name": "🏰 듀얼 2인 열공 아일랜드 (2x2 규격)",
		"size": Vector2(2, 2),
		"cost": 6000.0,
		"pixel_size": Vector2(260, 180),
		"desc": "팀 스터디 및 커플 전용 2인 아일랜드 데스크 (매출 2배)"
	},
	"royal_gold_2x2": {
		"name": "👑 로열 익세큐티브 골드 부스 (2x2 규격)",
		"size": Vector2(2, 2),
		"cost": 10000.0,
		"pixel_size": Vector2(280, 200),
		"desc": "황금 앰버 가죽 의자 & 리모컨 조명 럭셔리 부스 (평점 +0.5)"
	}
}

func buy_new_desk(type_key: String) -> bool:
	if not desk_catalog.has(type_key): return false
	var c_item = desk_catalog[type_key]
	var cost = c_item["cost"]
	if not can_afford(cost): return false
	
	add_money(-cost)
	if type_key.contains("booth") or type_key.contains("island") or type_key.contains("gold"):
		upgrades["private_booths"]["level"] += 1
	else:
		upgrades["open_seats"]["level"] += 1
	
	reputation = min(5.0, reputation + 0.2)
	reputation_changed.emit(reputation)
	save_game()
	upgrade_purchased.emit("open_seats", upgrades["open_seats"]["level"])
	return true

func get_seat_position(index: int) -> Vector2:
	if seat_custom_positions.has(index):
		return seat_custom_positions[index]
	var base_pos = get_base_seat_position(index)
	if seat_custom_offsets.has(index):
		return base_pos + seat_custom_offsets[index]
	return base_pos

func add_money(amount: float) -> void:
	money += amount
	if amount > 0:
		total_earnings += amount
	money_changed.emit(money, amount)

func can_afford(cost: float) -> bool:
	return money >= cost

func get_upgrade_cost(category: String) -> float:
	if not upgrades.has(category): return 0.0
	var item = upgrades[category]
	return item["base_cost"] * pow(item["cost_mult"], item["level"])

func buy_upgrade(category: String) -> bool:
	if not upgrades.has(category): return false
	var item = upgrades[category]
	if item["level"] >= item["max_level"]: return false
	
	var cost = get_upgrade_cost(category)
	if not can_afford(cost): return false
	
	add_money(-cost)
	item["level"] += 1
	
	reputation = min(5.0, reputation + 0.15)
	reputation_changed.emit(reputation)
	upgrade_purchased.emit(category, item["level"])
	
	save_game()
	return true

func add_review(text: String, rating: float, author: String) -> void:
	var review = {
		"text": text,
		"rating": rating,
		"author": author,
		"time": "%02d:%02d" % [int(game_time), int(fmod(game_time * 60.0, 60.0))]
	}
	reviews_log.push_front(review)
	if reviews_log.size() > 20:
		reviews_log.pop_back()
	review_added.emit(review)

func generate_random_review() -> void:
	var sample_reviews = [
		"의자가 진짜 편해서 인강 3개 연속으로 다 들었어요! ⭐5",
		"에스프레소 머신 커피 향이 최고입니다. 몰입 잘돼요! ⭐5",
		"초고속 Wi-Fi 덕분에 개발 작업 끊김없이 완료했습니다! ⭐5",
		"백색소음 잔잔하게 들려서 독서하기 딱 좋아요. ⭐5",
		"스터디 카페 인테리어가 차분하고 깔끔해요. 단골 확정! ⭐5"
	]
	var text = sample_reviews[randi() % sample_reviews.size()]
	add_review(text, 5.0, "열공중인 손님")

func save_game() -> void:
	var data = {
		"money": money,
		"total_earnings": total_earnings,
		"reputation": reputation,
		"day_count": day_count,
		"temperature": temperature,
		"upgrades": {}
	}
	for key in upgrades:
		data["upgrades"][key] = upgrades[key]["level"]
		
	var file = FileAccess.open("user://study_cafe_tycoon_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists("user://study_cafe_tycoon_save.json"):
		return
	var file = FileAccess.open("user://study_cafe_tycoon_save.json", FileAccess.READ)
	if not file: return
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	if json.parse(json_text) == OK:
		var data = json.get_data()
		money = data.get("money", 5000.0)
		total_earnings = data.get("total_earnings", 0.0)
		reputation = data.get("reputation", 4.2)
		day_count = data.get("day_count", 1)
		temperature = data.get("temperature", 24.0)
		
		var saved_upgrades = data.get("upgrades", {})
		for key in saved_upgrades:
			if upgrades.has(key):
				upgrades[key]["level"] = saved_upgrades[key]

func format_money(val: float) -> String:
	var n = int(val)
	var s = str(n)
	var res = ""
	var cnt = 0
	for i in range(s.length() - 1, -1, -1):
		if cnt > 0 and cnt % 3 == 0:
			res = "," + res
		res = s[i] + res
		cnt += 1
	return res

