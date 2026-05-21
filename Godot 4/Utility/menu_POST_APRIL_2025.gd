# Use this version of menu.gd for new projects or following along with my videos that are from April 2025 onward.

class_name Menu extends Control

signal button_focused(button: BaseButton, index: int)
signal button_pressed(button: BaseButton, index: int)
signal activated()
signal closed()

const MENU_CURSOR: PackedScene = preload("res://Utility/menu_cursor.tscn")

@export var auto_wrap: bool = true
@export var buttons_container: Control = null
@export var focus_on_ready: bool = false
@export var hide_on_start: bool = false
@export var hide_on_focus_exit: bool = false
@export var hide_on_close: bool = false
@export var is_dummy: bool = false
@export var focused_sound: AudioStream
@export var pressed_sound: AudioStream

static var tree: Array[Menu] = []

var index: int = 0
var exiting: bool = false
var highlight_all: bool = false
var buttons: Array = []
var stream_player: AudioStreamPlayer = AudioStreamPlayer.new()
var menu_cursor: MenuCursor = MENU_CURSOR.instantiate()

func _ready() -> void:
	set_process_unhandled_input(false)
	if !is_dummy:
		assert(buttons_container != null, "buttons_container not set on menu " + name + ". ")
	
	tree_exiting.connect(_on_tree_exiting)
	activated.connect(_on_activated)
	
	if not closed.is_connected(_on_closed):
		closed.connect(_on_closed)
	
	if is_dummy:
		return
		
	# Set up buttons.
	var child: Control
	var button: BaseButton
	var children: Array = buttons_container.get_children()
	for i in range(children.size()):
		child = children[i]
		
		if child is BaseButton:
			button = child
		else:
			button = child.get_child(0)
		
		button.mouse_entered.connect(button.grab_focus)
		#button.mouse_exited.connect(button.release_focus)
		button.focus_entered.connect(_on_button_focused.bind(button, i))
		button.focus_exited.connect(_on_button_focus_exited.bind(button))
		button.pressed.connect(_on_button_pressed.bind(button, i))
		button.tree_exiting.connect(_on_button_tree_exiting.bind(button))
		buttons.append(button)
		#print(button.text)
		
	_set_focus_neighbors()
		
	button_enable_focus(false)
	
	button_focused.connect(menu_cursor._on_menu_button_focused)
	closed.connect(menu_cursor._on_menu_closed)
	add_child(menu_cursor)
	add_child(stream_player)
	
	if focus_on_ready:
		button_focus()
		
	visible = not hide_on_start

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		button_enable_focus(false)
		#visible = !hide_on_focus_exit
		if hide_on_close:
			hide()
		closed.emit()
		get_viewport().set_input_as_handled()

func _set_focus_neighbors() -> void:
	# TODO Add support for GridContainers with columns > 2.
	# NOTE This does not work with GridContainers that have columns > 2.
	# NOTE Negative separation values will cause issues with auto neighbor focus for middle controls.
	# NOTE This could be optimized a bit, but it is not a huge deal since it runs once per menu, but...
	# TODO Need to add a way to queue this anytime we are changing the buttons_container's contents.
	await(get_tree().process_frame) # In case we modify buttons on _ready elsewhere.
	
	var buttons: Array[Node] = get_buttons()
	var _class: String = buttons_container.get_class()
	
	match _class:
		"GridContainer":
			var top_row: Array = []
			var bottom_row: Array = []
			var cols: int = buttons_container.columns
			@warning_ignore("integer_division")
			var rows: int = roundi(buttons.size() / cols)
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
				
				if auto_wrap:
					top_button.focus_neighbor_top = bottom_button.get_path()
					top_button.focus_previous = bottom_button.get_path()
					bottom_button.focus_neighbor_bottom = top_button.get_path()
					bottom_button.focus_next = top_button.get_path()
				else:
					# Keep focus on this one.
					top_button.focus_neighbor_top = top_button.get_path()
					top_button.focus_previous = top_button.get_path()
					bottom_button.focus_neighbor_bottom = bottom_button.get_path()
					bottom_button.focus_next = bottom_button.get_path()
			
			# Repeat for left and right columns.	
			for i in range(0, buttons.size(), cols):
				var left_button: BaseButton = buttons[i]
				var right_button: BaseButton = buttons[i + cols - 1]
	#			print(left_button, "...", right_button)
				left_button.focus_neighbor_left = right_button.get_path()
				right_button.focus_neighbor_right = left_button.get_path()
		"VBoxContainer", "HBoxContainer":
			var first_button: BaseButton = buttons.front()
			var last_button: BaseButton = buttons.back()
			var first_button_path: NodePath = first_button.get_path()
			var last_button_path: NodePath = last_button.get_path()
			var first_neighbor_key: String = "focus_neighbor_left"
			var last_neighbor_key: String = "focus_neighbor_right"
			var path: NodePath = ""
			
			if _class == "VBoxContainer":
				first_neighbor_key = "focus_neighbor_top"
				last_neighbor_key = "focus_neighbor_bottom"
				
				for button: Node in buttons:
					path = button.get_path()
					button.focus_neighbor_left = path
					button.focus_neighbor_right = path
			else:
				for button: Node in buttons:
					path = button.get_path()
					button.focus_neighbor_top = path
					button.focus_neighbor_bottom = path
			
			first_button.set(first_neighbor_key, last_button_path)
			first_button.focus_previous = last_button_path
			last_button.set(last_neighbor_key, first_button_path)
			last_button.focus_next = first_button_path

