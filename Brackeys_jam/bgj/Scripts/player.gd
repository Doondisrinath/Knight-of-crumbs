extends CharacterBody2D

#Finite State Machine
enum STATES{IDLE,WALK,DASH,JUMP,FALL,DOUBLEJUMP,WALLSLIDE,WALLJUMP}
var current_state:STATES = STATES.IDLE
var previous_state:STATES 
var is_wall_sliding := false
var wall_dir := 0
var wall_jump_velocity := -300.0
#Movement constants
const DASH_SPEED := 5000.0
const WALK_SPEED := 250.0
const JUMP_VELOCITY := -400.0
const ACCELERATION := 2000.0
const FRICTION := 5000.0
const WALL_SLIDE_FRICTION := 100
var current_speed 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_wall_sliding:
		velocity.y = min(velocity.y,WALL_SLIDE_FRICTION)
	
	handle_air_states()
	walk(delta)
	jump()
	move_and_slide()
	check_wall_collision()

func update_state(new_state: STATES): 
	previous_state = current_state
	current_state = new_state
	match current_state:
		STATES.IDLE:
			animated_sprite_2d.animation = 'idle'
		STATES.WALK:
			animated_sprite_2d.animation = 'walk'
		STATES.JUMP:
			animated_sprite_2d.animation = 'jump'
		STATES.DOUBLEJUMP:
			animated_sprite_2d.animation = 'jump'
		STATES.FALL:
			animated_sprite_2d.animation = 'fall'
		STATES.DASH:
			animated_sprite_2d.animation = 'dash'
		STATES.WALLSLIDE:
			animated_sprite_2d.animation = 'wall slide'
		STATES.WALLJUMP:
			animated_sprite_2d.animation = 'jump'
	for i in STATES:
		if STATES[i] == current_state:
			print(i)


func jump():
	if is_on_floor() and Input.is_action_just_pressed('space') and previous_state != STATES.WALLSLIDE:
		velocity.y = JUMP_VELOCITY
		update_state(STATES.JUMP)
	if is_wall_sliding and Input.is_action_just_pressed('space'):
		velocity.y = wall_jump_velocity
		velocity.x = -wall_dir * WALK_SPEED * 1.5
		update_state(STATES.WALLJUMP)

func handle_air_states():
	if not is_on_floor():
		if current_state in [STATES.WALLSLIDE,STATES.WALLJUMP]:
			return
		if velocity.y <0 and current_state!= STATES.FALL:
			update_state(STATES.JUMP)
		elif current_state != STATES.JUMP and velocity.y>0:
			update_state(STATES.FALL)

func walk(delta):
	var direction = Input.get_axis('left','right')
	if Input.is_action_just_pressed('shift'):
		current_speed = DASH_SPEED
	else :
		current_speed = WALK_SPEED
	
	if direction>0:
		animated_sprite_2d.flip_h = false
	elif direction<0:
		animated_sprite_2d.flip_h = true
	if direction:
		velocity.x =move_toward(velocity.x,direction * current_speed, ACCELERATION*delta)
		if current_speed == DASH_SPEED:
			update_state(STATES.DASH)
		elif current_speed == WALK_SPEED and is_on_floor():
			update_state(STATES.WALK)
	elif is_on_floor():
		velocity.x = move_toward(velocity.x,0,FRICTION*delta)
		update_state(STATES.IDLE)


func dash():
	pass


func check_wall_collision():
	is_wall_sliding = false
	wall_dir = 0
	if not is_on_floor():
		#test left
		if test_move(global_transform, Vector2(-1, 0)) and Input.is_action_pressed("left") and current_state != STATES.WALK :
			wall_dir = -1
			is_wall_sliding = true
			if is_on_wall():
				update_state(STATES.WALLSLIDE)
		#test right
		elif test_move(global_transform, Vector2(1, 0)) and Input.is_action_pressed("right") and current_state != STATES.WALK  :
			wall_dir = 1
			is_wall_sliding = true
			if is_on_wall():
				update_state(STATES.WALLSLIDE)
		elif (Input.is_action_pressed("right") or Input.is_action_pressed("left")) and (previous_state == STATES.WALLSLIDE or current_state == STATES.WALLSLIDE) :
			if current_state == STATES.WALLJUMP or previous_state == STATES.WALLJUMP:
				return
			elif current_state != STATES.WALLJUMP or previous_state != STATES.WALLJUMP:
				update_state(STATES.FALL)
