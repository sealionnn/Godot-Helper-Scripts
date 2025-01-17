class_name Menu extends Control

signal button_pressed(button)
signal button_focused(button)

export var hide_on_start: bool = true
export var is_field_menu: bool = false
export var focus_on_start: bool = false
export var auto_disable_focus: bool = true
export var hide_on_focus_exit: bool = false 
export var button_container_path: NodePath = "MarginContainer/GridContainer"
export var use_vertical_centered_arrow: bool = false
export var autowrap: bool = true
export var use_arrow: bool = true

var focus_enabled: bool = false
var instant_cursor_move_once: bool = false
var index: int = 0
var wait_to_move_arrow: bool = true

onready var _button_container: Control = get_node_or_null(button_container_path)
#onready var _buttons: Array = [] setget set_buttons

func _ready() -> void:
	if name == "TopMenu":
		owner.set_top_menu(self)
	
	if _button_container == null:
		_button_container = self
#	set_buttons()
	connect_buttons()
	visible = !hide_on_start
	set_process_unhandled_key_input(is_field_menu)
	
	if focus_on_start:
		button_grab_focus(index, true)
	else:
		disable_focus()
		
	focus_enabled = focus_on_start
	pause_mode = PAUSE_MODE_INHERIT

func _unhandled_key_input(event: InputEventKey) -> void:
	if event.pressed and !event.echo:
		match event.scancode:
			KEY_M:
				visible = !visible
				if visible:
					button_grab_focus(0, true)
				else:
					ArrowBlinkingAuto.hide()
				Globals.player.set_enabled(!visible)
			_:
				return
		get_tree().set_input_as_handled()

func get_buttons() -> Array:
	return _button_container.get_children()
#	return _buttons

#func set_buttons() -> Array:
#	_buttons.clear()
#	for node in _button_container.get_children():
#		if node is BaseButton:
#			_buttons.append(node)
#	return _buttons
	
func button_connect(button: BaseButton) -> void:
#	print(name, "/", button_container_path)
#	print(_button_container.name)
	button.connect("focus_entered", self, "_on_Button_focus_entered", [button])
	button.connect("focus_exited", self, "_on_Button_focus_exited", [button])
	button.connect("pressed", self, "_on_Button_pressed", [button])

func set_focus_neighbors_to_auto_wrap(clear_first: bool = false) -> void: # TODO Fix for grids (poss only issue with > 2 col grid)
	if !autowrap:
		return
		
	if _button_container is GridContainer and _button_container.columns != 1:
		var buttons: Array = get_buttons()
		var top_row: Array = []
		var bottom_row: Array = []
		var cols: int = _button_container.columns
		var rows: int = round(buttons.size() / cols)
		var btm_range: Array = [rows * (cols - 1) - 1, rows * cols]
#		var btm_range: Array = [rows * (cols - 1) + 1, rows * cols]
		
		if clear_first:
			for button in buttons:
				button.focus_neighbour_top = null
				button.focus_neighbour_bottom = null
		
		# Get top and bottom rows of buttons.
		for x in cols:
#			print(buttons[x].text)
			top_row.append(buttons[x])
		for x in range(btm_range[0], btm_range[1]):
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
			top_button.focus_neighbour_top = bottom_button.get_path()
			bottom_button.focus_neighbour_bottom = top_button.get_path()
		
		# Repeat for left and right columns.	
		var left_column: Array = []
		var right_column: Array = []
		for i in range(0, buttons.size(), cols):
			left_column.append(buttons[i])
			right_column.append(buttons[i + cols - 1])
		
		for x in (cols - 1):
			var left_button: BaseButton = left_column[x]
			var right_button: BaseButton = right_column[x]
			left_button.focus_neighbour_left = right_button.get_path()
			right_button.focus_neighbour_right = left_button.get_path()
		
	elif _button_container is VBoxContainer:
		var buttons: Array = get_buttons()
		var top_button: BaseButton = buttons.front()
		var bottom_button: BaseButton = buttons.back()
		top_button.focus_neighbour_top = bottom_button.get_path()
		bottom_button.focus_neighbour_bottom = top_button.get_path()
	elif _button_container is HBoxContainer:
		var buttons: Array = get_buttons()
		var first_button: BaseButton = buttons.front()
		var last_button: BaseButton = buttons.back()
		first_button.focus_neighbour_left = last_button.get_path()
		last_button.focus_neighbour_right = first_button.get_path()

func button_grab_focus(p_index: int = index, p_instant_button_move_once: bool = false) -> void:
	p_index = Math.mini(p_index, _button_container.get_child_count())
	if _button_container.get_child_count() == 0:
		return
	
	show()
	instant_cursor_move_once = p_instant_button_move_once
	
	if !focus_enabled:
		enable_focus()
		
	while p_index > 0 and !_button_container.get_child(p_index).visible:
		p_index -= 1
	
	_button_container.get_child(p_index).grab_focus()

#	if get_focus_owner() is BaseButton:
#		yield(get_tree(), "idle_frame")
#		print(get_focus_owner().text)

func connect_buttons() -> void:
	for button in get_buttons():
		button_connect(button)
		button.mouse_filter = MOUSE_FILTER_IGNORE

func disable_focus() -> void:
	focus_enabled = false
	for button in get_buttons():
		button.focus_mode = FOCUS_NONE
#		print(button.text)
	if hide_on_focus_exit:
		visible = false
		
func enable_focus() -> void:
	for button in get_buttons():
		button.focus_mode = FOCUS_ALL
	set_focus_neighbors_to_auto_wrap()

func set_buttons_disabled(value: bool) -> void:
	for button in get_buttons():
		button.disabled = value

func get_first_visible_button() -> BaseButton:
	for button in get_buttons():
		if button.visible:
			return button
	return null

func get_first_hidden_button() -> BaseButton:
	for button in get_buttons():
		if !button.visible:
			return button
	return null

func find_button_by_text(text: String) -> BaseButton:
	for button in get_buttons():
		if button.text == text:
			return button
	return null

func child_button_has_focus() -> bool:
	var focus_owner: Control = get_focus_owner()
	for button in get_buttons():
		if button == focus_owner:
			return true
	return false

func grab_first_visible_button() -> void:
	get_first_visible_button().grab_focus()
	
func disable_button_by_name(text: String, on: bool) -> void:
	var button: BaseButton = find_button_by_text(text)
	if button != null:
		button.disabled = on

func _on_Button_focus_entered(button: BaseButton) -> void:
	var instant: bool = instant_cursor_move_once
	instant_cursor_move_once = false
	index = button.get_index()
	
#	print(button.rect_global_position)
	if wait_to_move_arrow:
		yield(get_tree(), "idle_frame")
	wait_to_move_arrow = true
#	print(button.rect_global_position)
	if use_arrow:
		ArrowBlinkingAuto.move(button, self, use_vertical_centered_arrow, instant)
	emit_signal("button_focused", button)

func _on_Button_focus_exited(_button: BaseButton) -> void:
	if auto_disable_focus:
		yield(get_tree(), "idle_frame")
		if child_button_has_focus():
			return
		disable_focus()
		if get_focus_owner() == null:
			ArrowBlinkingAuto.hide()

func _on_Button_pressed(button: BaseButton) -> void:
	emit_signal("button_pressed", button)
	yield(get_tree(), "idle_frame")
	if button == get_focus_owner():
		AudioManager.play_press()
