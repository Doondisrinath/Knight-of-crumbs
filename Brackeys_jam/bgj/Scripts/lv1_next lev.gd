extends Area2D

var lv3 = preload("res://Scenes/s_lv3.tscn")
@onready var player: CharacterBody2D = $"../Player"


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		get_tree().set_deferred("res://Scenes/s_lv3.tscn",1)
		get_tree().change_scene_to_packed(lv3)
