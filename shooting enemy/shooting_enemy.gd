extends CharacterBody2D


signal enemy_killed
@export var move_speed: float = 100.0
@export var damage: int = 1
@export var change_direction_time: float = 2.0

@onready var damage_area: Area2D = $damage_area
@onready var items=[load("res://objects/healing_potion.tscn"),load("res://objects/heart.tscn")]
@onready var bullet_scene = load("res://shooting enemy/bullet.tscn")
@onready var anim=$AnimationPlayer
var target_node: Node2D = null
var stalk_timer: float = 0.0
var direction_timer: float = 0.0

var current_dir:Vector2=self.global_position
var shoot_time:float=randf_range(0,5.0)
const SHOOT_TIME:float = 5.0

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
		pos.y > (camera.limit_top-viewport_size.y/(camera.zoom.y*2))+38
	)

func _ready():
	# Сигналы
	anim.play("idle")
	damage_area.body_entered.connect(_on_damage_area_body_entered)

func _physics_process(delta):
	if is_visible_on_player_camera(global_position) and GameManager.player:
		shoot_time-=delta
		look_at(GameManager.player.global_position)
		if shoot_time<=0:
			shoot()
			shoot_time=SHOOT_TIME

func shoot():
	if GameManager.player:
		anim.play("shoot")
		var bullet=bullet_scene.instantiate()
		bullet.global_position=global_position
		bullet.move_to=(GameManager.player.global_position-global_position).normalized()
		GameManager.world.add_child(bullet)


#=== ОБРАБОТКА ТРИГГЕРОВ ===
func _on_damage_area_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(damage)

func get_hit(damage):
	enemy_killed.emit()
	queue_free()
	if randi_range(0,10)==0:
		var loot = items[randi_range(0, items.size()-1)].instantiate()
		loot.global_position=global_position
		GameManager.world.add_child(loot)
	
	
	
# Для визуализации направления (опционально)
