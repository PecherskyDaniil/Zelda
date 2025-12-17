extends Node2D

@export var MAX_RELOAD_TIME:float=3.0
@export var arrows_speed:float=100.0
var reload_time:float=0.0

@onready var anim_player=$AnimationPlayer
@export var damage=10.0
@onready var sprite:Sprite2D=get_node("Sprite2D")
@onready var arrow_scene:PackedScene=preload("res://items/arrow.tscn")
@export var texture:Texture2D
var onload:bool=false
func _ready() -> void:
	anim_player.play("idle")

func _process(delta: float) -> void:
	reload_time-=delta

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot") and reload_time<=0:
		anim_player.play("load")
		onload=true
	if Input.is_action_just_released("shoot") and onload:
		reload_time=MAX_RELOAD_TIME
		anim_player.play("idle")
		onload=false
		shoot()

func shoot():
	var arrow=arrow_scene.instantiate()
	arrow.speed=arrows_speed
	GameManager.world.add_child(arrow)
	arrow.global_position=self.global_position
	arrow.rotation=self.rotation
