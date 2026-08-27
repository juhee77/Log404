extends PanelContainer

# tech_systems_panel.gd - High-Tech Subsystems Control & Operations Center Overlay

signal closed

var scroll_container: ScrollContainer
var container_list: VBoxContainer
var btn_close: Button
var card_nodes: Dictionary = {}

var tech_modules = [
	{
		"category": "⚡ 에너지 & 파워",
		"items": [
			{"id": "antimatter", "title": "⚛️ 양자 얽힘 반물질 발전", "toggle_func": "toggle_antimatter_hud", "metrics_func": "calculate_antimatter_energy_metrics", "open_var": "is_antimatter_hud_open"},
			{"id": "harvesting", "title": "⚡ 전자기장 무선 하베스팅", "toggle_func": "toggle_harvesting_hud", "metrics_func": "calculate_electromagnetic_harvesting_metrics", "open_var": "is_harvesting_hud_open"},
			{"id": "fusion", "title": "☢️ 핵융합 마이크로 발전기", "toggle_func": "toggle_fusion_hud", "metrics_func": "calculate_fusion_reactor_metrics", "open_var": "is_fusion_hud_open"},
			{"id": "solar", "title": "☀️ 태양광 ESS 전력망", "toggle_func": "toggle_solar_hud", "metrics_func": "calculate_solar_ess_metrics", "open_var": "is_solar_hud_open"},
			{"id": "farm", "title": "🌾 수직농장 바이오 발전", "toggle_func": "toggle_farm_hud", "metrics_func": "calculate_vertical_farm_metrics", "open_var": "is_farm_hud_open"},
			{"id": "zero_point", "title": "⚡ 하위 공간 제로포인트 에너지 캡시터", "toggle_func": "toggle_zero_point_hud", "metrics_func": "calculate_zero_point_energy_metrics", "open_var": "is_zero_point_hud_open"},
			{"id": "nanite_sanitation", "title": "🤖 분자 나노봇 자율 위생 소독 엔진", "toggle_func": "toggle_nanite_sanitation_hud", "metrics_func": "calculate_nanite_sanitation_metrics", "open_var": "is_nanite_sanitation_hud_open"},
			{"id": "superconductive_power", "title": "⚡ 초전도 제로-저항 전력 그리드", "toggle_func": "toggle_superconductive_power_hud", "metrics_func": "calculate_superconductive_power_metrics", "open_var": "is_superconductive_power_hud_open"},
			{"id": "biophotonic_air", "title": "🌿 바이오-광학 퀀텀 태양광 광합성 공기재생기", "toggle_func": "toggle_biophotonic_air_hud", "metrics_func": "calculate_biophotonic_air_metrics", "open_var": "is_biophotonic_air_hud_open"},
			{"id": "photonic_power", "title": "⚡ 자율 초전도 포토닉 레이저 무선 전력 전송 네트워크", "toggle_func": "toggle_photonic_power_hud", "metrics_func": "calculate_photonic_power_metrics", "open_var": "is_photonic_power_hud_open"},
			{"id": "dark_energy_converter", "title": "🌌 자율 아원자 다크매터 암흑에너지 차원 전환기", "toggle_func": "toggle_dark_energy_converter_hud", "metrics_func": "calculate_dark_energy_converter_metrics", "open_var": "is_dark_energy_converter_hud_open"}
		]
	},
	{
		"category": "🌌 시공간 & 물리학",
		"items": [
			{"id": "tesseract", "title": "🌀 4차원 테서랙트 웜홀 공간확장", "toggle_func": "toggle_tesseract_hud", "metrics_func": "calculate_tesseract_expansion_metrics", "open_var": "is_tesseract_hud_open"},
			{"id": "tachyon", "title": "⏳ 타키온 초시공간 시간가속", "toggle_func": "toggle_tachyon_hud", "metrics_func": "calculate_tachyon_chrono_metrics", "open_var": "is_tachyon_hud_open"},
			{"id": "grav", "title": "🌌 중력파 위상 상쇄 무소음", "toggle_func": "toggle_grav_acoustic_hud", "metrics_func": "calculate_gravitational_acoustic_metrics", "open_var": "is_grav_acoustic_hud_open"},
			{"id": "teleport", "title": "🌀 양자 텔레포트 모듈", "toggle_func": "toggle_teleport_hud", "metrics_func": "calculate_teleportation_metrics", "open_var": "is_teleport_hud_open"},
			{"id": "multiverse", "title": "🌌 하위 퀀텀 다중우주 차원분기 포탈", "toggle_func": "toggle_multiverse_hud", "metrics_func": "calculate_multiverse_bifurcation_metrics", "open_var": "is_multiverse_hud_open"},
			{"id": "chrono_res", "title": "⌛ 크로노 필드 양자 공명 변환기", "toggle_func": "toggle_chrono_resonance_hud", "metrics_func": "calculate_chrono_resonance_metrics", "open_var": "is_chrono_resonance_hud_open"},
			{"id": "acoustic_damping", "title": "🔇 홀로그램 공간-음향 능동 공명 감쇠기", "toggle_func": "toggle_acoustic_damping_hud", "metrics_func": "calculate_acoustic_damping_metrics", "open_var": "is_acoustic_damping_hud_open"},
			{"id": "quantum_gravity", "title": "🌌 양자 얽힘 대기권-하위 중력장 안정화 엔진", "toggle_func": "toggle_quantum_gravity_hud", "metrics_func": "calculate_quantum_gravity_metrics", "open_var": "is_quantum_gravity_hud_open"},
			{"id": "dark_matter_gravity", "title": "🌌 아원자 다크매터 제로포인트 중력편향 엔진", "toggle_func": "toggle_dark_matter_gravity_hud", "metrics_func": "calculate_dark_matter_gravity_metrics", "open_var": "is_dark_matter_gravity_hud_open"},
			{"id": "chrono_dilation", "title": "⏳ 자율 아원자 퀀텀-시간지연 크로노 필드 안정기", "toggle_func": "toggle_chrono_dilation_hud", "metrics_func": "calculate_chrono_dilation_metrics", "open_var": "is_chrono_dilation_hud_open"},
			{"id": "singularity_power", "title": "🌌 자율 초전도 퀀텀 싱귤래리티 사건의지평선 중력우물 발전소", "toggle_func": "toggle_singularity_power_hud", "metrics_func": "calculate_singularity_power_metrics", "open_var": "is_singularity_power_hud_open"}
		]
	},
	{
		"category": "🧠 AI & 뇌파 바이오",
		"items": [
			{"id": "supercomputer", "title": "💻 홀로그램 슈퍼컴퓨터 AI", "toggle_func": "toggle_supercomputer_hud", "metrics_func": "calculate_holographic_supercomputer_metrics", "open_var": "is_supercomputer_hud_open"},
			{"id": "telepathic", "title": "🧠 텔레파시 신경 시냅스 다운로드", "toggle_func": "toggle_telepathic_hud", "metrics_func": "calculate_neural_telepathic_metrics", "open_var": "is_telepathic_hud_open"},
			{"id": "olfactory", "title": "🌿 피톤치드 공간 후각 디퓨저", "toggle_func": "toggle_olfactory_hud", "metrics_func": "calculate_olfactory_synthesizer_metrics", "open_var": "is_olfactory_hud_open"},
			{"id": "curriculum", "title": "🎓 퀀텀 AI 맞춤 커리큘럼", "toggle_func": "toggle_curriculum_hud", "metrics_func": "calculate_quantum_curriculum_metrics", "open_var": "is_curriculum_hud_open"},
			{"id": "biometric", "title": "🫀 생체맥박 맞춤 사운드스케이프", "toggle_func": "toggle_biometric_hud", "metrics_func": "calculate_biometric_pulse_metrics", "open_var": "is_biometric_hud_open"},
			{"id": "neural_cog", "title": "🧠 양자 AI 신경-시냅스 인지 가속기", "toggle_func": "toggle_neural_cognitive_hud", "metrics_func": "calculate_neural_cognitive_metrics", "open_var": "is_neural_cognitive_hud_open"},
			{"id": "bio_rest", "title": "💤 자율 서카디안 신경휴식 캡슐", "toggle_func": "toggle_bio_rest_hud", "metrics_func": "calculate_bio_rest_metrics", "open_var": "is_bio_rest_hud_open"},
			{"id": "memory_crystal", "title": "💎 신경-메모리 결정체 지식 합성기", "toggle_func": "toggle_memory_crystal_hud", "metrics_func": "calculate_memory_crystal_metrics", "open_var": "is_memory_crystal_hud_open"},
			{"id": "peptide_stimulator", "title": "🧬 바이오-다이내믹 아원자 펩타이드 신경-자극기", "toggle_func": "toggle_peptide_stimulator_hud", "metrics_func": "calculate_peptide_stimulator_metrics", "open_var": "is_peptide_stimulator_hud_open"},
			{"id": "neural_crystallizer", "title": "💎 자율 바이오-시냅스 신경-패턴 인지 기억 결정체화 엔진", "toggle_func": "toggle_neural_crystallizer_hud", "metrics_func": "calculate_neural_crystallizer_metrics", "open_var": "is_neural_crystallizer_hud_open"},
			{"id": "transmutation_reactor", "title": "⚛️ 자율 바이오-포토닉 신경-공명 기억-결정체 변무테이션 리액터", "toggle_func": "toggle_transmutation_reactor_hud", "metrics_func": "calculate_transmutation_reactor_metrics", "open_var": "is_transmutation_reactor_hud_open"}
		]
	},
	{
		"category": "💎 경영 & 글로벌 네트워크",
		"items": [
			{"id": "treasury", "title": "💎 양자 블록체인 정산", "toggle_func": "toggle_treasury_hud", "metrics_func": "calculate_quantum_treasury_metrics", "open_var": "is_treasury_hud_open"},
			{"id": "satellite", "title": "🛰️ 초고속 위성 네트워크", "toggle_func": "toggle_satellite_hud", "metrics_func": "calculate_satellite_network_metrics", "open_var": "is_satellite_hud_open"},
			{"id": "cryo", "title": "❄️ 극저온 액체질소 로스팅", "toggle_func": "toggle_cryo_hud", "metrics_func": "calculate_cryogenic_roaster_metrics", "open_var": "is_cryo_hud_open"},
			{"id": "exoskeleton", "title": "🦾 자율 체형교정 외골격", "toggle_func": "toggle_exoskeleton_hud", "metrics_func": "calculate_exoskeleton_metrics", "open_var": "is_exoskeleton_hud_open"},
			{"id": "water_gen", "title": "💧 대기 수자원 생성기", "toggle_func": "toggle_water_gen_hud", "metrics_func": "calculate_water_generator_metrics", "open_var": "is_water_gen_hud_open"},
			{"id": "satellite_mesh", "title": "🛰️ 글로벌 퀀텀-메쉬 위성 네트워크", "toggle_func": "toggle_satellite_mesh_hud", "metrics_func": "calculate_satellite_mesh_metrics", "open_var": "is_satellite_mesh_hud_open"},
			{"id": "cryo_roaster", "title": "❄️ 극저온 퀀텀-액체질소 영하-로스팅 합성기", "toggle_func": "toggle_cryo_roaster_hud", "metrics_func": "calculate_cryo_roaster_metrics", "open_var": "is_cryo_roaster_hud_open"},
			{"id": "exoskeleton_corrector", "title": "🦾 자율 바이오-로보틱 생체역학 외골격 체형교정기", "toggle_func": "toggle_exoskeleton_corrector_hud", "metrics_func": "calculate_exoskeleton_corrector_metrics", "open_var": "is_exoskeleton_corrector_hud_open"},
			{"id": "atmospheric_water", "title": "💧 자율 대기 수자원 응축 순수 생성기", "toggle_func": "toggle_nano_atmospheric_water_hud", "metrics_func": "calculate_nano_atmospheric_water_metrics", "open_var": "is_nano_atmospheric_water_hud_open"},
			{"id": "aeroponic_botanical", "title": "🌿 자율 에어로포닉 수직 식물원 영양-안개 분사기", "toggle_func": "toggle_aeroponic_botanical_hud", "metrics_func": "calculate_aeroponic_botanical_metrics", "open_var": "is_aeroponic_botanical_hud_open"},
			{"id": "maglev_floor", "title": "🧲 자율 초전도 자기장 양자 부유 바닥 매트릭스", "toggle_func": "toggle_maglev_floor_hud", "metrics_func": "calculate_maglev_floor_metrics", "open_var": "is_maglev_floor_hud_open"},
			{"id": "franchise_ledger", "title": "🌐 자율 글로벌 퀀텀 얽힘 프랜차이즈 가맹 원장 노드 리레이", "toggle_func": "toggle_franchise_ledger_hud", "metrics_func": "calculate_franchise_ledger_metrics", "open_var": "is_franchise_ledger_hud_open"}
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
	title_lbl.text = "🔬 첨단기술 관제 센터 (Tech Operations Center)"
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
	sub_lbl.text = "매장에 구축된 17개 첨단 서브시스템의 가동 상태를 실시간 모니터링하고 HUD 패널을 제어합니다."
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
		grid.columns = 2
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
