class_name TileMaps extends Node

const FLIP_H: int = TileSetAtlasSource.TRANSFORM_FLIP_H

static func roll_cell_flip_h() -> int:
	return FLIP_H if randf() > 0.5 else 0

static func get_surrounding_cells_four_dir(cell: Vector2) -> Array:
	var surrounding_cells: Array = []
	var target_cell: Vector2
	
	for dir in Vectors.get_four_directions():
		target_cell = cell + dir
		surrounding_cells.append(target_cell)
		
	return surrounding_cells

static func get_cells_in_area(_map: TileMapLayer, area: Vector2i) -> Array:
	var cells: Array = []
	for y in area.y:
		for x in area.x:
			cells.append(Vector2i(x, y))
	return cells

static func get_empty_cells_in_area(map: TileMapLayer, area: Vector2i) -> Array:
	var cells: Array = []
	var cell: Vector2i
	
	for y in area.y:
		for x in area.x:
			cell = Vector2i(x, y)
			if !map.get_cell_tile_data(cell):
				cells.append(cell)
	
	return cells
