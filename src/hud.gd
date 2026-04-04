extends CanvasLayer


signal start_game


func show_message(text: String) -> void:
	"""Shows a message and starts the timer to hide it after a delay."""
	$Message.text = text
	$Message.show()
	$MessageTimer.start()


func show_message_without_timer(text: String) -> void:
	"""Shows a message without starting the timer to hide it after a delay."""
	$Message.text = text
	$Message.show()
	$MessageTimer.stop()


func show_game_over(score: int) -> void:
	"""Displays the game over message and the player's score, then shows the start button to play again."""
	$ScoreLabel.hide()
	show_message("Game Over\nScore: " + str(score))
	
	await $MessageTimer.timeout

	show_message_without_timer("Endless\nPlatformer")

	$StartButton.show()
	$ScoreLabel.show()


func update_score(score: int) -> void:
	"""Updates the score display with the current score."""
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout() -> void:
	"""Hides the message when the timer times out."""
	$Message.hide()

func _on_start_button_pressed() -> void:
	"""Hides the start button and emits the signal to start the game."""
	$StartButton.hide()
	start_game.emit()
