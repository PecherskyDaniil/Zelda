extends CharacterBody2D

@export var stalk_time: float = 10.0
@export var move_speed: float = 80.0
@export var damage: int = 1
@export var change_direction_time: float = 2.0

@onready var damage_area: Area2D = $damage_area
@onready var vision_area: Area2D = $vision_area
# Состояния: "patrol", "chase", "idle"
var current_state = "patrol"
var target_node: Node2D = null
var stalk_timer: float = 0.0
var direction_timer: float = 0.0

# Только 4 направления (без диагоналей)
var possible_directions = [
	Vector2.RIGHT,   # 0: вправо
	Vector2.LEFT,    # 1: влево
	Vector2.UP,      # 2: вверх
	Vector2.DOWN     # 3: вниз
]
var current_dir_index = 0
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
	# Начинаем с случайного направления
	current_dir_index = randi_range(0, 3)
	move_direction = possible_directions[current_dir_index]
	direction_timer = change_direction_time
	
	# Сигналы
	damage_area.body_entered.connect(_on_damage_area_body_entered)
	vision_area.body_entered.connect(_on_vision_area_body_entered)
	vision_area.body_exited.connect(_on_vision_area_body_exited)

func _physics_process(delta):
	if is_visible_on_player_camera(global_position):
		# Обновляем таймеры
		direction_timer -= delta
		if stalk_timer > 0:
			stalk_timer -= delta
			if stalk_timer <= 0 and current_state == "chase":
				stop_chasing()
		
		# Движение в зависимости от состояния
		match current_state:
			"patrol":
				patrol_behavior(delta)
			"chase":
				chase_behavior(delta)
		
		# Применяем движение и проверяем коллизии
		var was_moving = move_and_slide()
		check_collisions()

#=== ПАТРУЛИРОВАНИЕ ===
func patrol_behavior(delta):
	# Меняем направление по таймеру
	if direction_timer <= 0:
		change_direction()
		direction_timer = change_direction_time
	
	# Двигаемся в текущем направлении
	velocity = move_direction * move_speed

func change_direction():
	# Выбираем новое направление (не такое же как текущее)
	var new_index = current_dir_index
	while new_index == current_dir_index:
		new_index = randi_range(0, 3)
	
	current_dir_index = new_index
	move_direction = possible_directions[current_dir_index]

#=== ПРЕСЛЕДОВАНИЕ ===
func chase_behavior(delta):
	if not target_node or not is_instance_valid(target_node):
		stop_chasing()
		return
	
	# Определяем направление к цели (только по осям)
	var to_target = target_node.global_position - global_position
	
	# Выбираем ось с большим смещением
	if abs(to_target.x) > abs(to_target.y):
		# Двигаемся по горизонтали
		if to_target.x > 0:
			move_direction = Vector2.RIGHT
		else:
			move_direction = Vector2.LEFT
	else:
		# Двигаемся по вертикали
		if to_target.y > 0:
			move_direction = Vector2.DOWN
		else:
			move_direction = Vector2.UP
	
	# Двигаемся к цели
	velocity = move_direction * move_speed

#=== ОБРАБОТКА СТОЛКНОВЕНИЙ ===
func check_collisions():
	# Проверяем все столкновения за этот кадр
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		
		# Если столкнулись со стеной - меняем направление
		if collision.get_collider() is TileMap or collision.get_collider() is StaticBody2D:
			handle_wall_collision()

func handle_wall_collision():
	# При столкновении со стеной выбираем перпендикулярное направление
	match current_dir_index:
		0, 1:  # Если двигались горизонтально, пробуем вертикально
			# Пробуем вверх или вниз (случайный выбор)
			if randi() % 2 == 0:
				move_direction = Vector2.UP
				current_dir_index = 2
			else:
				move_direction = Vector2.DOWN
				current_dir_index = 3
		2, 3:  # Если двигались вертикально, пробуем горизонтально
			if randi() % 2 == 0:
				move_direction = Vector2.RIGHT
				current_dir_index = 0
			else:
				move_direction = Vector2.LEFT
				current_dir_index = 1
	
	# Сбрасываем таймер смены направления
	direction_timer = change_direction_time
	
	# Останавливаемся на мгновение (опционально)
	velocity = Vector2.ZERO

#=== ОБРАБОТКА ТРИГГЕРОВ ===
func _on_damage_area_body_entered(body):
	if body.has_method("get_damage"):
		body.get_damage(damage)
		# Отталкиваем врага назад
		velocity = -move_direction * move_speed * 0.5

func _on_vision_area_body_entered(body):
	if body.is_in_group("player") or body.has_method("get_damage"):
		target_node = body
		stalk_timer = stalk_time
		current_state = "chase"
		# Сразу меняем направление к цели
		direction_timer = 0.1  # Минимальная задержка

func _on_vision_area_body_exited(body):
	if body == target_node:
		# Таймер уже отсчитывается
		pass

func stop_chasing():
	target_node = null
	current_state = "patrol"
	change_direction()  # Случайное новое направление
	direction_timer = change_direction_time

#=== ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ ===
func get_direction_name() -> String:
	# Для отладки
	match current_dir_index:
		0: return "RIGHT"
		1: return "LEFT"
		2: return "UP"
		3: return "DOWN"
		_: return "UNKNOWN"

func get_hit(damage):
	queue_free()
# Для визуализации направления (опционально)
