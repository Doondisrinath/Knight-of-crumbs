extends CharacterBody2D

#Finite State Machine
enum STATES{IDLE,WALK,DASH,JUMP,FALL,DOUBLEJUMP,WALLSLIDE}
var current_state:STATES = STATES.IDLE
var previous_state:STATES 


#Movement constants
const DASH_SPEED := 450.0
const WALK_SPEED := 300.0
const JUMP_VELOCITY := -400.0
const ACCELERATION := 800.0
const FRICTION := 1200

var current_speed 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	#Left Right
	var direction = Input.get_axis('left','right')
	if Input.is_action_pressed('shift'):
		current_speed = DASH_SPEED
	else :
		current_speed = WALK_SPEED
	if is_on_floor():
		if direction>0:
			animated_sprite_2d.flip_h = false
		elif direction<0:
			animated_sprite_2d.flip_h = true
		if direction:
			velocity.x =move_toward(velocity.x,direction * current_speed, ACCELERATION*delta)
			if current_speed == DASH_SPEED:
				update_state(STATES.DASH)
			elif current_speed == WALK_SPEED:
				update_state(STATES.WALK)
		else:
			velocity.x = move_toward(velocity.x,0,FRICTION*delta)
			update_state(STATES.IDLE)
	
	#Y jumping
	if is_on_floor() and Input.is_action_just_pressed('space'):
		velocity.y = JUMP_VELOCITY
	
	
	if not is_on_floor() and velocity.y < 0:
		update_state(STATES.JUMP)
	elif not is_on_floor() and velocity.y > 0:
		update_state(STATES.FALL)
	move_and_slide()


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
