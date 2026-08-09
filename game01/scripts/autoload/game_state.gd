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
signal decor_mode_changed(is_active)
signal achievement_unlocked(title, reward)

# Financial & Time Variables
var money: float = 5000.0
var total_earnings: float = 0.0
var reputation: float = 4.2
var day_count: int = 1
var exam_d_day: int = 100
var game_time: float = 8.0
var time_of_day: String = "DAY"
var weather: String = "RAINY"
var weather_timer: float = 0.0

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
	"suhyun": { "name": "재수생 수현", "level": 1, "xp": 0, "max_xp": 100, "reward": "원목 독서대" },
	"minjun": { "name": "개발자 민준", "level": 1, "xp": 0, "max_xp": 100, "reward": "울트라와이드 모니터석" },
	"hyunwoo": { "name": "고시생 현우", "level": 1, "xp": 0, "max_xp": 100, "reward": "기출 족보 서가" },
	"navi": { "name": "고양이 나비", "level": 1, "xp": 0, "max_xp": 100, "reward": "황금 고양이 동상" }
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

# Snack Bar & Locker Stock
var snack_stock: int = 100
var lockers_rented: int = 4

# Staff Character Animated Positions
var cleaner_pos: Vector2 = Vector2(700, 70)
var cleaner_target: Vector2 = Vector2(700, 70)
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
			c["pos"] = current_pos.move_toward(target, delta * 120.0)
			if c["pos"].distance_to(target) < 4.0:
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
		if dirty_seats.size() > 0:
			var target_seat_pos = get_seat_position(dirty_seats[0])
			cleaner_target = target_seat_pos
			cleaner_pos = cleaner_pos.move_toward(cleaner_target, delta * (100.0 + cleaner_lvl * 40.0))
			
			if cleaner_pos.distance_to(cleaner_target) < 10.0:
				clean_seat(dirty_seats[0])
		else:
			cleaner_target = Vector2(1050, 70)
			cleaner_pos = cleaner_pos.move_toward(cleaner_target, delta * 80.0)
			
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

func get_max_capacity() -> int:
	var open = upgrades["open_seats"]["level"] * 3
	var booth = upgrades["private_booths"]["level"] * 2
	return max(4, open + booth)

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
		"desc": "아늑한 1x1 규격의 기본 오픈 스터디 책상"
	},
	"booth_2x2": {
		"name": "🔮 프라이빗 1인실 부스 (2x2 규격)",
		"size": Vector2(2, 2),
		"cost": 2500.0,
		"pixel_size": Vector2(260, 180),
		"desc": "독립된 2x2 규격의 대형 방음 1인실 몰입 부스"
	},
	"vip_2x1": {
		"name": "🖥 VIP 38인치 울트라와이드 모니터석 (2x1 규격)",
		"size": Vector2(2, 1),
		"cost": 4000.0,
		"pixel_size": Vector2(240, 100),
		"desc": "개발자/디자이너 전용 2x1 듀얼 모니터 커스텀 데스크"
	}
}

func buy_new_desk(type_key: String) -> bool:
	if not desk_catalog.has(type_key): return false
	var c_item = desk_catalog[type_key]
	var cost = c_item["cost"]
	if not can_afford(cost): return false
	
	add_money(-cost)
	if type_key == "booth_2x2":
		upgrades["private_booths"]["level"] += 1
	else:
		upgrades["open_seats"]["level"] += 1
	save_game()
	upgrade_purchased.emit("open_seats", upgrades["open_seats"]["level"])
	return true

func get_seat_position(index: int) -> Vector2:
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
