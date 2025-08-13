class_name Arrays extends Node


static func interweave_arrays(arr1: Array, arr2: Array) -> Array:
	var arr3: Array = []
	if arr1.size() != arr2.size():
		print("Error: Arrays must have matching sizes for interweave_arrays().")
	else:
		for i in range(arr1.size()):
			arr3.append(arr1[i])
			arr3.append(arr2[i])
	return arr3

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


static func convert_int_array_to_bool_array(arr1: Array) -> Array:
	var arr2: Array = []
	for value in arr1:
		arr2.append(value > 0)
	return arr2
