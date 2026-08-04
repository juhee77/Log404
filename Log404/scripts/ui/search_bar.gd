extends HBoxContainer
class_name SearchBar

signal search_requested(keyword: String)
signal reset_requested
signal save_requested
signal load_requested

@onready var search_input: LineEdit = $SearchInput
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
    $SearchButton.pressed.connect(_on_search_pressed)
    $ResetButton.pressed.connect(func() -> void: reset_requested.emit())
    $SaveButton.pressed.connect(func() -> void: save_requested.emit())
    $LoadButton.pressed.connect(func() -> void: load_requested.emit())
    search_input.text_submitted.connect(func(_text: String) -> void: _on_search_pressed())

func get_search_text() -> String:
    return search_input.text

func clear_search() -> void:
    search_input.text = ""

func set_status(message: String) -> void:
    status_label.text = message

func _on_search_pressed() -> void:
    search_requested.emit(search_input.text)
