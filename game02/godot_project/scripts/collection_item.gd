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
	icon_emoji = p_icon
	obi_text = p_obi

func add_volume(p_vol: int, p_status: String = "owned", p_rating: int = 5, p_quote: String = "", p_date: String = "") -> void:
	var date_str = p_date
	if date_str == "":
		var d = Time.get_date_dict_from_system()
		date_str = "%04d.%02d.%02d" % [d.year, d.month, d.day]
	volumes.append({
		"vol": p_vol,
		"status": p_status,
		"rating": p_rating,
		"quote": p_quote,
		"date": date_str
	})

func get_average_rating() -> float:
	if volumes.is_empty():
		return 5.0
	var sum_r = 0.0
	for v in volumes:
		sum_r += float(v.get("rating", 5))
	return sum_r / float(volumes.size())

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
		"updated_at": updated_at,
		"volumes": volumes
	}
