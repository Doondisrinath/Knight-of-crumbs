extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("colliding")
		get_tree().change_scene_to_file("res://Scenes/s_lv3.tscn")
