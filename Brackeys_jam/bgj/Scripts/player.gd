extends CharacterBody2D

#Movement constants
const SPRINT_SPEED := 450.0
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
		current_speed = SPRINT_SPEED
	else :
		current_speed = WALK_SPEED
	
	if direction>0:
		animated_sprite_2d.flip_h = false
	elif direction<0:
		animated_sprite_2d.flip_h = true
	if direction:
		velocity.x =move_toward(velocity.x,direction * current_speed, ACCELERATION*delta)
	else:
		velocity.x = move_toward(velocity.x,0,FRICTION*delta)
	
	#Y jumping
	if is_on_floor() and Input.is_action_just_pressed('up'):
		velocity.y = JUMP_VELOCITY
	move_and_slide()
