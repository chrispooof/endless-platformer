extends Camera2D

@onready var player = get_parent()

var highest_y: float


func _ready() -> void:
	"""Called when the node enters the scene tree for the first time."""
	self.global_position.y = 0.0
	highest_y = Constants.SCREEN_HEIGHT


func _process(delta: float) -> void:
	"""
	Called every frame. 'delta' is the elapsed time since the previous frame.
	
	Locks the camera to the player's x-position and the highest y-position reached by the player.
	"""
	var player_y = player.position.y

	if player_y < highest_y:
		highest_y = player_y

	self.global_position.x = Constants.SCREEN_WIDTH / 2.0
	self.global_position.y = highest_y
