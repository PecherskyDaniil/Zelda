extends Node2D

@onready var map_vis=$Map
@onready var marker= $Marker
func _ready() -> void:
	map_vis.texture=load("res://world/level_structures/level1.png")
	GameManager.level_changed.connect(load_map)

func load_map(map):
	map_vis.texture=load(map)

func _process(delta: float) -> void:
	if GameManager.player_global_pos and map_vis:
		marker.position.x=GameManager.player_global_pos.x*(64/(map_vis.texture.get_size().x*16))-1.5
		marker.position.y=GameManager.player_global_pos.y*(64/(map_vis.texture.get_size().y*16))-1.5
