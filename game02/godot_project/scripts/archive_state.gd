extends RefCounted

const CollectionItemClass = preload("res://scripts/collection_item.gd")

var items: Array = []
var selected_item = null
var current_filter: int = -1
var current_theme: String = "clean_white"

const SAVE_FILE_PATH = "user://archive_data_v2.json"

const WEB_PRESET_CATALOG = [
	{"title": "더 퍼스트 슬램덩크 리소스", "author": "이노우에 다케히코", "tag": "초판특전", "color": "#dc2626", "icon": "🏀", "obi": "★ 극장판 비하인드 스토리 수록!"},
	{"title": "체인소 맨 버디 스토리즈", "author": "후지모토 타츠키", "tag": "초판소장", "color": "#ea580c", "icon": "⚔️", "obi": "★ 초판 한정 포치타 일러스트 카드"},
	{"title": "주술회전 공식 팬북", "author": "아쿠타미 게게", "tag": "한정판", "color": "#4f46e5", "icon": "⚡", "obi": "★ 캐릭터 비공개 설정 완벽 해부"},
	{"title": "나나 (NANA) 애장판", "author": "야자와 아이", "tag": "인생최애", "color": "#db2777", "icon": "🍓", "obi": "★ 707호실의 두 나나 특별 화보"},
]

func initialize_defaults() -> void:
	if not load_from_file():
		reset_to_rich_defaults()

func reset_to_rich_defaults() -> void:
	items.clear()

	# 1. 슬램덩크
	var m1 = CollectionItemClass.new("m1", 0, "슬램덩크 신장재편판", "이노우에 다케히코", "전권완결", "#e11d48", "🏀", "★ 전20권 완결 박스세트")
	m1.memo = "인생 최고의 농구 만화. 일러스트 표지 신장재편판"
	m1.add_volume(1, "first", 5, "농구... 좋아하세요?")
	m1.add_volume(2, "owned", 5, "리바운드를 제압하는 자가 시합을 제압한다")
	m1.add_volume(3, "first", 5, "포기하면 그 순간이 바로 시합 종료예요")
	items.append(m1)

	# 2. 장송의 프리렌
	var m2 = CollectionItemClass.new("m2", 0, "장송의 프리렌", "야마다 카네히토", "초판특전", "#0284c7", "🪄", "★ 초판 투명 북마크 동봉")
	m2.memo = "용사 힘멜 사후의 시간을 그리는 감성 판타지"
	m2.add_volume(1, "first", 5, "힘멜이라면 그렇게 했을 거야")
	m2.add_volume(2, "first", 5, "단 10년 함께했을 뿐인데")
	m2.add_volume(3, "owned", 5, "")
	items.append(m2)

	# 3. 치이카와 가챠
	var g1 = CollectionItemClass.new("g1", 1, "치이카와 캡슐 피규어", "반다이 가샤폰", "시크릿", "#ec4899", "🐱", "★ 아크릴 케이스 전시중")
	g1.memo = "국전 가챠샵에서 단번에 뽑은 행운의 피규어!"
	items.append(g1)

	# 4. 하이큐 파이널
	var m3 = CollectionItemClass.new("m3", 0, "하이큐!! 파이널 가이드", "후루다테 하루이치", "전권완결", "#ea580c", "🏐", "★ 쓰레기장의 결전 기념판")
	m3.memo = "배구 만화의 정점"
	m3.add_volume(1, "first", 5, "날아라 카라스노!")
	m3.add_volume(2, "owned", 5, "")
	items.append(m3)

	# 5. 카드캡터 체리 애장판
	var m4 = CollectionItemClass.new("m4", 0, "카드캡터 체리 애장판", "CLAMP", "인생최애", "#f43f5e", "🌸", "★ 크로우카드 일러스트 수록")
	m4.memo = "영롱한 금박 테두리 애장판"
	m4.add_volume(1, "first", 5, "봉인해제(릴리즈)!")
	m4.add_volume(2, "first", 5, "절대 괜찮을 거야")
	items.append(m4)

	# 6. 주희의 커스텀 마법서
	var g2 = CollectionItemClass.new("g2", 1, "루나 요술봉 아크릴 가챠", "한정판 캡슐 토이", "SSR한정", "#7c3aed", "🌙", "★ 카메라 실물 촬영 등록")
	g2.memo = "책상 위 아크릴 스탠드 보물 1호"
	items.append(g2)

	if items.size() > 0:
		selected_item = items[0]

