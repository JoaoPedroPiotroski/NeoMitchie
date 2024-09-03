extends Node2D

@onready var text: RichTextLabel = $Text

func _find_position() -> void:
	var camera : Camera2D = get_viewport().get_camera_2d()
	var camera_pos = camera.global_position
	#print(global_position)
	#print(camera_pos)
	if global_position.x < camera_pos.x:
		if global_position.y < camera_pos.y:
			text.position = Vector2(0, text.size.y)
			#text.set_anchors_preset(Control.PRESET_TOP_LEFT)
		elif global_position.y > camera_pos.y:
			text.position = Vector2(0, -text.size.y)
			#text.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	elif global_position.x > camera_pos.x:
		if global_position.y < camera_pos.y:
			text.position = Vector2(-text.size.x, text.size.y)
			#text.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		elif global_position.y > camera_pos.y:
			text.position = -text.size
			#text.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)

func _process(delta: float) -> void:
	_find_position()
