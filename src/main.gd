extends Node2D

@onready var player = preload("res://scenes/Player.tscn")
@onready var player_container = $Player
@onready var start_position = $StartPosition
@onready var platforms_container = $Platforms
@onready var platform = preload("res://scenes/Platform.tscn")
@onready var hud = $HUD


var highest_spawn_y := 0.0
var highest_y := 0.0
var score := 0
var playing := false
var new_player: CharacterBody2D


func _ready() -> void:
	"""Called when the node enters the scene tree for the first time."""
	$Platform.hide()
	hud.start_game.connect(new_game)


func _process(delta: float) -> void:
	"""Called every frame. 'delta' is the elapsed time since the previous frame."""
	if not playing:
		return

	if new_player.position.y < highest_y:
		highest_y = new_player.position.y

	score = int(abs(highest_y - start_position.position.y) / 10)
	hud.update_score(score)

	if new_player.position.y < (highest_spawn_y + start_position.position.y):
		spawn_platform()

	for platform_inst in platforms_container.get_children():
		if platform_inst.position.y > (new_player.position.y + 400.0):
			platform_inst.queue_free()


func new_game() -> void:
	"""Resets the game state to start a new game."""
	$HUD/MessageTimer.start()
	$Platform.show()
	
	# Initialize a new player instance and connect the died signal to the game_over function.
	new_player = player.instantiate()
	new_player.died.connect(game_over)
	new_player.get_node("Camera2D").highest_y = start_position.position.y
	new_player.position = start_position.position
	player_container.add_child(new_player)
	new_player.show()
	
	highest_spawn_y = new_player.position.y

	while highest_spawn_y > 0.0:
		spawn_platform()

	highest_y = new_player.position.y
	score = 0
	hud.update_score(score)
	playing = true


func game_over() -> void:
	"""End the game when the player falls below the screen."""
	playing = false
	new_player.hide()
	new_player.queue_free()

	for platform_inst in platforms_container.get_children():
		platform_inst.queue_free()
	
	$Platform.hide()
	hud.show_game_over(score)



func spawn_platform() -> void:
	"""Spawns a new platform at a random x-position and a y-position above the highest spawn point."""
	var new_platform = platform.instantiate()

	highest_spawn_y -= randf_range(20.0, 40.0)
	var random_x = randf_range(25.0, Constants.SCREEN_WIDTH - 25.0)

	new_platform.position = Vector2(random_x, highest_spawn_y)

	platforms_container.add_child(new_platform)

	new_platform.show()
