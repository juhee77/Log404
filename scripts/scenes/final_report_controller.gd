extends Control
class_name FinalReportController

@onready var report_panel: ReportPanel = $Margin/VBox/ReportPanel
@onready var result_label: RichTextLabel = $Margin/VBox/ResultLabel

func _ready() -> void:
    report_panel.submit_requested.connect(_on_submit_requested)
    AppState.state_changed.connect(refresh_from_app_state)
    AppState.report_submitted.connect(_show_result)
    AppState.message_emitted.connect(_on_message_emitted)
    refresh_from_app_state()

func refresh_from_app_state() -> void:
    report_panel.set_submit_enabled(AppState.can_submit_report())
    report_panel.set_status_text(AppState.get_last_report_result())
    result_label.text = AppState.get_last_report_result()

func _on_submit_requested(culprit: String, motive: String, method: String) -> void:
    _show_result(AppState.submit_report(culprit, motive, method))

func _show_result(result: String) -> void:
    result_label.text = result

func _on_message_emitted(message: String, _level: String) -> void:
    if message.begins_with("["):
        result_label.text = message
