@tool
extends Control

var editor_interface: EditorInterface

@onready var status_label: Label  = $VBox/StatusBar/StatusLabel
@onready var paste_btn   : Button = $VBox/Buttons/PasteBtn

func _ready() -> void:
	paste_btn.pressed.connect(_on_paste_pressed)
	_set_status("Ready", false)

func _on_paste_pressed() -> void:
	var code := DisplayServer.clipboard_get()

	if code.is_empty():
		_set_status("⚠ Clipboard is empty", true)
		return

	if not editor_interface:
		_set_status("⚠ No editor_interface", true)
		return

	var current_editor := editor_interface.get_script_editor().get_current_editor()
	if not current_editor:
		_set_status("⚠ No script open", true)
		return

	var code_edit := current_editor.get_base_editor()
	code_edit.insert_text_at_caret(code)
	_set_status("✓ Done", false)

func _set_status(msg: String, is_error: bool) -> void:
	status_label.text     = msg
	status_label.modulate = Color.RED if is_error else Color.WHITE

