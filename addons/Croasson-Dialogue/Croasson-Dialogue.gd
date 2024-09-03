@tool
extends EditorPlugin

const DialogueManager = "res://addons/Croasson-Dialogue/scripts/dialogue_manager.gd"
const MAIN_SCENE = preload("res://addons/Croasson-Dialogue/main_scene.tscn")

var main_scene_instance

func _enter_tree() -> void:
	add_autoload_singleton("DialogueManager", DialogueManager)
	main_scene_instance = MAIN_SCENE.instantiate()
	EditorInterface.get_editor_main_screen().add_child(main_scene_instance)
	_make_visible(false)
	
func _has_main_screen() -> bool:
	return true
	
func _make_visible(visible: bool) -> void:
	if main_scene_instance:
		main_scene_instance.visible = visible

func _get_plugin_name() -> String:
	return "Croasson Dialogue"

func _exit_tree() -> void:
	remove_autoload_singleton("DialogueManager")
	if main_scene_instance:
		main_scene_instance.queue_free()


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