func get_item_by_id(item_id: String):
	for it in items:
		if it.id == item_id:
			return it
	return null

func get_filtered_items(filter_cat: int = -1, query: String = "") -> Array:
	var result: Array = []
	var q = query.strip_edges().to_lower()
	for it in items:
		var cat_match = (filter_cat == -1 or it.category == filter_cat)
		var query_match = q.is_empty() or it.title.to_lower().contains(q) or it.author_or_series.to_lower().contains(q) or it.memo.to_lower().contains(q) or it.status_tag.to_lower().contains(q)
		if not query_match and it.volumes.size() > 0:
			for v in it.volumes:
				if str(v.get("quote", "")).to_lower().contains(q):
					query_match = true
					break
		if cat_match and query_match:
			result.append(it)
	return result

func add_item(
	p_title: String,
	p_cat: int,
	p_author: String = "",
	p_color: String = "#4f46e5",
	p_icon: String = "📖",
	p_obi: String = "★ 신규 소장 등록!",
	p_tag: String = "소장중"
):
	var new_id = "item_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000)
	var default_icon = p_icon if p_icon != "" else ("📖" if p_cat == 0 else "🔮")
	var item = CollectionItemClass.new(new_id, p_cat, p_title, p_author, p_tag, p_color, default_icon, p_obi)
	if p_cat == 0:
		item.add_volume(1, "first", 5, "")
	items.insert(0, item)
	selected_item = item
	save_to_file()
	return item

func scrape_web_preset(preset_idx: int):
	var idx = clampi(preset_idx, 0, WEB_PRESET_CATALOG.size() - 1)
	var p = WEB_PRESET_CATALOG[idx]
	return add_item(p["title"], 0, p["author"], p["color"], p["icon"], p["obi"], p["tag"])

func remove_item(p_id: String) -> void:
	for i in range(items.size()):
		if items[i].id == p_id:
			items.remove_at(i)
			break
	if items.size() > 0:
		selected_item = items[0]
	else:
		selected_item = null
	save_to_file()

func get_total_volumes() -> int:
	var total = 0
	for it in items:
		if it.category == 0:
			total += it.volumes.size()
	return total

func get_first_editions_count() -> int:
	var count = 0
	for it in items:
		for v in it.volumes:
			if v.get("status", "") == "first":
				count += 1
	return count

func save_to_file(custom_path: String = "") -> bool:
	var target_path = custom_path if custom_path != "" else SAVE_FILE_PATH
	var file = FileAccess.open(target_path, FileAccess.WRITE)
	if not file:
		return false
	
	var data_array: Array = []
	for it in items:
		data_array.append(it.to_dict())
	
	var json_str = JSON.stringify(data_array, "  ")
	file.store_string(json_str)
	file.close()
	return true

func load_from_file(custom_path: String = "") -> bool:
	var target_path = custom_path if custom_path != "" else SAVE_FILE_PATH
	if not FileAccess.file_exists(target_path):
		return false
	
	var file = FileAccess.open(target_path, FileAccess.READ)
	if not file:
		return false
	
	var json_str = file.get_as_text()
	file.close()
	
	var parsed = JSON.parse_string(json_str)
	if typeof(parsed) != TYPE_ARRAY or parsed.is_empty():
		return false
	
	items.clear()
	for d in parsed:
		if typeof(d) == TYPE_DICTIONARY:
			var it = CollectionItemClass.new(
				d.get("id", ""),
				d.get("category", 0),
				d.get("title", ""),
				d.get("author_or_series", ""),
				d.get("status_tag", "소장중"),
				d.get("cover_color", "#4f46e5"),
				d.get("icon_emoji", "📖"),
				d.get("obi_text", "")
			)
			it.memo = d.get("memo", "")
			it.cover_path = d.get("cover_path", "")
			it.template_name = d.get("template_name", "COMICS")
			it.volumes = d.get("volumes", [])
			items.append(it)
	
	return items.size() > 0
