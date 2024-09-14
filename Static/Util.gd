class_name Util extends Node

const HIT_TEXT: PackedScene = preload("res://Utility/HitText.tscn")
const SCREEN_FLASH: PackedScene = preload("res://Utility/ScreenFlash.tscn")

static func create_hit_text(target_node: Control, owner_node: Node, value: int, type: int = HitText.BOUNCING) -> void:
	var inst: HitText = HIT_TEXT.instance()
	owner_node.add_child(inst)
	inst.init(value, target_node, type)
	
static func screen_flash(node: Node, animation: String, use_owner: bool) -> ScreenFlash:
	var inst: ScreenFlash = SCREEN_FLASH.instance()
	if use_owner and node.owner != null:
		node.owner.add_child(inst)
	else:
		node.add_child(inst)
		
	inst.play(animation)
	return inst

static func interweave_arrays(arr1: Array, arr2: Array) -> Array:
	var arr3: Array = []
	if arr1.size() != arr2.size():
		print("Error: Arrays must have matching sizes for interweave_arrays().")
	else:
		for i in range(arr1.size()):
			arr3.append(arr1[i])
			arr3.append(arr2[i])
	return arr3

static func choose(choices: Array):
	return choices[randi() % choices.size()]

static func choose_weighted(choices: Array):
	# choices = [variant, chance(int), variant, chance(int)...]
	var n = 0
	var choices_size: int = choices.size()
	for i in range(1, choices_size, 2):
		if choices[i] <= 0:
			continue
		n += choices[i]
	
	n = randi() % n
	for i in range(1, choices_size, 2):
		if choices[i] <= 0:
			continue
		n -= choices[i]
		if n < 0:
			return choices[i - 1]
	return choices[0]
	
#static func choose_weighted(choices: Array, chances: Array):
#	# Credit: https://yal.cc/gamemaker-weighted-choose/
#	# Modified by me to split choices and chances.
#	# choices = [variant, chance(int), variant, chance(int)...]
#	var n = 0
#	var choices_size: int = choices.size()
#	for i in range(1, choices_size, 2):
#		if choices[i] <= 0:
#			continue
#		n += chances[i]
#
#	n = randi() % n
#	for i in range(1, choices_size, 2):
#		if choices[i] <= 0:
#			continue
#		n -= chances[i]
#		if n < 0:
#			print(choices[i])
#			return choices[i]
#	print(choices[0])
#	return choices[0]

static func audio_play_varied_pitch(node: AudioStreamPlayer, base_range: float = 0.1) -> void:
	var base: float = 1.0
	node.pitch_scale = rand_range(base - base_range, base + base_range)
	node.play()

static func audio_play_varied_pitch_2d(node: AudioStreamPlayer2D, base_range: float = 0.1) -> void:
	var base: float = 1.0
	node.pitch_scale = rand_range(base - base_range, base + base_range)
	node.play()

static func set_keys_to_names(dict: Dictionary) -> void:
	var keys: Array = dict.keys()
	if dict[keys[0]] is Reference:
		for key in keys:
			dict[key].set_name(key)
	else:
		print("Error: Dictionary must have instanced references in it. Exiting convert_keys_to_names()...")

static func array_random(arr: Array):
	return arr[randi() % arr.size()]

static func dictionary_random(dict: Dictionary):
	return dict.values()[randi() % dict.size()]

static func vec2_to_array(vec2: Vector2) -> Array:
	return [vec2.x, vec2.y]
	
static func array_to_vec2(array: Array) -> Vector2:
	return Vector2(array[0], array[1])

static func vec2_to_key(vec2: Vector2) -> String:
	return str(vec2.x) + "," + str(vec2.y)

static func vec2_key_to_vec2(key: String) -> Vector2:
	var string_array: PoolStringArray = key.split(",")
	var vec2: Vector2 = Vector2.ZERO
	
	vec2.x = int(string_array[0])
	vec2.y = int(string_array[1])

	return vec2

# credit: hiulit @ https://gist.github.com/hiulit/9c13e15b7a3bd8a2afa28641323e3731
static func get_surrounding_cells(cell: Vector2, length: int = 3) -> Array:
	var surrounding_cells: Array = []
	var target_cell: Vector2
	
	length = int(max(length, 3)) # Does not work with length less than 3.

	for y in length:
		for x in length:
			target_cell = cell + Vector2(x - 1, y - 1)

			if cell == target_cell:
				continue

			surrounding_cells.append(target_cell)
	
	return surrounding_cells
	
# Alt for above, quoted:
#What I usually do is define an array of neighbouring tiles
#var neighbours = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
#And then iterate through them
#for n in neighbours: do_whatever(current_coord + n)
#You way absolutely works but I often find I just need cardinal directions or need to prioritise left & right neighbours and this way I can order them as necessary.	

static func get_four_directions() -> Array:
	return [Vector2.UP, Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT]

static func get_surrounding_cells_four_dir(cell: Vector2) -> Array:
	var surrounding_cells: Array = []
	var target_cell: Vector2
	
	for dir in get_four_directions():
		target_cell = cell + dir
		surrounding_cells.append(target_cell)
		
	return surrounding_cells

static func timer_is_running(timer: Timer) -> bool:
	return !timer.is_stopped()

static func reparent(node: Node, new_parent: Node, zero_pos: bool = false) -> void:
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	if zero_pos:
		node.position = Vector2.ZERO

static func convert_int_array_to_bool_array(arr1: Array) -> Array:
	var arr2: Array = []
	for value in arr1:
		arr2.append(value > 0)
	return arr2
