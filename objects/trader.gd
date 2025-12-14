extends StaticBody2D

var is_active:bool=false
@onready var anim_player:AnimationPlayer=get_node("AnimationPlayer")

func _ready() -> void:
	print("unready")
	anim_player.play("not_ready")

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("interact") and is_active:
		GameManager.trader_hud_open.emit()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name=="player":
		anim_player.play("ready")
		is_active=true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name=="player":
		anim_player.play("not_ready")
		is_active=false
	GameManager.trader_hud_close.emit()
