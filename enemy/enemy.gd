extends CharacterBody2D


signal enemy_killed
@export var move_speed: float = 100.0
@export var damage: int = 1
@export var change_direction_time: float = 2.0

@onready var damage_area: Area2D = $damage_area
@onready var items=[load("res://objects/healing_potion.tscn"),load("res://objects/heart.tscn")]
@onready var anim_player=get_node("AnimationPlayer")
var target_node: Node2D = null
var stalk_timer: float = 0.0
var direction_timer: float = 0.0

var current_dir:Vector2=self.global_position

var walk_time:float=0.0
const TIME_TO_WALK:float=1.0
# Только 4 направления (без диагоналей)
var possible_directions = [
	Vector2.RIGHT,   # 0: вправо
	Vector2.LEFT,    # 1: влево
	Vector2.UP,      # 2: вверх
	Vector2.DOWN     # 3: вниз
]
var move_direction: Vector2 = Vector2.RIGHT

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
	anim_player.play("idle")
	# Начинаем с случайного направления
	move_direction = possible_directions[randi_range(0, 3)]
	
	# Сигналы
	damage_area.body_entered.connect(_on_damage_area_body_entered)

func _physics_process(delta):
	if is_visible_on_player_camera(global_position):
		velocity-=velocity.normalized()*4.0
		random_walk(delta)
		# Применяем движение и проверяем коллизии
		move_and_slide()

func random_walk(delta):
	if walk_time>0.0:
		walk_time-=delta
	else:
		
		current_dir=Vector2(-1000000,-10000)
		while current_dir==Vector2(-1000000,-10000):
			var move_dir=self.global_position+possible_directions[randi_range(0,3)]
			if is_visible_on_player_camera(move_dir):
				current_dir=move_dir
				velocity=(current_dir-self.global_position)*move_speed
				walk_time=TIME_TO_WALK
				break
				


#=== ОБРАБОТКА ТРИГГЕРОВ ===
func _on_damage_area_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(damage)
		# Отталкиваем врага назад
		velocity = (self.global_position-body.global_position)*10
		walk_time=TIME_TO_WALK

func get_hit(damage):
	enemy_killed.emit()
	anim_player.play("death")
	if randi_range(0,10)==0:
		var loot = items[randi_range(0, items.size()-1)].instantiate()
		loot.global_position=global_position
		GameManager.world.add_child(loot)
	
	
	
# Для визуализации направления (опционально)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="death":
		queue_free()
