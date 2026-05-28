extends Sprite2D

signal left_pressed(pos: Vector2)
signal right_pressed(pos: Vector2)

var left_held: bool = false
var right_held: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	show()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				left_held = event.pressed
			MOUSE_BUTTON_RIGHT:
				right_held = event.pressed

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if left_held:
		left_pressed.emit(global_position)
	if right_held:
		right_pressed.emit(global_position)
