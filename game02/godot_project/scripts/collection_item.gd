extends RefCounted

enum Category { MANGA, GACHA, GOODS }

var id: String = ""
var category: int = Category.MANGA
var title: String = ""
var author_or_series: String = ""
var status_tag: String = "소장중"
var memo: String = ""
var cover_path: String = ""
var cover_color: String = "#4f46e5"
var icon_emoji: String = "📖"
var obi_text: String = ""
var template_name: String = "COMICS"
var memo_ink_color: String = "#2c221e"
var highlight_enabled: bool = false
var pen_nib_size: int = 11
var washi_tape_color: String = "#f4d394"
var deco_sticker: String = "✨"
var rarity_tier: String = "🌟노말"
var paper_pattern: String = "ruled"
var storage_location: String = "🗄️ 1층 장식장"
var acquisition_source: String = "🏪 오프라인 서점"
var reading_mood: String = "🥰 힐링"
var target_volumes: int = 0
var reread_count: int = 1
var estimated_value: int = 0
var duplicate_count: int = 1
var updated_at: int = 0
var volumes: Array = []

func _init(
	p_id: String = "",
	p_cat: int = 0,
	p_title: String = "",
	p_author: String = "",
	p_tag: String = "소장중",
	p_color: String = "#4f46e5",
	p_icon: String = "📖",
	p_obi: String = ""
) -> void:
	id = p_id
	category = p_cat
	title = p_title
	author_or_series = p_author
	status_tag = p_tag
	cover_color = p_color
	icon_emoji = p_icon
	obi_text = p_obi
	updated_at = int(Time.get_unix_time_from_system())

func add_volume(p_vol: int, p_status: String = "owned", p_rating: int = 5, p_quote: String = "", p_date: String = "", p_bookmarked: bool = false) -> void:
	var date_str = p_date
	if date_str == "":
		var d = Time.get_date_dict_from_system()
		date_str = "%04d.%02d.%02d" % [d.year, d.month, d.day]
	volumes.append({
		"vol": p_vol,
		"status": p_status,
		"rating": p_rating,
		"quote": p_quote,
		"date": date_str,
		"bookmarked": p_bookmarked
	})

func get_bookmarked_volumes_count() -> int:
	var count = 0
	for v in volumes:
		if v.get("bookmarked", false):
			count += 1
	return count

func get_average_rating() -> float:
	if volumes.is_empty():
		return 5.0
	var sum_r = 0.0
	for v in volumes:
		sum_r += float(v.get("rating", 5))
	return sum_r / float(volumes.size())

func quick_advance_volume() -> int:
	var next_vol = volumes.size() + 1
	var d = Time.get_date_dict_from_system()
	var date_str = "%04d.%02d.%02d" % [d.year, d.month, d.day]
	volumes.append({
		"vol": next_vol,
		"status": "owned",
		"rating": 5,
		"quote": "%d권 독서 완료" % next_vol,
		"date": date_str,
		"bookmarked": false
	})
	updated_at = int(Time.get_unix_time_from_system())
	return next_vol

func cycle_deco_sticker() -> String:
	const PRESETS = ["✨", "🌸", "☕", "🌙", "🍀", "🎧"]
	var idx = PRESETS.find(deco_sticker)
	if idx == -1:
		deco_sticker = PRESETS[0]
	else:
		deco_sticker = PRESETS[(idx + 1) % PRESETS.size()]
	updated_at = int(Time.get_unix_time_from_system())
	return deco_sticker

func cycle_rarity_tier() -> String:
	const PRESETS = ["🌟노말", "💎레어", "👑슈퍼레어", "🔮시크릿"]
	var idx = PRESETS.find(rarity_tier)
	if idx == -1:
		rarity_tier = PRESETS[0]
	else:
		rarity_tier = PRESETS[(idx + 1) % PRESETS.size()]
	updated_at = int(Time.get_unix_time_from_system())
	return rarity_tier

func cycle_paper_pattern() -> String:
	const PRESETS = ["ruled", "grid", "blank", "vintage"]
	var idx = PRESETS.find(paper_pattern)
	if idx == -1:
		paper_pattern = PRESETS[0]
	else:
		paper_pattern = PRESETS[(idx + 1) % PRESETS.size()]
	updated_at = int(Time.get_unix_time_from_system())
	return paper_pattern

func cycle_storage_location() -> String:
	const PRESETS = ["🗄️ 1층 장식장", "📦 아크릴함", "📚 책상 선반", "🎒 외출 파우치"]
	var idx = PRESETS.find(storage_location)
	if idx == -1:
		storage_location = PRESETS[0]
	else:
		storage_location = PRESETS[(idx + 1) % PRESETS.size()]
	updated_at = int(Time.get_unix_time_from_system())
	return storage_location

func cycle_acquisition_source() -> String:
	const PRESETS = ["🏪 오프라인 서점", "🇯🇵 직구/해외", "🎁 선물", "🎪 팝업/행사", "📦 온라인 서점"]
	var idx = PRESETS.find(acquisition_source)
	if idx == -1:
		acquisition_source = PRESETS[0]
	else:
		acquisition_source = PRESETS[(idx + 1) % PRESETS.size()]
	updated_at = int(Time.get_unix_time_from_system())
	return acquisition_source

func cycle_reading_mood() -> String:
	const PRESETS = ["🥰 힐링", "🔥 열혈", "😭 감동", "🤯 반전", "🤣 유쾌"]
	var idx = PRESETS.find(reading_mood)
	if idx == -1:
		reading_mood = PRESETS[0]
	else:
		reading_mood = PRESETS[(idx + 1) % PRESETS.size()]
	updated_at = int(Time.get_unix_time_from_system())
	return reading_mood

func get_completion_percentage() -> float:
	if target_volumes > 0:
		return clampf(float(volumes.size()) / float(target_volumes) * 100.0, 5.0, 100.0)
	if status_tag == "전권완결" or status_tag == "완독":
		return 100.0
	if volumes.size() == 0:
		return 30.0
	return clampf(float(volumes.size()) * 25.0, 20.0, 100.0)

func increment_reread_count() -> int:
	reread_count += 1
	updated_at = int(Time.get_unix_time_from_system())
	return reread_count

func increment_duplicate_count() -> int:
	duplicate_count += 1
	updated_at = int(Time.get_unix_time_from_system())
	return duplicate_count

func get_item_value() -> int:
	var qty = maxi(1, duplicate_count)
	if estimated_value > 0:
		return estimated_value * qty
	if category == 0:
		return maxi(1, volumes.size()) * 7000 * qty
	return 5000 * qty

func to_dict() -> Dictionary:
	return {
		"id": id,
		"category": category,
		"title": title,
		"author_or_series": author_or_series,
		"status_tag": status_tag,
		"memo": memo,
		"cover_path": cover_path,
		"cover_color": cover_color,
		"icon_emoji": icon_emoji,
		"obi_text": obi_text,
		"template_name": template_name,
		"memo_ink_color": memo_ink_color,
		"highlight_enabled": highlight_enabled,
		"pen_nib_size": pen_nib_size,
		"washi_tape_color": washi_tape_color,
		"deco_sticker": deco_sticker,
		"rarity_tier": rarity_tier,
		"paper_pattern": paper_pattern,
		"storage_location": storage_location,
		"acquisition_source": acquisition_source,
		"reading_mood": reading_mood,
		"target_volumes": target_volumes,
		"reread_count": reread_count,
		"estimated_value": estimated_value,
		"duplicate_count": duplicate_count,
		"updated_at": updated_at,
		"volumes": volumes
	}
