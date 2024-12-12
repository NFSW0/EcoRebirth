class_name MapGrid
extends Resource

var grid_pos: Vector2i
var grid_data := {}

func _init(_grid_pos:Vector2i):
	grid_pos = _grid_pos

func get_grid_pos() -> Vector2i:
	return grid_pos

# 覆盖或注册图格数据
func update_grid_data(data_key: String, data_value):
	if data_value == null:
		remove_grid_data(data_key)
		return
	grid_data[data_key] = data_value

func get_grid_data():
	return grid_data

func remove_grid_data(data_key: String):
	if not data_key in grid_data:
		return
	grid_data.erase(data_key)

func to_data() -> Dictionary:
	var data = {}
	data["grid_pos"] = grid_pos
	data["grid_data"] = grid_data
	return data

static func new_from_data(data: Dictionary) -> MapGrid:
	var saved_grid_pos = data.get("grid_pos",Vector2i())
	var new_map_grid:MapGrid = MapGrid.new(saved_grid_pos if saved_grid_pos is Vector2i else DataTool.parse_vector2i(saved_grid_pos))
	
	new_map_grid.grid_data = data.get("grid_data",{})
	return new_map_grid