func _close_menus_in_front_of_self() -> void:
	var tree_pos: int = tree.rfind(self)
	if tree_pos <= 0:
		return
		
	for i in range(tree.size() - 1, tree_pos, -1):
		tree.back().close()

func set_highlight_all(on: bool) -> void:
	highlight_all = on
		
func get_buttons_count() -> int:
	if !buttons_container:
		return 0
	return buttons_container.get_child_count()

func get_buttons() -> Array:
	return buttons

func get_first_focusable_button(and_focus: bool) -> BaseButton:
	for button in get_buttons():
		if button.visible and !button.disabled:
			if and_focus:
				button.grab_focus()
			return button
	return null

func connect_to_buttons(target: Object, _name: String = name) -> void:
	_name = _name.to_lower()
	
	var callable: Callable = Callable()
	callable = Callable(target, "_on_" + _name + "_button_focused")
	button_focused.connect(callable)
	callable = Callable(target, "_on_" + _name + "_button_pressed")
	button_pressed.connect(callable)

func menu_is_focused() -> bool:
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	
	for button in get_buttons():
		if button == focus_owner:
			return true
	return false

func in_menu_tree() -> bool:
	return tree.has(self)

func button_enable_focus(on: bool) -> void:
	var mode: FocusMode = FocusMode.FOCUS_ALL if on else FocusMode.FOCUS_NONE
	for button in get_buttons():
		button.set_focus_mode(mode)
	
	if hide_on_focus_exit:	
		visible = on
		
	set_process_unhandled_input(on)
	Globals.menu_has_focus = on
	#print(name + " is " + "on" if on else name + " is " + "off")

func button_focus(n: int = index) -> void:
	if !menu_is_focused():
		activated.emit()
	
	await get_tree().process_frame
	show()
	button_enable_focus(true)
	
	if get_buttons_count() > 0:
		n = clampi(n, 0, get_buttons_count()-1)
		var button: BaseButton = buttons[n]
		
		if button.is_inside_tree():
			if button.visible:
				button.grab_focus()
			else:
				get_first_focusable_button(true)
	else:
		var focus_owner: Control = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

func disable_all(on: bool = true) -> void:
	# WARNING not fully tested
	for button: BaseButton in get_buttons():
		button.disabled = on

func release() -> void:
	button_enable_focus(false)

func close() -> bool:
	if in_menu_tree():
		var button: BaseButton = buttons[index]
		button.release_focus()
		closed.emit()
		if hide_on_close:
			hide()
		return true
	return false

func _on_button_focused(button: BaseButton, button_index: int) -> void:
	index = button_index
	emit_signal("button_focused", button, index)
	
	if focused_sound:
		stream_player.stream = focused_sound
		stream_player.play()
	
	if highlight_all:
		for node in get_buttons():
			node.highlight(true)
	
func _on_button_focus_exited(_button: BaseButton) -> void:
	await get_tree().process_frame
	
	if exiting:
		return
		
	if not get_viewport().gui_get_focus_owner() in get_buttons():
		button_enable_focus(false)
		
		if highlight_all:
			for node in get_buttons():
				node.highlight(false)
		set_highlight_all(false)

func _on_button_pressed(button: BaseButton, button_index: int) -> void:
	if pressed_sound:
		stream_player.stream = pressed_sound
		stream_player.play()
		
	emit_signal("button_pressed", button, button_index)

func _on_button_tree_exiting(button: BaseButton) -> void:
	if get_viewport().gui_get_focus_owner() == button:
		button_focus(index - 1)

func _on_tree_exiting() -> void:
	exiting = true

func _on_activated() -> void:
	#print("activating ", name)
	if in_menu_tree():
		pass
		#_close_menus_in_front_of_self()
	else:
		tree.append(self)

func _on_closed() -> void:
	#print("closing ", name)
	_close_menus_in_front_of_self()
	tree.pop_back()
	
	if tree:
		tree.back().button_focus()
