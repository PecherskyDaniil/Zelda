extends Node2D



@onready var level_generator = preload("res://world/level_generator.gd")
@onready var tile_map: TileMapLayer = $floor_and_walls
@onready var objects_tile_map:TileMapLayer = $objects
var wall:Vector2i=Vector2i(14,0)
var floor:Vector2i=Vector2i(1,2)
var spawn_pos=Vector2(0,0)
var random_level:String
@onready var teleport_scene:PackedScene = preload("res://objects/teleport.tscn")
@onready var enemy_scene:PackedScene=preload("res://enemy/enemy.tscn")
@onready var crate_scene:PackedScene=preload("res://objects/crate.tscn")
@export var teleport_closed_default_state:bool=true

var level_size:Vector2i
@export var enemy_count:int=10
@export var crates_count:int=20
@onready var teleport=teleport_scene.instantiate()
@export var level_path:String=""

func _ready() -> void:
	if level_path!="":
		generate_special_level(level_path)
	else:
		generate_random_level()

func generate_special_level(level_path:String)->void:
	var lg=level_generator.new()
	lg.generate_from_png(tile_map,objects_tile_map,level_path)
	random_level=level_path
	level_size=lg.size
	teleport.global_position=Vector2(lg.get_teleport_pos())
	teleport.closed=teleport_closed_default_state
	spawn_pos=Vector2(lg.get_teleport_pos())
	add_child(teleport)
	place_enemies(enemy_count)
	place_crates(crates_count)

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
		random_level = level_files[randi() % level_files.size()]
		generate_special_level(random_level)

func place_enemies(enemy_count:int):
	var placed_enemies=0
	while placed_enemies<enemy_count:
		var pos=Vector2i(randi_range(0,level_size.x-1),randi_range(0,level_size.y-1))
		var tile:TileData=tile_map.get_cell_tile_data(pos)
		if tile!=null and tile.get_collision_polygons_count(0)==0:
			placed_enemies+=1
			var enemy=enemy_scene.instantiate()
			place_object(enemy,pos)
			enemy.enemy_killed.connect(_on_enemy_killed)

func place_crates(crates_count:int):
	var placed_crates=0
	while placed_crates<crates_count:
		var pos=Vector2i(randi_range(0,level_size.x-1),randi_range(0,level_size.y-1))
		if Vector2(pos)==spawn_pos:
			continue
		var ground_tile:TileData=tile_map.get_cell_tile_data(pos)
		var object_tile:TileData=objects_tile_map.get_cell_tile_data(pos)
		if ground_tile!=null and ground_tile.get_collision_polygons_count(0)==0 and object_tile==null:
			placed_crates+=1
			var crate=crate_scene.instantiate()
			place_object(crate,pos)

func _on_enemy_killed():
	enemy_count-=1
	if enemy_count<=0:
		teleport.closed=false

func place_object(object:Node2D,pos:Vector2i):
	add_child(object)
	object.global_position=tile_map.map_to_local(pos)


func _place_character(character:CharacterBody2D):
	character.global_position=spawn_pos
	character.shade()
