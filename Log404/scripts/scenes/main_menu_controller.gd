extends Control
class_name MainMenuController

signal start_requested

func _ready() -> void:
    $Center/Panel/VBox/StartButton.pressed.connect(func() -> void: start_requested.emit())
