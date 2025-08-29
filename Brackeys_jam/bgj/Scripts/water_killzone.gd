extends HitBox

var checkpoint_manager
var player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	checkpoint_manager = get_parent().get_node("Checkpoint Manager")
	player = get_parent().get_node("Player")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_entered(body: Node2D) -> void:
	killPlayer()

func killPlayer():
	player.position = checkpoint_manager.last_location
	
