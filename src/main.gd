extends Node2D

@onready var player = preload("res://scenes/player.tscn")
@onready var player_container = $Player

@onready var platforms_container = $Platforms
@onready var platform = preload("res://scenes/platform.tscn")
@onready var breakable_platform = preload("res://scenes/breakable_platform.tscn")
@onready var vertical_moving_platform = preload("res://scenes/vertical_moving_platform.tscn")

@onready var hud = $HUD
@onready var start_position = $StartPosition

var highest_y := 0.0
var score := 0
var playing := Types.GameState.START
var new_player: CharacterBody2D

var last_platform_type := Types.PlatformType.NORMAL
var distance_since_safe := 0.0
var current_pattern := Types.Pattern.RANDOM
var pattern_steps_remaining := 0
var zigzag_direction := 1
var last_position := Vector2.ZERO


func _ready() -> void:
	"""Called when the node enters the scene tree for the first time."""
	$Platform.hide()
	hud.start_game.connect(new_game)


func _process(delta: float) -> void:
	"""Called every frame. 'delta' is the elapsed time since the previous frame."""
	if playing != Types.GameState.PLAYING:
		return

	if new_player.position.y < highest_y:
		highest_y = new_player.position.y

	score = int(abs(highest_y - start_position.position.y) / 10)
	hud.update_score(score)

	if new_player.position.y < (last_position.y + start_position.position.y):
		spawn_platform()

	for platform_inst in platforms_container.get_children():
		if platform_inst.position.y > (new_player.position.y + 400.0):
			platform_inst.queue_free()


func new_game() -> void:
	"""Resets the game state to start a new game."""
	$HUD/Message.hide()
	$Platform.show()

	# Initialize a new player instance and connect the died signal to the game_over function.
	new_player = player.instantiate()
	new_player.died.connect(game_over)
	new_player.get_node("Camera2D").highest_y = start_position.position.y
	new_player.position = start_position.position
	player_container.add_child(new_player)
	new_player.show()

	last_position = new_player.position

	while last_position.y > 0.0:
		spawn_platform()

	highest_y = new_player.position.y
	score = 0
	hud.update_score(score)
	playing = Types.GameState.PLAYING


func game_over() -> void:
	"""End the game when the player falls below the screen."""
	playing = Types.GameState.GAME_OVER
	new_player.hide()
	new_player.queue_free()

	for platform_inst in platforms_container.get_children():
		platform_inst.queue_free()

	$Platform.hide()
	hud.show_game_over(score)


func get_next_position(progress: float) -> Vector2:
	var vertical_gap = randf_range(60.0, Constants.MAX_JUMP_HEIGHT)

	# Bias harder over time
	vertical_gap = lerp(vertical_gap, Constants.MAX_JUMP_HEIGHT, progress)

	var horizontal_offset = randf_range(-Constants.MAX_JUMP_WIDTH, Constants.MAX_JUMP_WIDTH)

	return Vector2(
		clamp(last_position.x + horizontal_offset, 25.0, Constants.SCREEN_WIDTH - 25.0),
		last_position.y - vertical_gap
	)


func get_pattern_position(progress: float) -> Vector2:
	if pattern_steps_remaining <= 0:
		current_pattern = RNG.choose_pattern()
		pattern_steps_remaining = randi_range(3, 6)

	pattern_steps_remaining -= 1

	match current_pattern:
		Types.Pattern.ZIGZAG:
			zigzag_direction *= -1
			return Vector2(
				clamp(
					last_position.x + zigzag_direction * Constants.MAX_JUMP_WIDTH * 0.8,
					25,
					Constants.SCREEN_WIDTH - 25
				),
				last_position.y - randf_range(20, Constants.MAX_JUMP_HEIGHT)
			)

		Types.Pattern.VERTICAL:
			return Vector2(
				last_position.x, last_position.y - randf_range(20, Constants.MAX_JUMP_HEIGHT)
			)

		Types.Pattern.REST:
			return Vector2(randf_range(25, Constants.SCREEN_WIDTH - 25), last_position.y - 60.0)

		_:
			return get_next_position(progress)


func spawn_platform() -> void:
	"""Spawns a new platform at a random x-position and a y-position above the highest spawn point."""
	var progress = clamp(abs(last_position.y) / 2000.0, 0.0, 1.0)

	var next_pos = get_pattern_position(progress)

	var gap = abs(next_pos.y - last_position.y)
	distance_since_safe += gap

	var type = RNG.choose_platform_type(progress, last_platform_type, score, distance_since_safe)

	if type == Types.PlatformType.NORMAL:
		distance_since_safe = 0.0

	last_platform_type = type
	last_position = next_pos

	var scene: PackedScene
	match type:
		Types.PlatformType.NORMAL:
			scene = platform
		Types.PlatformType.DISAPPEARING:
			scene = breakable_platform
		Types.PlatformType.MOVING:
			scene = vertical_moving_platform

	var new_platform = scene.instantiate()
	new_platform.position = next_pos

	platforms_container.add_child(new_platform)
	new_platform.show()
