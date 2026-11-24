extends Node

signal inventory_changed(items: Array[String])
signal selection_changed(selected_id: String)
signal flag_changed(flag_name: String, value: bool)
signal dialogue_requested(speaker: String, text: String)

const ITEM_CATALOG: Dictionary = {
	"ticket_left": {
		"name": "찢어진 승차권 (좌)",
		"symbol": "🎫L",
		"desc": "승차권의 왼쪽 조각. 좌석 번호 '404'라고 적혀 있다."
	},
	"ticket_right": {
		"name": "찢어진 승차권 (우)",
		"symbol": "🎫R",
		"desc": "승차권의 오른쪽 조각. 목적지 칸은 별빛 잉크로 지워져 있다."
	},
	"ticket_full": {
		"name": "복원된 승차권",
		"symbol": "✨🎫",
		"desc": "두 조각을 맞춘 승차권. [좌석 404 / 목적지: ???]"
	},
	"brass_key": {
		"name": "황동 태엽 열쇠",
		"symbol": "🔑",
		"desc": "작은 부엉이 문양이 새겨진 정교한 태엽 감기용 열쇠."
	}
}

var inventory: Array[String] = []
var selected_item_id: String = ""
var flags: Dictionary = {
	"coat_searched": false,
	"tick_joined": false,
	"mirror_wiped": false,
	"suitcase_opened": false,
	"validator_wound": false,
	"door_unlocked": false,
	"chapter_cleared": false
}


func reset_state() -> void:
	inventory = []
	selected_item_id = ""
	flags = {
		"coat_searched": false,
		"tick_joined": false,
		"mirror_wiped": false,
		"suitcase_opened": false,
		"validator_wound": false,
		"door_unlocked": false,
		"chapter_cleared": false
	}
	inventory_changed.emit(inventory.duplicate())
	selection_changed.emit(selected_item_id)


func has_flag(flag_name: String) -> bool:
	return bool(flags.get(flag_name, false))


func set_flag(flag_name: String, value: bool) -> void:
	if flags.get(flag_name) == value:
		return
	var next_flags: Dictionary = flags.duplicate()
	next_flags[flag_name] = value
	flags = next_flags
	flag_changed.emit(flag_name, value)


func has_item(item_id: String) -> bool:
	return inventory.has(item_id)


func add_item(item_id: String) -> void:
	if not ITEM_CATALOG.has(item_id) or inventory.has(item_id):
		return
	var next_inv: Array[String] = inventory.duplicate()
	next_inv.append(item_id)
	inventory = next_inv
	inventory_changed.emit(inventory.duplicate())


func remove_item(item_id: String) -> void:
	if not inventory.has(item_id):
		return
	var next_inv: Array[String] = inventory.duplicate()
	next_inv.erase(item_id)
	inventory = next_inv
	if selected_item_id == item_id:
		selected_item_id = ""
		selection_changed.emit(selected_item_id)
	inventory_changed.emit(inventory.duplicate())


func select_item(item_id: String) -> void:
	# 이미 선택된 아이템과 다른 승차권 조각을 클릭하면 자동 조합 시도
	if selected_item_id != "" and selected_item_id != item_id:
		if try_combine(selected_item_id, item_id):
			return

	if selected_item_id == item_id:
		selected_item_id = ""
	else:
		selected_item_id = item_id
	selection_changed.emit(selected_item_id)


func try_combine(item_a: String, item_b: String) -> bool:
	var pair: Array[String] = [item_a, item_b]
	pair.sort()
	if pair == ["ticket_left", "ticket_right"]:
		remove_item("ticket_left")
		remove_item("ticket_right")
		add_item("ticket_full")
		selected_item_id = "ticket_full"
		selection_changed.emit(selected_item_id)
		say("티크", "딱 맞아떨어졌어! 찢어진 승차권이 하나로 복원됐어. 그런데 목적지 칸이 비어 있네...?")
		return true
	return false


func get_item_info(item_id: String) -> Dictionary:
	return ITEM_CATALOG.get(item_id, {})


func say(speaker: String, text: String) -> void:
	dialogue_requested.emit(speaker, text)


func get_tick_hint() -> String:
	if not has_flag("tick_joined"):
		return ""
	if not has_flag("suitcase_opened"):
		if not has_flag("mirror_wiped"):
			return "침대 밑 가죽 가방에 3자리 자물쇠가 걸려 있어! 테이블 위 일지를 읽어보고, 창문·거울·시계에서 숫자를 찾아보자. 오른쪽 거울에 김이 서려 있던데?"
		return "좋아! 창밖 별자리(첫째), 닦아낸 거울(둘째), 멈춘 회중시계(셋째)의 숫자를 침대 밑 가방 자물쇠에 맞춰보자!"
	if has_item("ticket_left") and has_item("ticket_right"):
		return "승차권 조각이 두 개 다 모였어! 아래 가방(인벤토리)에서 한 조각을 선택한 다음 다른 조각을 눌러 합쳐볼까?"
	if not has_flag("validator_wound"):
		return "오른쪽 문 옆에 부엉이 모양 검표기가 있어! 인벤토리에서 [황동 태엽 열쇠]를 선택해 검표기를 눌러보자!"
	if not has_flag("door_unlocked"):
		return "검표기 태엽이 감겼어! 이제 [복원된 승차권]을 선택해서 검표기에 넣어보자!"
	return "5호차 문이 열렸어! 오른쪽 출구 문을 눌러 4호차로 건너가 보자!"
