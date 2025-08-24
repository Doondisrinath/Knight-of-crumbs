extends CharacterBody2D

#Movement constants
const SPRINT_SPEED := 450.0
const WALK_SPEED := 300.0
const JUMP_VELOCITY := -400.0
const ACCELERATION := 600.0
const FRICTION := 1200

var current_speed 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


enum STATE {IDLE, WALK, RUN, JUMP, FALL}
var player_state: STATE = STATE.IDLE

func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	#Left Right
	var direction = Input.get_axis('left','right')
	if Input.is_action_pressed('shift'):
		current_speed = SPRINT_SPEED
	else :
		current_speed = WALK_SPEED
	
	
	if direction:
		velocity.x =move_toward(velocity.x,direction * current_speed, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x,0,FRICTION*delta)
	
	#Y jumping
	if is_on_floor() and Input.is_action_just_pressed('space'):
		velocity.y = JUMP_VELOCITY
	move_and_slide()
	update_player_state(direction)


func update_player_state(direction):
	if not is_on_floor():
		if velocity.y < 0:
			player_state = STATE.JUMP
			animated_sprite_2d.animation = 'Jump'
		else:
			player_state = STATE.FALL
	else:
		if velocity.x != 0:
			if Input.is_action_pressed("shift") and is_on_floor():
				player_state = STATE.RUN
				animated_sprite_2d.animation = 'Run'
			else:
				player_state = STATE.WALK
				animated_sprite_2d.animation = 'Walk'
		else:
			player_state = STATE.IDLE
			animated_sprite_2d.animation = 'Idle'
	if direction>0:
		animated_sprite_2d.flip_h = false
	elif direction<0:
		animated_sprite_2d.flip_h = true
# You can print the state to debug it
