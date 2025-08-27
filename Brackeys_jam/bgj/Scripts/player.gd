extends CharacterBody2D

#Finite State Machine
enum STATES{IDLE,WALK,DASH,JUMP,FALL,DOUBLEJUMP,WALLSLIDE,WALLJUMP,ATTACK,HURT,DYING}
var current_state:STATES = STATES.IDLE
var previous_state:STATES 
var is_wall_sliding := false
var wall_dir := 0
var wall_jump_velocity := -300.0
var jump_count : int = 0
var can_dash = true
var dashing = false
var direction
var current_speed 
var attacking = false
var attack_animation = 0
var hurt_lockout := false
var allow_state_override_during_attack := false

@onready var attack0: CollisionShape2D = $HitBox/attack0
@onready var hurt_timer: Timer = $hurt_timer









#Movement constants
const DASH_SPEED := 900.0
const WALK_SPEED := 250.0
const JUMP_VELOCITY := -400.0
const ACCELERATION := 2000.0
const FRICTION := 5000.0
const WALL_SLIDE_FRICTION := 100
const MAX_DASHES = 1
const MAX_JUMPS = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_timer: Timer = $dash_timer
@onready var dash_again_timer: Timer = $dash_again_timer



func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_wall_sliding:
		velocity.y = min(velocity.y,WALL_SLIDE_FRICTION)
	if is_on_floor():
		jump_count = 0
	
	
	handle_air_states()
	walk(delta)
	dash()
	jump()
	attack()
	move_and_slide()
	check_wall_collision()


func _process(_delta: float) -> void:
	for i in STATES:
		if STATES[i] == current_state:
			print(i)


func update_state(new_state: STATES):
	
	
	
	
	if current_state == new_state:
		return
	
	if attacking and new_state != STATES.ATTACK and not allow_state_override_during_attack:
		return
	if current_state == STATES.DYING:
		return
	
	previous_state = current_state
	current_state = new_state
	
	match current_state:
		STATES.IDLE:        animated_sprite_2d.play("idle")
		STATES.WALK:        animated_sprite_2d.play("walk")
		STATES.JUMP:        animated_sprite_2d.play("jump")
		STATES.DOUBLEJUMP:  animated_sprite_2d.play("jump")
		STATES.FALL:        animated_sprite_2d.play("fall")
		STATES.DASH:        animated_sprite_2d.play("dash")
		STATES.WALLSLIDE:   animated_sprite_2d.play("wall slide")
		STATES.WALLJUMP:    animated_sprite_2d.play("jump")
		STATES.ATTACK:
			match attack_animation:
				0:
					animated_sprite_2d.animation = "attack"
					animated_sprite_2d.play()
				1:
					animated_sprite_2d.animation = "attack1"
					animated_sprite_2d.play()
				2:
					animated_sprite_2d.animation = "attack2"
					animated_sprite_2d.play()
				3:
					animated_sprite_2d.animation = "attack3"
					animated_sprite_2d.play()





func jump():
	if is_on_floor() and Input.is_action_just_pressed('space') and previous_state != STATES.WALLSLIDE:
		velocity.y = JUMP_VELOCITY
		update_state(STATES.JUMP)
	elif jump_count < MAX_JUMPS and not is_on_floor() and Input.is_action_just_pressed('space') and current_state != STATES.WALLSLIDE:
		velocity.y = JUMP_VELOCITY
		update_state(STATES.DOUBLEJUMP)
		jump_count +=1
		
	elif is_wall_sliding and Input.is_action_just_pressed('space'):
		velocity.y = wall_jump_velocity
		velocity.x = -wall_dir * WALK_SPEED * 1.5
		update_state(STATES.WALLJUMP)


func handle_air_states():
	if dashing:
		return
	if not is_on_floor():
		if current_state in [STATES.WALLSLIDE,STATES.WALLJUMP]:
			return
		if velocity.y <0 and current_state!= STATES.FALL:
			update_state(STATES.JUMP)
		elif (current_state != STATES.JUMP and current_state != STATES.DOUBLEJUMP and current_state != STATES.WALLSLIDE) and velocity.y>0:
			update_state(STATES.FALL)


func walk(delta):
	if attacking or dashing:
		return
	direction = Input.get_axis("left","right")
	current_speed = WALK_SPEED
	if not dashing:
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true
		if direction:
			velocity.x = move_toward(velocity.x, direction * current_speed, ACCELERATION * delta)
			if current_speed == WALK_SPEED and is_on_floor() and not dashing:
				update_state(STATES.WALK)
		elif is_on_floor():
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
			update_state(STATES.IDLE)


func dash():
	if Input.is_action_just_pressed("shift") and can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_again_timer.start()
	
		update_state(STATES.DASH)
	
		# freeze vertical velocity only once at start if you want
		velocity.y = 0
	
	if dashing:
		var dash_dir = direction
		if dash_dir == 0:
			dash_dir = -1 if animated_sprite_2d.flip_h else 1
		velocity.x = dash_dir * DASH_SPEED



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
			elif (current_state != STATES.WALLJUMP and current_state != STATES.WALLSLIDE ) or previous_state != STATES.WALLJUMP:
				update_state(STATES.FALL)


#for dash cooldown
func _on_dash_again_timer_timeout() -> void:
	can_dash = true

func attack():
	if Input.is_action_just_pressed("attack") and not attacking:
		attacking = true
		update_state(STATES.ATTACK)
		attack0.disabled = false
		velocity.x = 0   # freeze movement during attack


func _on_attack_timer_timeout() -> void:
	pass # Replace with function body.


func take_damage():
	print('player took damage')


func _on_health_health_depleted() -> void:
	update_state(STATES.DYING)



func _on_health_changed(difference: int) -> void:
	if difference < 0 and not hurt_lockout:
		update_state(STATES.HURT)
		hurt_lockout = true
		hurt_timer.start()



func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == STATES.ATTACK:
		attacking = false
		attack0.disabled = true
		attack_animation = (attack_animation + 1) % 4

		# temporarily allow breaking out of attack
		allow_state_override_during_attack = true
		if is_on_floor():
			update_state(STATES.IDLE)
		elif velocity.y > 0 and current_state != STATES.WALLSLIDE:
			update_state(STATES.FALL)
		else:
			update_state(STATES.JUMP)
		allow_state_override_during_attack = false

	elif animated_sprite_2d.animation == "dying":
		queue_free()



func _on_dash_timer_timeout() -> void:
	dashing = false
	if is_on_floor():
		if direction != 0:
			update_state(STATES.WALK)
		else:
			update_state(STATES.IDLE)
	else:
		if velocity.y > 0 and current_state != STATES.WALLSLIDE:
			update_state(STATES.FALL)
		elif current_state !=STATES.WALLSLIDE :
			update_state(STATES.JUMP)
