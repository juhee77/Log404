extends VBoxContainer
class_name ReportPanel

signal submit_requested(culprit: String, motive: String, method: String)

@onready var hint_label: Label = $HintLabel
@onready var culprit_input: LineEdit = $CulpritInput
@onready var motive_input: LineEdit = $MotiveInput
@onready var method_input: LineEdit = $MethodInput
@onready var submit_button: Button = $SubmitButton
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
    submit_button.pressed.connect(_on_submit_pressed)

func set_submit_enabled(enabled: bool) -> void:
    submit_button.disabled = not enabled
    hint_label.text = "모든 핵심 단서가 확보되었습니다. 범인 / 동기 / 방법을 입력해 보고서를 제출하세요." if enabled else "아직 보고서를 제출할 수 없습니다. 단서를 더 확보해야 합니다."

func set_status_text(message: String) -> void:
    status_label.text = message

func clear_status() -> void:
    status_label.text = ""

func _on_submit_pressed() -> void:
    submit_requested.emit(culprit_input.text, motive_input.text, method_input.text)
