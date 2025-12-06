extends Node2D


@onready var player_scene = preload("res://player/Player.tscn")

func _ready():
	var player = player_scene.instantiate()
	GameManager._set_player(player)
	GameManager._set_world($world)
	GameManager._load_level()
	$world.add_child(player)
