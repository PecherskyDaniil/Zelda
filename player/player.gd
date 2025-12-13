extends CharacterBody2D

enum move_state{IDLE,WALK, HIT}
enum object_state{EXIST,NOT_EXIST}
var ON_HIT_TIME:float=3.0

signal player_dead

var hitted_time_expired:float=0

var coins:float=0.0
var keys:int=0
var hit_time=0

@onready var anim_player=$AnimationPlayer
var current_move_state:move_state=move_state.IDLE
var current_object_state:object_state=object_state.EXIST
var speed:float=200.0
var idle_name="idle_front"


@onready var sword:Node2D=get_node("hands/sword1")


@onready var camera:Camera2D=$Camera2D
@onready var screen_size = get_viewport_rect().size

func handle_idle(delta):
	var direction=Input.get_vector("left","right","up","down")
	if direction!=Vector2.ZERO:
		current_move_state=move_state.WALK
	
func handle_walk(delta):
	var direction=Input.get_vector("left","right","up","down")
	if Input.is_action_pressed("right") || Input.is_action_pressed("left"):
		direction.y=0
	
	if Input.is_action_pressed("down") || Input.is_action_pressed("up"):
		direction.x=0
	if direction==Vector2.ZERO:
		current_move_state=move_state.IDLE
	if direction==Vector2.DOWN:
		sword.rotation=deg_to_rad(0)
		idle_name="idle_front"
	if direction==Vector2.UP:
		sword.rotation=deg_to_rad(180)
		idle_name="idle_back"
	if direction==Vector2.LEFT:
		sword.rotation=deg_to_rad(90)
		idle_name="idle_left"
	if direction==Vector2.RIGHT:
		sword.rotation=deg_to_rad(-90)
		idle_name="idle_right"
	velocity=direction.normalized()*speed

func handle_hit(delta):
	velocity=Vector2(0,0)
	sword.hit()
	hit_time=sword.HIT_TIME
	current_move_state=move_state.HIT
	

func get_damage(damage:int):
	GameManager.player_health-=damage
	GameManager.health_changed.emit()
	if GameManager.player_health<=0:
		player_dead.emit()
		print("I DEAD")
	hitted_time_expired=ON_HIT_TIME
	velocity= Vector2(randf_range(0.1,1.0),randf_range(0.1,1.0))
	current_object_state=object_state.NOT_EXIST

func handle_collisions(delta):
	pass


func handle_exist(delta):
	anim_player.play("exist")
	
func handle_not_exist(delta):
	hitted_time_expired-=delta
	if hitted_time_expired<=0.0:
		hitted_time_expired=0.0
		current_object_state=object_state.EXIST
	anim_player.play("not_exist")

func move_camera(pos):
	print(pos)
	camera.limit_bottom=pos.y
	camera.limit_top=pos.y
	camera.limit_left=pos.x
	camera.limit_right=pos.x

func manage_camera(pos:Vector2):
	var camera_pos=Vector2(camera.limit_left, camera.limit_bottom)
	if int(global_position.y)<int(camera_pos.y+GameManager.CAMERA_Y_BIAS-screen_size.y/(2*camera.zoom.y)):
		move_camera(Vector2(camera_pos.x,camera_pos.y-screen_size.y/camera.zoom.y))
	elif int(global_position.y)>int(camera_pos.y+GameManager.CAMERA_Y_BIAS+screen_size.y/(2*camera.zoom.y)):
		move_camera(Vector2(camera_pos.x,camera_pos.y+screen_size.y/camera.zoom.y))
	elif int(global_position.x)<int(camera_pos.x+GameManager.CAMERA_X_BIAS-screen_size.x/(2*camera.zoom.x)):
		move_camera(Vector2(camera_pos.x-screen_size.x/camera.zoom.x,camera_pos.y))
	elif int(global_position.x)>int(camera_pos.x+GameManager.CAMERA_X_BIAS+screen_size.x/(2*camera.zoom.x)):
		move_camera(Vector2(camera_pos.x+screen_size.x/camera.zoom.x,camera_pos.y))

func _physics_process(delta: float) -> void:
	GameManager.player_global_pos=global_position
	manage_camera(global_position)
	match current_move_state:
		move_state.IDLE:
			handle_idle(delta)
		move_state.WALK:
			handle_walk(delta)
		move_state.HIT:
			if hit_time>0:
				hit_time-=delta
			else:
				current_move_state=move_state.IDLE
	
	match current_object_state:
		object_state.EXIST:
			handle_exist(delta)
		object_state.NOT_EXIST:
			handle_not_exist(delta)
	
	if Input.is_action_pressed("hit") and current_move_state!=move_state.HIT:
		handle_hit(delta)
	handle_collisions(delta)	
	move_and_slide()

func shade():
	if anim_player!=null:
		anim_player.play("shade_camera")
