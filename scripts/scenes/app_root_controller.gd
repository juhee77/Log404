extends Control
class_name AppRootController

@onready var main_menu: Control = $MainMenu
@onready var case_dashboard: Control = $CaseDashboard

func _ready() -> void:
    main_menu.start_requested.connect(_on_start_requested)
    case_dashboard.hide()

func _on_start_requested() -> void:
    main_menu.hide()
    case_dashboard.show()
    case_dashboard.prepare_session()
