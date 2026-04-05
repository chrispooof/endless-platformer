class_name RNG


static func choose_weighted_platform(progress: float) -> Types.PlatformType:
	"""Chooses a platform type to spawn based on the player's progress."""
	var normal_weight = max(0.2, lerp(1.0, 0.2, progress))
	var breakable_weight = lerp(0.1, 0.6, progress)
	var moving_weight = lerp(0.0, 0.5, progress)

	var total = normal_weight + breakable_weight + moving_weight
	var roll = randf() * total

	if roll < normal_weight:
		return Types.PlatformType.NORMAL
	elif roll < normal_weight + breakable_weight:
		return Types.PlatformType.DISAPPEARING
	else:
		return Types.PlatformType.MOVING


static func choose_pattern() -> Types.Pattern:
	"""Chooses a platform pattern to spawn."""
	var roll = randf()

	if roll < 0.4:
		return Types.Pattern.RANDOM
	elif roll < 0.7:
		return Types.Pattern.ZIGZAG
	elif roll < 0.9:
		return Types.Pattern.VERTICAL
	else:
		return Types.Pattern.REST


static func choose_platform_type(
	progress: float, last_platform_type: Types.PlatformType, score: int, distance_since_safe: float
) -> Types.PlatformType:
	"""Chooses a platform type to spawn based on the player's progress, 
    last platform type, score, and distance since the last safe platform. 
    Applies rules to ensure a fair and enjoyable gameplay experience.
    """
	var type = choose_weighted_platform(progress)

	# RULES
	if (
		type == Types.PlatformType.DISAPPEARING
		and last_platform_type == Types.PlatformType.DISAPPEARING
	):
		type = Types.PlatformType.NORMAL

	if score < 200 and type == Types.PlatformType.MOVING:
		type = Types.PlatformType.NORMAL

	if distance_since_safe > 120:
		type = Types.PlatformType.NORMAL

	return type
