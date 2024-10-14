class_name Menu extends Control

signal button_focused(button: BaseButton)
signal button_pressed(button: BaseButton)

@export var auto_wrap: bool = true

var index: int = 0
var exiting: bool = false

func _ready() -> void:
	tree_exiting.connect(_on_tree_exiting)
	
	# Connect to buttons.
	for button in get_buttons():
		button.focus_exited.connect(_on_Button_focus_exited.bind(button))
		button.focus_entered.connect(_on_Button_focused.bind(button))
		button.pressed.connect(_on_Button_pressed.bind(button))
		button.tree_exiting.connect(_on_Button_tree_exiting.bind(button))
	
	# Set focus neighbors.
	# TODO Fix for grids (poss only issue with > 2 col grid)	
	# NOTE Negative separation values will cause issues with auto neighbor focus for middle controls.
	if !auto_wrap:
		return
	
	var _class: String = get_class()
	var buttons: Array = get_buttons()
	var use_this_on_grid_containers: bool = false # hot fix
	
	if use_this_on_grid_containers and get("columns"): # GridContainer
		var top_row: Array = []
		var bottom_row: Array = []
		var cols: int = self.columns
		var rows: int = round(buttons.size() / cols)
		var btm_range: Array = [rows * cols - cols, rows * cols - 1]
#		var btm_range: Array = [rows * (cols - 1) + 1, rows * cols]

#		print(btm_range)

		#if clear_first:
			#for button in buttons:
				#button.focus_neighbor_top = null
				#button.focus_neighbor_bottom = null

		# Get top and bottom rows of buttons.
		for x in cols:
#			print(buttons[x].text)
			top_row.append(buttons[x])
		for x in range(btm_range[0], btm_range[1] + 1):
#			print(x)
			if x > buttons.size():
#				print(buttons[x - cols].text)
				bottom_row.append(buttons[x - cols])
				continue
#			print(buttons[x].text)
			bottom_row.append(buttons[x])

		# Change their focus neighbors accordingly.
		for x in cols:
			var top_button: BaseButton = top_row[x]
			var bottom_button: BaseButton = bottom_row[x]
#			print(top_button)
#			print(bottom_button)
			if top_button == bottom_button:
				continue
			top_button.focus_neighbor_top = bottom_button.get_path()
			bottom_button.focus_neighbor_bottom = top_button.get_path()

		# Repeat for left and right columns.	
		for i in range(0, buttons.size(), cols):
			var left_button: BaseButton = buttons[i]
			var right_button: BaseButton = buttons[i + cols - 1]
#			print(left_button, "...", right_button)
			left_button.focus_neighbor_left = right_button.get_path()
			right_button.focus_neighbor_right = left_button.get_path()
	elif _class.begins_with("VBox"):
		var top_button: BaseButton = buttons.front()
		var bottom_button: BaseButton = buttons.back()
		top_button.focus_neighbor_top = bottom_button.get_path()
		bottom_button.focus_neighbor_bottom = top_button.get_path()
	elif _class.begins_with("HBox"):
		var first_button: BaseButton = buttons.front()
		var last_button: BaseButton = buttons.back()
		first_button.focus_neighbor_left = last_button.get_path()
		last_button.focus_neighbor_right = first_button.get_path()
		
	button_enable_focus(false)

func get_buttons_count() -> int:
	return get_child_count()

func get_buttons() -> Array:
	return get_children()

func connect_to_buttons(target: Object, _name: String = name) -> void:
	var callable: Callable = Callable()
	callable = Callable(target, "_on_" + _name + "_focused")
	button_focused.connect(callable)
	callable = Callable(target, "_on_" + _name + "_pressed")
	button_pressed.connect(callable)

func button_enable_focus(on: bool) -> void:
	var mode: FocusMode = FocusMode.FOCUS_ALL if on else FocusMode.FOCUS_NONE
	for button in get_buttons():
		button.set_focus_mode(mode)

func button_focus(n: int = index) -> void:
	await get_tree().process_frame
	if get_buttons_count() > 0:
		button_enable_focus(true)
		n = clampi(n, 0, get_buttons_count()-1)
		var button: BaseButton = get_buttons()[n]
		button.grab_focus()

func _on_Button_focus_exited(_button: BaseButton) -> void:
	await get_tree().process_frame
	if exiting:
		return
		
	if not get_viewport().gui_get_focus_owner() in get_buttons():
		button_enable_focus(false)

func _on_Button_focused(button: BaseButton) -> void:
	index = button.get_index()
	emit_signal("button_focused", button)
		
func _on_Button_pressed(button: BaseButton) -> void:
	emit_signal("button_pressed", button)

func _on_Button_tree_exiting(button: BaseButton) -> void:
	if get_viewport().gui_get_focus_owner() == button:
		button_focus(index - 1)

func _on_tree_exiting() -> void:
	exiting = true
