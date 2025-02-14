extends Sprite2D

var cell_size: Vector2 = Globals.CELL_SIZE

func _ready() -> void:
	show()

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	global_position.x -= int(global_position.x) % int(cell_size.x)
	global_position.y -= int(global_position.y) % int(cell_size.y)
	global_position = global_position.snapped(cell_size)
