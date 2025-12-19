extends Node2D

@onready var stream=$AudioStreamPlayer
func _ready() -> void:
	stream.stream=load("res://music/death_music.mp3")
	stream.volume_db=linear_to_db(1.0)
	stream.play()
	
func _on_button_pressed() -> void:
	var main = load("res://main.tscn")
	get_tree().change_scene_to_packed(main)
