extends Node2D

@onready var level_generator = load("res://world/level_generator.gd")
@onready var tile_map: TileMapLayer = $floor_and_walls
@onready var objects_tile_map:TileMapLayer = $objects
var wall:Vector2i=Vector2i(14,0)
var floor:Vector2i=Vector2i(1,2)
var spawn_pos=Vector2(0,0)
@onready var teleport_scene:PackedScene = preload("res://objects/teleport.tscn")
func _ready() -> void:
	generate_random_level()

func generate_random_level() -> void:
	var level_files := []
	var dir := DirAccess.open("res://world/level_structures/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".png"):
				level_files.append("res://world/level_structures/" + file_name)
			file_name = dir.get_next()
	
	if level_files.size() > 0:
		var random_level = level_files[randi() % level_files.size()]
		var lg=level_generator.new()
		lg.generate_from_png(tile_map,objects_tile_map,random_level)
		var teleport=teleport_scene.instantiate()
		print(lg.get_teleport_pos())
		teleport.global_position=Vector2(lg.get_teleport_pos())
		spawn_pos=Vector2(lg.get_teleport_pos())
		add_child(teleport)

# Или через кнопку в UI
#func _on_generate_button_pressed() -> void:
#   level_generator.generate_level_from_png("res://levels/level_structures/level1.png")

func _place_character(character:CharacterBody2D):
	character.global_position=spawn_pos
