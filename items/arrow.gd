extends Node2D

var move_vector:Vector2=Vector2(0,1)
var speed:float=100.0

const MAX_LIFE_TIME=5.0
var lifetime:float
func _ready() -> void:
	lifetime=MAX_LIFE_TIME

func _process(delta: float) -> void:
	lifetime-=delta
	global_position+=move_vector.rotated(self.rotation)*delta*speed
	if lifetime<=0:
		queue_free()



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("get_hit"):
		body.get_hit(10.0)
		queue_free()
