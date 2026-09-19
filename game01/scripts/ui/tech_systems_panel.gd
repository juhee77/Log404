extends PanelContainer

# tech_systems_panel.gd - 매장 설비 관제 오버레이 (Facilities Control Overlay)

signal closed

var scroll_container: ScrollContainer
var container_list: VBoxContainer
var btn_close: Button
var card_nodes: Dictionary = {}

var tech_modules = [
	{
		"category": "🔌 설비 & 공조",
		"items": [
			{"id": "antimatter", "title": "⚡ 심야 전력 절감 ESS", "toggle_func": "toggle_antimatter_hud", "metrics_func": "calculate_antimatter_energy_metrics", "open_var": "is_antimatter_hud_open"},
			{"id": "harvesting", "title": "🔌 좌석별 무선 충전 패드", "toggle_func": "toggle_harvesting_hud", "metrics_func": "calculate_electromagnetic_harvesting_metrics", "open_var": "is_harvesting_hud_open"},
			{"id": "fusion", "title": "🔥 고효율 인버터 냉난방", "toggle_func": "toggle_fusion_hud", "metrics_func": "calculate_fusion_reactor_metrics", "open_var": "is_fusion_hud_open"},
			{"id": "solar", "title": "☀️ 옥상 태양광 자가발전", "toggle_func": "toggle_solar_hud", "metrics_func": "calculate_solar_ess_metrics", "open_var": "is_solar_hud_open"},
			{"id": "farm", "title": "🌿 실내 그린월 공기정화", "toggle_func": "toggle_farm_hud", "metrics_func": "calculate_vertical_farm_metrics", "open_var": "is_farm_hud_open"},
			{"id": "zero_point", "title": "🔋 피크 부하 배터리 뱅크", "toggle_func": "toggle_zero_point_hud", "metrics_func": "calculate_zero_point_energy_metrics", "open_var": "is_zero_point_hud_open"},
			{"id": "nanite_sanitation", "title": "🧼 자동 살균 방역 시스템", "toggle_func": "toggle_nanite_sanitation_hud", "metrics_func": "calculate_nanite_sanitation_metrics", "open_var": "is_nanite_sanitation_hud_open"},
			{"id": "superconductive_power", "title": "🔧 노후 배선 전면 교체", "toggle_func": "toggle_superconductive_power_hud", "metrics_func": "calculate_superconductive_power_metrics", "open_var": "is_superconductive_power_hud_open"},
			{"id": "biophotonic_air", "title": "💨 전열교환 환기 시스템", "toggle_func": "toggle_biophotonic_air_hud", "metrics_func": "calculate_biophotonic_air_metrics", "open_var": "is_biophotonic_air_hud_open"},
			{"id": "photonic_power", "title": "💡 인체감지 LED 조명 제어", "toggle_func": "toggle_photonic_power_hud", "metrics_func": "calculate_photonic_power_metrics", "open_var": "is_photonic_power_hud_open"},
			{"id": "dark_energy_converter", "title": "📉 실시간 전력 사용 모니터", "toggle_func": "toggle_dark_energy_converter_hud", "metrics_func": "calculate_dark_energy_converter_metrics", "open_var": "is_dark_energy_converter_hud_open"}
		]
	},
	{
		"category": "🔇 방음 & 공간",
		"items": [
			{"id": "tesseract", "title": "📐 접이식 파티션 가변 레이아웃", "toggle_func": "toggle_tesseract_hud", "metrics_func": "calculate_tesseract_expansion_metrics", "open_var": "is_tesseract_hud_open"},
			{"id": "tachyon", "title": "⏱️ 좌석 자동 연장 결제", "toggle_func": "toggle_tachyon_hud", "metrics_func": "calculate_tachyon_chrono_metrics", "open_var": "is_tachyon_hud_open"},
			{"id": "grav", "title": "🔇 액티브 노이즈 차폐 패널", "toggle_func": "toggle_grav_acoustic_hud", "metrics_func": "calculate_gravitational_acoustic_metrics", "open_var": "is_grav_acoustic_hud_open"},
			{"id": "teleport", "title": "🛎️ 모바일 주문 픽업 알림", "toggle_func": "toggle_teleport_hud", "metrics_func": "calculate_teleportation_metrics", "open_var": "is_teleport_hud_open"},
			{"id": "multiverse", "title": "🗺️ 층별 구역 분리 설계", "toggle_func": "toggle_multiverse_hud", "metrics_func": "calculate_multiverse_bifurcation_metrics", "open_var": "is_multiverse_hud_open"},
			{"id": "chrono_res", "title": "🕐 시간대별 요금제", "toggle_func": "toggle_chrono_resonance_hud", "metrics_func": "calculate_chrono_resonance_metrics", "open_var": "is_chrono_resonance_hud_open"},
			{"id": "acoustic_damping", "title": "🧱 흡음 천장 & 벽면 마감", "toggle_func": "toggle_acoustic_damping_hud", "metrics_func": "calculate_acoustic_damping_metrics", "open_var": "is_acoustic_damping_hud_open"},
			{"id": "quantum_gravity", "title": "🪟 이중창 외부 소음 차단", "toggle_func": "toggle_quantum_gravity_hud", "metrics_func": "calculate_quantum_gravity_metrics", "open_var": "is_quantum_gravity_hud_open"},
			{"id": "dark_matter_gravity", "title": "🚪 도어 클로저 소음 저감", "toggle_func": "toggle_dark_matter_gravity_hud", "metrics_func": "calculate_dark_matter_gravity_metrics", "open_var": "is_dark_matter_gravity_hud_open"},
			{"id": "chrono_dilation", "title": "📅 좌석 사전 예약 시스템", "toggle_func": "toggle_chrono_dilation_hud", "metrics_func": "calculate_chrono_dilation_metrics", "open_var": "is_chrono_dilation_hud_open"},
			{"id": "singularity_power", "title": "🏗️ 내력벽 보강 & 층간 방음", "toggle_func": "toggle_singularity_power_hud", "metrics_func": "calculate_singularity_power_metrics", "open_var": "is_singularity_power_hud_open"}
		]
	},
	{
		"category": "📊 데이터 & 학습지원",
		"items": [
			{"id": "supercomputer", "title": "📊 좌석 이용 분석 대시보드", "toggle_func": "toggle_supercomputer_hud", "metrics_func": "calculate_holographic_supercomputer_metrics", "open_var": "is_supercomputer_hud_open"},
			{"id": "telepathic", "title": "🎧 집중 사운드 추천", "toggle_func": "toggle_telepathic_hud", "metrics_func": "calculate_neural_telepathic_metrics", "open_var": "is_telepathic_hud_open"},
			{"id": "olfactory", "title": "🌿 피톤치드 공간 디퓨저", "toggle_func": "toggle_olfactory_hud", "metrics_func": "calculate_olfactory_synthesizer_metrics", "open_var": "is_olfactory_hud_open"},
			{"id": "curriculum", "title": "📚 학습 플래너 연동", "toggle_func": "toggle_curriculum_hud", "metrics_func": "calculate_quantum_curriculum_metrics", "open_var": "is_curriculum_hud_open"},
			{"id": "biometric", "title": "🎵 시간대별 BGM 자동 전환", "toggle_func": "toggle_biometric_hud", "metrics_func": "calculate_biometric_pulse_metrics", "open_var": "is_biometric_hud_open"},
			{"id": "neural_cog", "title": "📈 체류시간 패턴 리포트", "toggle_func": "toggle_neural_cognitive_hud", "metrics_func": "calculate_neural_cognitive_metrics", "open_var": "is_neural_cognitive_hud_open"},
			{"id": "bio_rest", "title": "💤 수면실 & 파워냅 존", "toggle_func": "toggle_bio_rest_hud", "metrics_func": "calculate_bio_rest_metrics", "open_var": "is_bio_rest_hud_open"},
			{"id": "memory_crystal", "title": "🗂️ 스터디 자료 공유 서가", "toggle_func": "toggle_memory_crystal_hud", "metrics_func": "calculate_memory_crystal_metrics", "open_var": "is_memory_crystal_hud_open"},
			{"id": "peptide_stimulator", "title": "🥤 카페인 & 당충전 메뉴 추천", "toggle_func": "toggle_peptide_stimulator_hud", "metrics_func": "calculate_peptide_stimulator_metrics", "open_var": "is_peptide_stimulator_hud_open"},
			{"id": "neural_crystallizer", "title": "✍️ 오답노트 스캔 프린트", "toggle_func": "toggle_neural_crystallizer_hud", "metrics_func": "calculate_neural_crystallizer_metrics", "open_var": "is_neural_crystallizer_hud_open"},
			{"id": "transmutation_reactor", "title": "🎯 목표 달성률 트래커", "toggle_func": "toggle_transmutation_reactor_hud", "metrics_func": "calculate_transmutation_reactor_metrics", "open_var": "is_transmutation_reactor_hud_open"}
		]
	},
	{
		"category": "🏪 운영 & 확장",
		"items": [
			{"id": "treasury", "title": "💳 통합 POS & 자동 정산", "toggle_func": "toggle_treasury_hud", "metrics_func": "calculate_quantum_treasury_metrics", "open_var": "is_treasury_hud_open"},
			{"id": "satellite", "title": "📶 기가 와이파이 증설", "toggle_func": "toggle_satellite_hud", "metrics_func": "calculate_satellite_network_metrics", "open_var": "is_satellite_hud_open"},
			{"id": "cryo", "title": "❄️ 콜드브루 저온 추출", "toggle_func": "toggle_cryo_hud", "metrics_func": "calculate_cryogenic_roaster_metrics", "open_var": "is_cryo_hud_open"},
			{"id": "exoskeleton", "title": "🪑 인체공학 의자 전면 교체", "toggle_func": "toggle_exoskeleton_hud", "metrics_func": "calculate_exoskeleton_metrics", "open_var": "is_exoskeleton_hud_open"},
			{"id": "water_gen", "title": "💧 직수형 정수 시스템", "toggle_func": "toggle_water_gen_hud", "metrics_func": "calculate_water_generator_metrics", "open_var": "is_water_gen_hud_open"},
			{"id": "satellite_mesh", "title": "🌐 지점 통합 관리 시스템", "toggle_func": "toggle_satellite_mesh_hud", "metrics_func": "calculate_satellite_mesh_metrics", "open_var": "is_satellite_mesh_hud_open"},
			{"id": "cryo_roaster", "title": "☕ 저온 숙성 로스팅 설비", "toggle_func": "toggle_cryo_roaster_hud", "metrics_func": "calculate_cryo_roaster_metrics", "open_var": "is_cryo_roaster_hud_open"},
			{"id": "exoskeleton_corrector", "title": "🧘 자세교정 스트레칭 존", "toggle_func": "toggle_exoskeleton_corrector_hud", "metrics_func": "calculate_exoskeleton_corrector_metrics", "open_var": "is_exoskeleton_corrector_hud_open"},
			{"id": "atmospheric_water", "title": "🚰 층별 급수대 증설", "toggle_func": "toggle_nano_atmospheric_water_hud", "metrics_func": "calculate_nano_atmospheric_water_metrics", "open_var": "is_nano_atmospheric_water_hud_open"},
			{"id": "aeroponic_botanical", "title": "🪴 실내 조경 & 식물 관리", "toggle_func": "toggle_aeroponic_botanical_hud", "metrics_func": "calculate_aeroponic_botanical_metrics", "open_var": "is_aeroponic_botanical_hud_open"},
			{"id": "maglev_floor", "title": "🧹 무소음 바닥재 시공", "toggle_func": "toggle_maglev_floor_hud", "metrics_func": "calculate_maglev_floor_metrics", "open_var": "is_maglev_floor_hud_open"},
			{"id": "franchise_ledger", "title": "🏪 2호점 가맹 관리 원장", "toggle_func": "toggle_franchise_ledger_hud", "metrics_func": "calculate_franchise_ledger_metrics", "open_var": "is_franchise_ledger_hud_open"}
		]
	}
]

