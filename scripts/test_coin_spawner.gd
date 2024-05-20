extends Node2D

func _on_timer_timeout():
	return
	for f in range(10):
		var c = load("res://scenes/coin.tscn")
		var i = c.instantiate()
		add_child(i)
		i.global_position = global_position
