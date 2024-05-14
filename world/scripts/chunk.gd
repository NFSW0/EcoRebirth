class_name Chunk
extends Resource

var chunk_pos: Vector2i
var chunk_data := {"map_grids":{}}

func _init(_chunk_pos:Vector2i):
	chunk_pos = _chunk_pos

func get_chunk_pos() -> Vector2i:
	return chunk_pos

# 覆盖或注册区块数据
func update_chunk_data(data_key: String, data_value):
	if data_value == null:
		remove_chunk_data(data_key)
		return
	chunk_data[data_key] = data_value

func get_chunk_data() -> Dictionary:
	return chunk_data

func remove_chunk_data(data_key: String):
	if not data_key in chunk_data:
		return
	chunk_data.erase(data_key)