func _ready() -> void:
	custom_minimum_size = Vector2(720, 500)
	mouse_filter = Control.MOUSE_FILTER_STOP
	build_layout()

func build_layout() -> void:
	for c in get_children():
		c.queue_free()
		
	var main_margin = MarginContainer.new()
	main_margin.add_theme_constant_override("margin_left", 20)
	main_margin.add_theme_constant_override("margin_top", 16)
	main_margin.add_theme_constant_override("margin_right", 20)
	main_margin.add_theme_constant_override("margin_bottom", 16)
	add_child(main_margin)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	main_margin.add_child(main_vbox)
	
	# Header
	var header_hbox = HBoxContainer.new()
	var title_lbl = Label.new()
	title_lbl.text = "🛠️ 매장 설비 관제실 (Facilities)"
	title_lbl.add_theme_font_size_override("font_size", 18)
	title_lbl.add_theme_color_override("font_color", Color(0.2, 0.95, 0.85))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_lbl)
	
	btn_close = Button.new()
	btn_close.text = " ✖ 닫기 "
	btn_close.pressed.connect(func(): hide(); closed.emit())
	header_hbox.add_child(btn_close)
	main_vbox.add_child(header_hbox)
	
	# Subtitle
	var sub_lbl = Label.new()
	sub_lbl.text = "공조·방음·데이터·운영 설비의 가동 상태를 확인하고, 매장 화면에 표시할 계기판을 켜고 끕니다."
	sub_lbl.add_theme_font_size_override("font_size", 12)
	sub_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9))
	main_vbox.add_child(sub_lbl)
	
	# Scroll area for categories
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_vbox.add_child(scroll_container)
	
	container_list = VBoxContainer.new()
	container_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container_list.add_theme_constant_override("separation", 16)
	scroll_container.add_child(container_list)
	
	refresh_cards()

