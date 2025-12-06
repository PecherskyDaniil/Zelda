extends Node2D

@onready var anim:AnimatedSprite2D=$AnimatedSprite2D

@export  var destination: String = ""
var entered = false
var closed=false

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is CharacterBody2D:
		entered=true
	


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is CharacterBody2D:
		entered=false

func _ready() -> void:
	anim.play("default")

func _process(delta: float) -> void:
	if Input.is_action_pressed("interact") and entered and !closed:
		anim.play("Teleport")
		GameManager._load_level()
