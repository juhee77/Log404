extends PanelContainer

# snack_restock_panel.gd - Interactive Snack Bar & Amenity Restock Minigame Panel

signal closed

@onready var label_stock: Label = $MarginContainer/VBoxContainer/StockBox/LabelStock
@onready var btn_fill_coffee: Button = $MarginContainer/VBoxContainer/ActionGrid/BtnFillCoffee
@onready var btn_fill_snack: Button = $MarginContainer/VBoxContainer/ActionGrid/BtnFillSnack
@onready var btn_fill_amenity: Button = $MarginContainer/VBoxContainer/ActionGrid/BtnFillAmenity
@onready var btn_close: Button = $MarginContainer/VBoxContainer/Header/BtnClose

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if btn_close:
		btn_close.pressed.connect(func(): hide(); closed.emit())
		
	if btn_fill_coffee:
		btn_fill_coffee.pressed.connect(func(): restock("coffee", 200.0))
	if btn_fill_snack:
		btn_fill_snack.pressed.connect(func(): restock("snack", 300.0))
	if btn_fill_amenity:
		btn_fill_amenity.pressed.connect(func(): restock("amenity", 250.0))
		
	update_view()

func restock(type: String, cost: float) -> void:
	if not GameState.can_afford(cost): return
	GameState.add_money(-cost)
	GameState.snack_stock = min(100, GameState.snack_stock + 30)
	GameState.reputation = min(5.0, GameState.reputation + 0.05)
	GameState.reputation_changed.emit(GameState.reputation)
	SoundManager.play_coin_sfx()
	update_view()

func update_view() -> void:
	if label_stock:
		label_stock.text = "🍫 스낵바 & 비품 재고율: %d%% (100%% 시 최대 만족도)" % GameState.snack_stock
