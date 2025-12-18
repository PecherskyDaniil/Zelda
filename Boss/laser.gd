extends Node2D

var shoot_time:float=4.0
var life_time:float=2.0
var damage=2
var SPEED=3
@onready var damage_area=$Area2D/CollisionShape2D
@onready var laser=$Sprite2D
func _process(delta: float) -> void:
	if GameManager.player and shoot_time>0:
		var direction=GameManager.player.global_position-global_position
		global_position+=direction*SPEED*delta
		shoot_time-=delta
	elif GameManager.player and life_time>0:
		damage_area.disabled=false
		laser.visible=true
		life_time-=delta
	else:
		queue_free()
		
	
	


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.has_method("get_damage"):
		body.get_damage(damage)
