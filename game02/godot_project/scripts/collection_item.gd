extends RefCounted

enum Category { MANGA, GACHA, GOODS }

var id: String = ""
var category: int = Category.MANGA
var title: String = ""
var author_or_series: String = ""
var status_tag: String = "소장중"
var memo: String = ""
var cover_path: String = ""
var volumes: Array = []

func _init(p_id: String = "", p_cat: int = 0, p_title: String = "", p_author: String = "", p_tag: String = "소장중") -> void:
	id = p_id
	category = p_cat
	title = p_title
	author_or_series = p_author
	status_tag = p_tag

func add_volume(p_vol: int, p_status: String = "owned", p_rating: int = 5, p_quote: String = "") -> void:
	volumes.append({
		"vol": p_vol,
		"status": p_status,
		"rating": p_rating,
		"quote": p_quote
	})

func to_dict() -> Dictionary:
	return {
		"id": id,
		"category": category,
		"title": title,
		"author_or_series": author_or_series,
		"status_tag": status_tag,
		"memo": memo,
		"cover_path": cover_path,
		"volumes": volumes
	}
