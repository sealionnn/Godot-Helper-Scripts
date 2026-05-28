class_name MenuCursor extends Sprite2D

@export var base_offset: Vector2 = Vector2(0, 5)
@export var follow_viewport_focus: bool = false

var target: Node = null

@onready var size_offset: Vector2 = texture.get_size() * -0.5
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	offset = base_offset + size_offset
	
	if follow_viewport_focus:
		get_viewport().gui_focus_changed.connect(_on_viewport_gui_focus_changed)
	
	stop()
	
func _process(_delta: float) -> void:
	global_position = target.global_position + Vector2(offset.x, offset.y + target.size.y * 0.5)

func update_target(node: Control) -> void:
	#print(node.name)
	if node is BaseButton:
		if target:
			target.tree_exiting.disconnect(_on_target_tree_exiting)
			target.focus_exited.disconnect(_on_target_focus_exited)
		
		target = node
		
		if !target.tree_exiting.is_connected(_on_target_tree_exiting):
			target.tree_exiting.connect(_on_target_tree_exiting.bind(target))
			target.focus_exited.connect(_on_target_focus_exited.bind(target))
		
		show()
		set_process(true)
		animation_player.play("RESET")
	else:
		stop()

func stop() -> void:
	target = null
	set_process(false)
	hide()

func _on_viewport_gui_focus_changed(node: Control) -> void:
	update_target(node)

func _on_menu_button_focused(button: BaseButton, _index: int) -> void:
	update_target(button)

func _on_target_tree_exiting(node: Control) -> void:
	if node == target:
		stop()

func _on_target_focus_exited(node: Control) -> void:
	if node == target:
		if follow_viewport_focus:
			stop()
		else:
			animation_player.play("blink")

func _on_menu_closed() -> void:
	await(get_tree().process_frame)
	stop()
