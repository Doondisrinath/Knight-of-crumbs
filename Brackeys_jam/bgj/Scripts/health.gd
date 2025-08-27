class_name Health
extends Node

signal max_health_changed(difference : int)
signal health_changed(difference : int)
signal health_depleted

@export var max_health : int = 3: set =set_max_health , get = get_max_health
func set_max_health(value) :
		var clamped_value =1 if value<=0 else value
		var difference = clamped_value - max_health
		max_health = clamped_value
		max_health_changed.emit(difference)
		if health>max_health:
			health = max_health

func get_max_health():
	return max_health


@export var invincible :bool = false:
	set = set_invincible,
	get = get_invincible

func set_invincible(value:bool):
	invincible = value
func get_invincible():
	return invincible



var health := max_health : set = set_health , get = get_health
func set_health(value):
		if value < health and invincible:
			return
		var clamped_value = clamp(value,0,max_health)
		if clamped_value!= health:
			var difference = clamped_value - health 
			health = clamped_value
			health_changed.emit(difference)
		if health == 0:
			health_depleted.emit()
		
func get_health():
		return health


var invincible_timer : Timer = null


func temporary_invincible(time:float):
	if invincible_timer == null:
		invincible_timer = Timer.new()
		invincible_timer.one_shot = true
		add_child(invincible_timer)
	if invincible_timer.timeout.is_connected(set_invincible):
		invincible_timer.timeout.disconnect(set_invincible)
	invincible_timer.set_wait_time(time)
	invincible_timer.timeout.connect(set_invincible.bind(false))
	invincible = true
	invincible_timer.start()
