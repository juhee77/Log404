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
var diary_signature: String = "✍️ 주희의 서재"
var possession_state: String = "📦 소장중"
var purchase_date: String = ""
var custom_tag: String = "#소장각"
var favorite_character: String = "🌟 최애 캐릭터"
var condition_grade: String = "✨ S급(최상)"
var cover_finish: String = "📜 무광 매트"
var reading_weather: String = "☀️ 맑은 오후"
var reading_spot: String = "🛋️ 이불 속"
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

func _step_preset(presets: Array, current_val: String, step: int) -> String:
	var idx = presets.find(current_val)
	if idx == -1:
		return presets[0]
	return presets[(idx + step + presets.size()) % presets.size()]

func cycle_deco_sticker(step: int = 1) -> String:
	const PRESETS = ["✨", "🌸", "☕", "🌙", "🍀", "🎧"]
	deco_sticker = _step_preset(PRESETS, deco_sticker, step)
	updated_at = int(Time.get_unix_time_from_system())
	return deco_sticker

func cycle_rarity_tier(step: int = 1) -> String:
	const PRESETS = ["🌟노말", "💎레어", "👑슈퍼레어", "🔮시크릿"]
	rarity_tier = _step_preset(PRESETS, rarity_tier, step)
	updated_at = int(Time.get_unix_time_from_system())
	return rarity_tier

func cycle_paper_pattern(step: int = 1) -> String:
	const PRESETS = ["ruled", "grid", "blank", "vintage"]
	paper_pattern = _step_preset(PRESETS, paper_pattern, step)
	updated_at = int(Time.get_unix_time_from_system())
	return paper_pattern

func cycle_storage_location(step: int = 1) -> String:
	const PRESETS = ["🗄️ 1층 장식장", "📦 아크릴함", "📚 책상 선반", "🎒 외출 파우치"]
	storage_location = _step_preset(PRESETS, storage_location, step)
	updated_at = int(Time.get_unix_time_from_system())
	return storage_location

func cycle_acquisition_source(step: int = 1) -> String:
	const PRESETS = ["🏪 오프라인 서점", "🇯🇵 직구/해외", "🎁 선물", "🎪 팝업/행사", "📦 온라인 서점"]
	acquisition_source = _step_preset(PRESETS, acquisition_source, step)
	updated_at = int(Time.get_unix_time_from_system())
	return acquisition_source

func cycle_reading_mood(step: int = 1) -> String:
	const PRESETS = ["🥰 힐링", "🔥 열혈", "😭 감동", "🤯 반전", "🤣 유쾌"]
	reading_mood = _step_preset(PRESETS, reading_mood, step)
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

func cycle_diary_signature(step: int = 1) -> String:
	const PRESETS = ["✍️ 주희의 서재", "🌙 밤독서 기록", "☕ 카페 다꾸", "🎁 소장 기념"]
	diary_signature = _step_preset(PRESETS, diary_signature, step)
	updated_at = int(Time.get_unix_time_from_system())
	return diary_signature

func cycle_possession_state(step: int = 1) -> String:
	const PRESETS = ["📦 소장중", "🛒 예약중", "🚚 배송중", "✨ 전시중"]
	possession_state = _step_preset(PRESETS, possession_state, step)
	updated_at = int(Time.get_unix_time_from_system())
	return possession_state

func stamp_purchase_date() -> String:
	var dt = Time.get_date_dict_from_system()
	purchase_date = "📅 %02d.%02d" % [int(dt.get("month", 11)), int(dt.get("day", 15))]
	updated_at = int(Time.get_unix_time_from_system())
	return purchase_date

func cycle_custom_tag(step: int = 1) -> String:
	const PRESETS = ["#소장각", "#인생만화", "#힐링타임", "#전시필수", "#한정특전"]
	custom_tag = _step_preset(PRESETS, custom_tag, step)
	updated_at = int(Time.get_unix_time_from_system())
	return custom_tag

func cycle_favorite_character(step: int = 1) -> String:
	const PRESETS = ["🌟 최애 캐릭터", "🏀 강백호", "🧙‍♀️ 프리렌", "🐾 치이카와", "🏐 히나타", "🌸 체리"]
	favorite_character = _step_preset(PRESETS, favorite_character, step)
	updated_at = int(Time.get_unix_time_from_system())
	return favorite_character

func cycle_condition_grade(step: int = 1) -> String:
	const PRESETS = ["✨ S급(최상)", "📖 A급(양호)", "🏷️ B급(사용감)", "📦 미개봉(새상품)"]
	condition_grade = _step_preset(PRESETS, condition_grade, step)
	updated_at = int(Time.get_unix_time_from_system())
	return condition_grade

func cycle_cover_finish(step: int = 1) -> String:
	const PRESETS = ["📜 무광 매트", "✨ 유광 코팅", "🌟 홀로그램", "🧶 패브릭 양장"]
	cover_finish = _step_preset(PRESETS, cover_finish, step)
	updated_at = int(Time.get_unix_time_from_system())
	return cover_finish

func cycle_reading_weather(step: int = 1) -> String:
	const PRESETS = ["☀️ 맑은 오후", "🌧️ 비 오는 밤", "❄️ 눈 내리는 창가", "🌙 새벽 감성"]
	reading_weather = _step_preset(PRESETS, reading_weather, step)
	updated_at = int(Time.get_unix_time_from_system())
	return reading_weather

func cycle_reading_spot(step: int = 1) -> String:
	const PRESETS = ["🛋️ 이불 속", "☕ 북카페", "🪑 내 방 책상", "🚃 출퇴근길"]
	reading_spot = _step_preset(PRESETS, reading_spot, step)
	updated_at = int(Time.get_unix_time_from_system())
	return reading_spot

func get_item_value() -> int:
	var qty = maxi(1, duplicate_count)
	if estimated_value > 0:
		return estimated_value * qty
	if category == 0:
		return maxi(1, volumes.size()) * 7000 * qty
	return 5000 * qty

func boost_estimated_value(step: int = 5000) -> int:
	if estimated_value <= 0:
		var base_unit = maxi(1, volumes.size()) * 7000 if category == 0 else 5000
		estimated_value = base_unit + step
	else:
		estimated_value += step
	updated_at = int(Time.get_unix_time_from_system())
	return get_item_value()

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
		"diary_signature": diary_signature,
		"possession_state": possession_state,
		"purchase_date": purchase_date,
		"custom_tag": custom_tag,
		"favorite_character": favorite_character,
		"condition_grade": condition_grade,
		"cover_finish": cover_finish,
		"reading_weather": reading_weather,
		"reading_spot": reading_spot,
		"updated_at": updated_at,
		"volumes": volumes
	}
