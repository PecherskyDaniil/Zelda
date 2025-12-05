extends Area2D

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			body.get_damage(1)


	
