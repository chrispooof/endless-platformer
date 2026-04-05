extends CanvasLayer

signal start_game


func show_message(text: String, font_size: int = 64) -> void:
	"""Shows a message and starts the timer to hide it after a delay."""
	$Message.text = text
	$Message.add_theme_font_size_override("font_size", font_size)
	$Message.show()
	$MessageTimer.start()


func show_message_without_timer(text: String, font_size: int = 64) -> void:
	"""Shows a message without starting the timer to hide it after a delay."""
	$Message.text = text
	$Message.add_theme_font_size_override("font_size", font_size)
	$Message.show()
	$MessageTimer.stop()


func show_game_over(score: int) -> void:
	"""Displays the game over message and the player's score, then shows the start button to play again."""
	$ScoreLabel.hide()
	show_message("Game Over\nScore: " + str(score))

	await $MessageTimer.timeout

	show_message_without_timer("Endless\nPlatformer")

	$StartButton.show()
	$InfoButton.show()
	$ScoreLabel.show()


func update_score(score: int) -> void:
	"""Updates the score display with the current score."""
	$ScoreLabel.text = str(score)


func show_instructions() -> void:
	"""Shows the game instructions."""
	show_message_without_timer(
		"Use the arrow keys to move left and right.\nPress the spacebar to jump.\nTry to climb as high as you can!",
		19
	)


func _on_message_timer_timeout() -> void:
	"""Hides the message when the timer times out."""
	$Message.hide()


func _on_start_button_pressed() -> void:
	"""Hides the start button and emits the signal to start the game."""
	$StartButton.hide()
	$InfoButton.hide()
	start_game.emit()


func _on_info_button_pressed() -> void:
	"""Hides the info button and shows the instructions."""
	$InfoButton.hide()
	show_instructions()
