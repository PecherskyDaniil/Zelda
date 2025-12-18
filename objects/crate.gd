extends StaticBody2D

@onready var items=[load("res://objects/healing_potion.tscn"),load("res://objects/heart.tscn")]

func get_hit(damage):
	queue_free()
	if randi_range(0,10)==0:
		var loot = items[randi_range(0, items.size()-1)].instantiate()
		loot.global_position=global_position
		GameManager.world.add_child(loot)
