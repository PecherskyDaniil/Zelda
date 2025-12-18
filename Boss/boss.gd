extends CharacterBody2D


signal enemy_killed
@export var damage: int = 1

@onready var damage_area: Area2D = $damage_area
@onready var shield=$BossShield
@onready var laser=preload("res://Boss/laser.tscn")
@onready var minion=preload("res://shooting enemy/shooting_enemy.tscn")
var CAST_TIME:float=4.0
var cast_timer:float=CAST_TIME
var SUMMON_TIME:float=10.0
var summon_timer:float=0.0
var current_dir:Vector2=self.global_position
var health:int=3
var is_invincible=false
var invincible_timer:float=0.0
var is_wall_created=false
func is_visible_on_player_camera(pos:Vector2) -> bool:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return false
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	return (
		pos.x < camera.limit_left+viewport_size.x/(camera.zoom.x*2) and
		pos.x > camera.limit_left-viewport_size.x/(camera.zoom.x*2) and
		pos.y < camera.limit_top+viewport_size.y/(camera.zoom.y*2) and
		pos.y > camera.limit_top-viewport_size.y/(camera.zoom.y*2)
	)

func _ready():
	# Сигналы
	damage_area.body_entered.connect(_on_damage_area_body_entered)
func cast():
	var laser_beam=laser.instantiate()
	laser_beam.global_position=global_position
	GameManager.world.add_child(laser_beam)

func summon():
	var minion1=minion.instantiate()
	minion1.global_position=Vector2(randf_range(80,300),randf_range(100,150))
	var minion2=minion.instantiate()
	minion2.global_position=Vector2(randf_range(80,300),randf_range(100,150))
	GameManager.add_child(minion1)
	GameManager.add_child(minion2)


	
func _physics_process(delta):
	if is_visible_on_player_camera(global_position):
		if !is_wall_created:
			GameManager.lock_player()
			is_wall_created=true
		if cast_timer>0:
			cast_timer-=delta
		else:
			cast_timer=CAST_TIME
			cast()
		
		if summon_timer>0:
			summon_timer-=delta
		else:
			summon_timer=SUMMON_TIME
			summon()
		
		if invincible_timer>0:
			invincible_timer-=delta
			is_invincible=true
			shield.visible=true
		else:
			is_invincible=false
			shield.visible=false

#=== ОБРАБОТКА ТРИГГЕРОВ ===
func _on_damage_area_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(damage)

func get_hit(damage):
	if !is_invincible:
		health-=1
		is_invincible=true
		invincible_timer=5.0
	if health<=0:
		enemy_killed.emit()
		GameManager._death()
		queue_free()
