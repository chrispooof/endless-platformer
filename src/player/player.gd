extends CharacterBody2D

signal died


func _physics_process(delta: float) -> void:
	"""Called every physics frame. 'delta' is the elapsed time since the previous physics frame."""
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle collisions with breakable platforms.
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("breakable_platform"):
			velocity.y = Constants.JUMP_VELOCITY
			collider.queue_free()
		elif collider.is_in_group("vertical_moving_platform"):
			position.x += collider.speed * delta * collider.direction

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = Constants.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * Constants.SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, Constants.SPEED)

	move_and_slide()


func _process(delta: float) -> void:
	"""Called every frame. 'delta' is the elapsed time since the previous frame."""
	var highest_y = get_parent().get_parent().highest_y

	if position.y > highest_y + 320:
		emit_signal("died")
