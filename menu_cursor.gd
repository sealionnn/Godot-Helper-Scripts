# This is a Godot 4 variant menu cursor that automatically follows the focus of the GUI target.
# How to use it: add to a scene and give it a sprite. Adjust OFFSET based on your needs.
# By Tampopo Interactive Media

class_name MenuCursor extends TextureRect

const OFFSET: Vector2 = Vector2(-16, -2)

var target: Node = null

func _enter_tree() -> void:
	Menus.menu_cursor = self

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_viewport_gui_focus_changed)
	stop()
	
func _process(_delta: float) -> void:
	if target is TextureButton:
		global_position = target.global_position + Vector2(OFFSET.x, target.size.y * 0.5)
	else:
		global_position = target.global_position + OFFSET

func stop() -> void:
	target = null
	set_process(false)
	hide()

func _on_viewport_gui_focus_changed(node: Control) -> void:
	#print(node.name)
	if node is BaseButton:
		if target:
			target.tree_exiting.disconnect(_on_target_tree_exiting)
		
		target = node
		
		if !target.tree_exiting.is_connected(_on_target_tree_exiting):
			target.tree_exiting.connect(_on_target_tree_exiting.bind(target))
			
		show()
		set_process(true)
	else:
		hide()
		set_process(false)

func _on_target_tree_exiting(node: Control) -> void:
	if node == target:
		stop()
