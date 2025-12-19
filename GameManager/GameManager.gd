extends Node

var level=preload("res://world/level/level.tscn")
const START_HEALTH:int=6
var MAX_PLAYER_HEALTH:int = START_HEALTH
var player_health:int = MAX_PLAYER_HEALTH
signal level_changed(map)
signal health_changed(current, max)
signal coins_changed(current_money)
signal trader_hud_open
signal trader_hud_close
var world: Node2D = null
var player: CharacterBody2D=null
var current_level:Node2D = null
var level_count=0
var player_global_pos:Vector2
var stream_player:AudioStreamPlayer=null

var pause_menu:Control
var coins:int=0

const CAMERA_Y_BIAS=108
const CAMERA_X_BIAS=-192
func _set_audio(node:AudioStreamPlayer):
	stream_player=node
	stream_player.volume_db=linear_to_db(1.0)

func _set_world(node:Node2D):
	world=node

func _set_pause_menu(control:Control):
	pause_menu=control

func _set_player(character:CharacterBody2D):
	player=character
	
func _play_simple_music():
	if stream_player:
		var music:AudioStream = load("res://music/parapapapam.mp3")
		stream_player.stream=music
		stream_player.play()

func _play_boss_music():
	if stream_player:
		stream_player.stream=load("res://music/soundtrack1.mp3")
		stream_player.play()
		
func _play_win_music():
	if stream_player:
		stream_player.stream=load("res://music/win_music.mp3")
		stream_player.play()



func _load_hub():
	_play_simple_music()
	if current_level:
		world.remove_child(current_level)
		current_level.queue_free()
	var node:Node2D = level.instantiate()
	node.teleport_closed_default_state=false
	node.enemy_count=0
	node.crates_count=0
	node.level_path="res://world/hub/hub.png"
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
	if current_level:
		world.remove_child(current_level)
		current_level.queue_free()
	var node:Node2D = level.instantiate()
	if level_count==4:
		node.teleport_closed_default_state=false
		node.enemy_count=0
		node.crates_count=0
		node.level_path="res://world/shop/shop.png"
	if level_count==5:
		node.enemy_count=0
		node.crates_count=0
		node.is_boss=true
		_play_boss_music()
	#node.generate_random_level()
	current_level=node
	if world:
		world.add_child(current_level)
	if player:
		current_level._place_character(player)
	var map = node.random_level
	level_changed.emit(map)

func on_camera_moved(pos:Vector2):
	pause_menu.global_position.x=pos.x - 192
	pause_menu.global_position.y=pos.y - 108

func add_coins(money:int):
	coins+=money
	coins_changed.emit(coins)

func lock_player():
	current_level.create_wall(Vector2i(5,12))
	current_level.create_wall(Vector2i(6,12))
	current_level.create_wall(Vector2i(7,12))
	current_level.create_wall(Vector2i(8,12))
	current_level.create_wall(Vector2i(9,12))
	current_level.create_wall(Vector2i(10,12))

func _death():
	player=null
	world=null
	current_level=null
	level_count=0
	MAX_PLAYER_HEALTH = START_HEALTH
	player_health = MAX_PLAYER_HEALTH
	var death_scene=load("res://main/death_scene.tscn")
	get_tree().change_scene_to_packed(death_scene)
	
func _win():
	player=null
	world=null
	current_level=null
	level_count=0
	MAX_PLAYER_HEALTH = START_HEALTH
	player_health = MAX_PLAYER_HEALTH
	var win_scene=load("res://main/win.tscn")
	get_tree().change_scene_to_packed(win_scene)
