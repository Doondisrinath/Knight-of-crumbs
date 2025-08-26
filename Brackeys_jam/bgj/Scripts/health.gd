class_name Health
extends Node

signal max_health_changed(difference : int)
signal health_changed(difference : int)
signal health_depleted

@export var max_health : int = 3:
	set(value) :
		var clamped_value =1 if value<=0 else value
		var difference = clamped_value - max_health
		max_health = clamped_value
		max_health_changed.emit(difference)
		if health>max_health:
			health = max_health
	get:
		return max_health


@export var invincible :bool = false:
	set(value):
		pass
	get:
		return invincible


var health := max_health:
	set(value):
		if value < health and invincible:
			return
		var clamped_value = clamp(value,0,max_health)
		if clamped_value!= health:
			var difference = clamped_value - health 
			health = clamped_value
			health_changed.emit(difference)
		if health == 0:
			health_depleted.emit()
		
	get:
		return health


var invincible_timer : Timer = null


func temporary_invincible(time:float):
	if invincible_timer == null:
		invincible_timer = Timer.new()
		invincible_timer.one_shot = true
		add_child(invincible_timer)
	if invincible_timer.timeout.is_connected(invincible):
		invincible_timer.timeout.disconnect(invincible.set)
