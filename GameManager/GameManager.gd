extends Node

var level=preload("res://world/level/level.tscn")
var MAX_PLAYER_HEALTH:int = 40
var player_health:int = MAX_PLAYER_HEALTH
signal level_changed(map)
signal health_changed(current, max)
var world: Node2D = null
var player: CharacterBody2D=null
var current_level:Node2D = null
var level_count=0
var player_global_pos:Vector2

const CAMERA_Y_BIAS=108
const CAMERA_X_BIAS=-192

func _set_world(node:Node2D):
	world=node
	
func _set_player(character:CharacterBody2D):
	player=character

func _load_hub():
	if current_level:
		world.remove_child(current_level)
		current_level.queue_free()
	var node:Node2D = level.instantiate()
	node.teleport_closed_default_state=false
	node.enemy_count=0
	node.crates_count=0
	node.level_path="res://world/hub/hub.png"
	#node.generate_special_level()
	current_level=node
	if world:
		world.add_child(current_level)
	if player:
		current_level._place_character(player)
	var map = node.random_level
	print(map)
	level_changed.emit(map)

func _load_level():
	level_count+=1
	print(level_count)
	if current_level:
		world.remove_child(current_level)
		current_level.queue_free()
	var node:Node2D = level.instantiate()
	#node.generate_random_level()
	current_level=node
	if world:
		world.add_child(current_level)
	if player:
		current_level._place_character(player)
	var map = node.random_level
	level_changed.emit(map)
