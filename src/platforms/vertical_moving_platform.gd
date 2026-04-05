extends StaticBody2D

@export var speed: float = 100.0
@export var move_distance: float = 200.0

var start_x: float
var direction := 1


func _ready():
	"""Called when the node enters the scene tree for the first time. Initializes the starting x-position of the platform."""
	start_x = position.x


func _process(delta):
	"""Called every frame. 'delta' is the elapsed time since the previous frame. Moves the platform back and forth horizontally."""
	position.x += direction * speed * delta

	if (
		abs(position.x - start_x) > move_distance
		or position.x < 0
		or position.x > Constants.SCREEN_WIDTH
	):
		direction *= -1