func refresh_cards() -> void:
	if not container_list: return
	for child in container_list.get_children():
		child.queue_free()
		
	for cat in tech_modules:
		var cat_lbl = Label.new()
		cat_lbl.text = cat["category"]
		cat_lbl.add_theme_font_size_override("font_size", 15)
		cat_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		container_list.add_child(cat_lbl)
		
		var grid = GridContainer.new()
		# One column: at two columns each card's toggle button ran past the
		# panel's right edge and was clipped.
		grid.columns = 1
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 10)
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		container_list.add_child(grid)
		
		for item in cat["items"]:
			var card = PanelContainer.new()
			card.custom_minimum_size = Vector2(320, 68)
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var card_margin = MarginContainer.new()
			card_margin.add_theme_constant_override("margin_left", 10)
			card_margin.add_theme_constant_override("margin_top", 8)
			card_margin.add_theme_constant_override("margin_right", 10)
			card_margin.add_theme_constant_override("margin_bottom", 8)
			card.add_child(card_margin)
			
			var card_hbox = HBoxContainer.new()
			card_margin.add_child(card_hbox)
			
			var info_vbox = VBoxContainer.new()
			info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var item_title = Label.new()
			item_title.text = item["title"]
			item_title.add_theme_font_size_override("font_size", 13)
			item_title.add_theme_color_override("font_color", Color.WHITE)
			info_vbox.add_child(item_title)
			
			var status_lbl = Label.new()
			var info_dict = {}
			if GameState.has_method(item["metrics_func"]):
				info_dict = GameState.call(item["metrics_func"])
			var status_text = info_dict.get("status", "가동 중")
			status_lbl.text = status_text
			status_lbl.add_theme_font_size_override("font_size", 10)
			status_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.6))
			info_vbox.add_child(status_lbl)
			card_hbox.add_child(info_vbox)
			
			var is_on = GameState.get(item["open_var"]) if item["open_var"] in GameState else false
			var btn_toggle = Button.new()
			btn_toggle.custom_minimum_size = Vector2(70, 32)
			btn_toggle.text = "HUD OFF" if not is_on else "HUD ON"
			if is_on:
				btn_toggle.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
			else:
				btn_toggle.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
				
			btn_toggle.pressed.connect(func():
				if GameState.has_method(item["toggle_func"]):
					GameState.call(item["toggle_func"])
					refresh_cards()
			)
			card_hbox.add_child(btn_toggle)
			grid.add_child(card)
