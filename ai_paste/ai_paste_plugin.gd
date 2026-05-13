@tool
extends EditorPlugin

var dock: Control

func _enter_tree() -> void:
 var scene = load("res://addons/ai_paste/ai_paste_dock.tscn")
 dock = scene.instantiate()
 dock.editor_interface = EditorInterface
 add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree() -> void:
 if dock:
  remove_control_from_docks(dock)
  dock.queue_free()
