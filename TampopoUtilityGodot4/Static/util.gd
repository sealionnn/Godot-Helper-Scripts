class_name Util extends Node

static func get_enum_key_at_index(enumerator: Dictionary, index: int) -> String:
	return enumerator.keys()[index]

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
	
	n = randi() % int(n) # this was prev not int()
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
	if !node:
		return
	var base: float = 1.0
	node.pitch_scale = randf_range(base - base_range, base + base_range)
	node.play()

static func audio_play_varied_pitch_2d(node: AudioStreamPlayer2D, base_range: float = 0.1, seek: float = 0.0) -> void:
	var base: float = 1.0
	node.pitch_scale = randf_range(base - base_range, base + base_range)
	node.play(seek)

static func set_keys_to_names(dict: Dictionary) -> void:
	var keys: Array = dict.keys()
	#print(keys)
	if dict[keys[0]] is RefCounted:
		for key in keys:
			dict[key].name = key
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

#static func vec2_key_to_vec2(key: String) -> Vector2:
	#var string_array: PoolStringArray = key.split(",")
	#var vec2: Vector2 = Vector2.ZERO
	#
	#vec2.x = int(string_array[0])
	#vec2.y = int(string_array[1])
#
	#return vec2

static func unparse_vec2_dictionary(dict: Dictionary) -> Dictionary:
	var new_dict: Dictionary = {}
	var keys: Array = dict.keys()
	for key in keys:
		new_dict[vec2_to_key(key)] = dict[key]
	return new_dict

#static func parse_vec2_dictionary(dict: Dictionary) -> Dictionary:
	#var new_dict: Dictionary = {}
	#var keys: Array = dict.keys()
	#for key in keys:
		#new_dict[vec2_key_to_vec2(key)] = dict[key]
	#return new_dict

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

static func timer_is_running(timer: Timer) -> bool:
	return !timer.is_stopped()

static func convert_int_array_to_bool_array(arr1: Array) -> Array:
	var arr2: Array = []
	for value in arr1:
		arr2.append(value > 0)
	return arr2
