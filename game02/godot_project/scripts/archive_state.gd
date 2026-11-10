extends RefCounted

const CollectionItemClass = preload("res://scripts/collection_item.gd")

var items: Array = []
var selected_item = null
var current_filter: int = -1

func initialize_defaults() -> void:
	items.clear()
	
	# Default Manga 1: 슬램덩크
	var m1 = CollectionItemClass.new("m1", 0, "슬램덩크 신장재편판", "이노우에 다케히코", "전권완결")
	m1.memo = "인생 최고의 농구 만화"
	m1.add_volume(1, "first", 5, "농구 좋아하세요?")
	m1.add_volume(2, "owned", 5, "리바운드를 제압하는 자가 시합을 제압한다")
	m1.add_volume(3, "first", 5, "포기하면 그 순간이 바로 시합 종료예요")
	items.append(m1)

	# Default Manga 2: 프리렌
	var m2 = CollectionItemClass.new("m2", 0, "장송의 프리렌", "야마다 카네히토", "연재중")
	m2.memo = "용사 사후의 시간을 그리는 감성 판타지"
	m2.add_volume(1, "first", 5, "힘멜이라면 그렇게 했을 거야")
	m2.add_volume(2, "owned", 4, "")
	items.append(m2)

	# Default Gacha 1: 치이카와
	var g1 = CollectionItemClass.new("g1", 1, "치이카와 캡슐 토이 피규어", "반다이 캡슐", "시크릿 획득")
	g1.memo = "국전 가챠샵에서 단번에 뽑은 행운의 피규어!"
	items.append(g1)

	if items.size() > 0:
		selected_item = items[0]

func get_filtered_items(filter_cat: int = -1, query: String = "") -> Array:
	var result: Array = []
	var q = query.strip_edges().to_lower()
	for it in items:
		var cat_match = (filter_cat == -1 or it.category == filter_cat)
		var query_match = (q.is_empty() or it.title.to_lower().contains(q) or it.author_or_series.to_lower().contains(q))
		if cat_match and query_match:
			result.append(it)
	return result

func add_item(p_title: String, p_cat: int, p_author: String = ""):
	var new_id = "item_" + str(Time.get_unix_time_from_system())
	var item = CollectionItemClass.new(new_id, p_cat, p_title, p_author)
	if p_cat == 0:
		item.add_volume(1, "owned", 5, "")
	items.insert(0, item)
	selected_item = item
	return item

func remove_item(p_id: String) -> void:
	for i in range(items.size()):
		if items[i].id == p_id:
			items.remove_at(i)
			break
	if items.size() > 0:
		selected_item = items[0]
	else:
		selected_item = null

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
