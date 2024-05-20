extends RigidBody2D


func _ready():
	randomize()
	linear_velocity = Vector2(randf_range(-50, 50), -200)
