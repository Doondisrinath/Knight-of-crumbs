extends Sprite2D

var amplitude: float = 20.0 # how far it moves
var speed: float = 2.0 # how fast it oscillates
var start_y: float

func _ready():
	start_y = position.y

func _process(delta: float) -> void:
	position.y = start_y + sin(Time.get_ticks_msec() / 1000.0 * speed) * amplitude
