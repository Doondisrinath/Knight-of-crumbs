class_name HurtBox
extends Area2D


signal recieved_damage(damage: int)

@export var health : Health

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area ) -> void:
	if area is HitBox:
		var hitbox = area as HitBox	
		health.health -= hitbox.damage
		recieved_damage.emit(hitbox.damage)
