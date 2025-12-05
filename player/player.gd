extends CharacterBody2D

enum move_state{IDLE,WALK}
enum object_state{EXIST,NOT_EXIST}
var MAX_PLAYER_HEALTH:int = 5
var ON_HIT_TIME:float=3.0

signal player_dead

var hitted_time_expired:float=0
var player_health:int = MAX_PLAYER_HEALTH

var coins:float=0.0
var keys:int=0


@onready var anim_player=$AnimationPlayer
var current_move_state:move_state=move_state.IDLE
var current_object_state:object_state=object_state.EXIST
var speed:float=200.0
var idle_name="idle_front"
@onready var world_object=$"../world/library"
	
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
		idle_name="idle_front"
	if direction==Vector2.UP:
		idle_name="idle_back"
	if direction==Vector2.LEFT:
		idle_name="idle_left"
	if direction==Vector2.RIGHT:
		idle_name="idle_right"
	velocity=direction.normalized()*speed

func get_damage(damage:int):
	player_health-=damage
	if player_health<=0:
		player_dead.emit()
		print("I DEAD")
	hitted_time_expired=ON_HIT_TIME
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


func _physics_process(delta: float) -> void:
	match current_move_state:
		move_state.IDLE:
			handle_idle(delta)
		move_state.WALK:
			handle_walk(delta)
	
	match current_object_state:
		object_state.EXIST:
			handle_exist(delta)
		object_state.NOT_EXIST:
			handle_not_exist(delta)
	handle_collisions(delta)	
	move_and_slide()
