extends Node2D


@onready var player_scene = preload("res://player/Player.tscn")
@onready var main= $Menu/main
@onready var settings=$Menu/settings
@onready var pause_menu=$Pause
@onready var world=$world
var player:Node2D
var game_started=false

func _ready() -> void:
	player = player_scene.instantiate()
	GameManager._set_player(player)
	GameManager._set_world(world)
	GameManager._set_pause_menu(pause_menu)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("pause") and game_started:
		pause()
	
func _on_settings_button_pressed() -> void:
	main.visible=false
	settings.visible=true


func _on_play_button_pressed() -> void:
	game_started=true
	main.visible=false
	GameManager._load_hub()
	world.add_child(player)
	


func _on_back_button_pressed() -> void:
	main.visible=true
	settings.visible=false

func pause():
	pause_menu.visible=true
	get_tree().paused = true


func _on_exit_button_pressed() -> void:
	get_tree().quit()
