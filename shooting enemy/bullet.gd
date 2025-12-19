extends Node2D

var life_time:float = 3.0
var move_to:Vector2 = Vector2(0.0,0.0)
var SPEED=100
var damage=1
@onready var anim=$AnimationPlayer

func _ready() -> void:
	anim.play("idle")

func _process(delta: float) -> void:
	print(move_to)
	look_at(global_position+SPEED*delta*move_to)
	global_position+=SPEED*delta*move_to
	life_time-=delta
	if life_time<=0:
		queue_free()


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("get_damage"):
		body.get_damage(damage)
		queue_free()
