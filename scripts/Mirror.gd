extends Sprite2D

const MIRRORED_SPRITE_MAT = preload("res://assets/materials/mirrored_sprite_mat.tres")

@export var sprites_offset := Vector2(5	, 0)

# Bodies take a body as key, they point to an array with 2 values
# This array always has [0] as the sprite in the body
# And [1] as the sprite stored here
var bodies = {}

@onready var mirrored_sprites = $MirroredSprites

func _process(delta):
	for body in bodies.keys():
		var curr_sprite_offset = sprites_offset * int(body.get('look_dir'))
		
		bodies[body][1].texture = bodies[body][0].texture
		bodies[body][1].flip_h = bodies[body][0].flip_h
		bodies[body][1].flip_v = bodies[body][0].flip_v
		bodies[body][1].centered = bodies[body][0].centered
		bodies[body][1].hframes = bodies[body][0].hframes
		bodies[body][1].vframes = bodies[body][0].vframes
		bodies[body][1].frame = bodies[body][0].frame
		bodies[body][1].global_position = bodies[body][0].global_position + curr_sprite_offset
		bodies[body][1].scale = bodies[body][0].scale

func _on_mirror_area_body_entered(body):
	if body.has_node("Sprite"):
		if not body in bodies.keys():
			
			var bs = body.get_node("Sprite")
			var ns = Sprite2D.new()
			ns.material = MIRRORED_SPRITE_MAT
			ns.modulate.a = 0.5
			mirrored_sprites.add_child(ns)
			bodies[body] = [bs, ns]
			bodies[body][1].texture = bodies[body][0].texture
			bodies[body][1].flip_h = bodies[body][0].flip_h
			bodies[body][1].flip_v = bodies[body][0].flip_v
			bodies[body][1].centered = bodies[body][0].centered
			bodies[body][1].hframes = bodies[body][0].hframes
			bodies[body][1].vframes = bodies[body][0].vframes
			bodies[body][1].frame = bodies[body][0].frame
			bodies[body][1].global_position = bodies[body][0].global_position + sprites_offset
			bodies[body][1].scale = bodies[body][0].scale
			



func _on_mirror_area_body_exited(body):
	if body in bodies.keys():
		bodies[body][1].queue_free()
		bodies.erase(body)
