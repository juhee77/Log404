extends VBoxContainer
class_name DocumentViewPanel

@onready var title_label: Label = $TitleLabel
@onready var meta_label: Label = $MetaLabel
@onready var content_label: RichTextLabel = $ContentText

func show_document(document_payload: Dictionary) -> void:
    if document_payload.is_empty():
        clear_view()
        return
    title_label.text = str(document_payload.get("title", "문서를 선택하세요"))
    meta_label.text = str(document_payload.get("meta", ""))
    content_label.text = str(document_payload.get("content", ""))

func clear_view() -> void:
    title_label.text = "문서를 선택하세요"
    meta_label.text = "좌측 목록에서 문서를 열면 내용이 표시됩니다."
    content_label.text = ""
