extends Node2D


@onready var anim=$AnimationPlayer
@onready var hit_area:Area2D=$Area2D
@export var damage=10.0
const HIT_TIME:float=0.5
var hit_time:float=0
func _ready() -> void:
	anim.play("idle")
	
func _process(delta: float) -> void:
	if hit_time>0.0:
		handle_hit(delta)
		
		
func hit():
	hit_time=HIT_TIME
	anim.play("hit")
	
func handle_hit(delta):
	hit_time-=delta
	var bodies=hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.has_method("get_hit"):
			body.get_hit(damage)


		
