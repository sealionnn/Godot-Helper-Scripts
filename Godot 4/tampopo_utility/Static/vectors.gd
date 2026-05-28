class_name Vectors extends Node

enum Facing {
	RIGHT,
	DOWN,
	LEFT,
	UP,
}

static func get_four_directions() -> Array:
	return [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]
	
static func get_random_vector_cardinal() -> Vector2:
	return get_four_directions().pick_random()

static func get_random_vector(snap: bool = false, min_x: float = -1.0, max_x: float = 1.0, min_y: float = -1.0, max_y: float = 1.0) -> Vector2:
	var vector: Vector2 = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
	if snap:
		vector.x = round(vector.x)
		vector.y = round(vector.y)
	return vector

static func clamp_to_four_dir(vec2: Vector2) -> Vector2:
	if vec2.is_zero_approx():
		return vec2
		
	if abs(vec2.x) > abs(vec2.y):
		if sign(vec2.x) == 1:
			return Vector2.RIGHT
		else:
			return Vector2.LEFT
	if sign(vec2.y) == 1:
		return Vector2.DOWN
	return Vector2.UP
		
static func get_four_direction_vector(diagonal_allowed: bool) -> Vector2:
	var velocity: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	elif Input.is_action_pressed("ui_right"):
		velocity.x += 1
	
	if diagonal_allowed or is_zero_approx(velocity.x):
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
		elif Input.is_action_pressed("ui_down"):
			velocity.y += 1
	
	return velocity

static func get_analog_vector() -> Vector2:
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

static func convert_vec2_to_facing_int(dir: Vector2) -> int:
	if dir.y < 0:
		return Facing.UP
	elif dir.y > 0:
		return Facing.DOWN
	elif dir.x < 0:
		return Facing.LEFT
	elif dir.x > 0:
		return Facing.RIGHT
	else:
		return Facing.DOWN # default
		
static func convert_facing_int_to_vec2(n: int) -> Vector2:
	match n:
		Facing.UP:
			return Vector2.UP
		Facing.DOWN:
			return Vector2.DOWN
		Facing.RIGHT:
			return Vector2.RIGHT
		Facing.LEFT:
			return Vector2.LEFT
	return Vector2.DOWN

static func convert_vec2_to_facing_string(dir: Vector2) -> String:
	var value: int = convert_vec2_to_facing_int(dir)
	var keys: Array = Facing.keys()
	for key in keys:
		if Facing[key] == value:
			return key
	return ""
