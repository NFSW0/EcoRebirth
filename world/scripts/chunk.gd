class_name Chunk
extends Resource

var chunk_pos: Vector2i
var chunk_data := {"map_grids": {}} # 区块数据，目前包含图格数据和区块的生物数据

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

func to_data() -> Dictionary:
	var data = {}
	data["chunk_data"] = _to_data(chunk_data)
	data["chunk_pos"] = chunk_pos
	return data

func _to_data(dic:Dictionary):
	var packed_data = {}
	for key in dic.keys():
		var d = dic.get(key)
		if d:
			if d is Dictionary:
				var da = _to_data(d)
				packed_data[key] = da
			else:
				if d is Resource:
					if d.has_method("to_data"):
						packed_data[key] = d.to_data()
					else:
						var message = "%s缺少序列化方法to_data" % type_string(typeof(d))
						LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
				else:
					packed_data[key] = d
		else:
			continue
	return packed_data

static func new_from_data(data: Dictionary) -> Chunk:
	var _chunk_pos = data.get("chunk_pos", Vector2i())
	var new_chunk = Chunk.new(_chunk_pos if _chunk_pos is Vector2i else DataTool.parse_vector2i(_chunk_pos))
	
	var _chunk_data = data.get("chunk_data", {})
	new_chunk.chunk_data = _new_from_data(_chunk_data)
	
	return new_chunk

static func _new_from_data(packed_data: Dictionary) -> Dictionary:
	var dic = {}
	for key in packed_data.keys():
		var d = packed_data[key]
		
		if d is Dictionary:
			match key:
				"map_grids":
					var _map_grids = {}
					for v2 in d.keys():
						_map_grids[v2 if v2 is Vector2i else DataTool.parse_vector2i(v2)] = MapGrid.new_from_data(d[v2])
					dic[key] = _map_grids
					break
				_:
					dic[key] = d
					var message = "区块数据 %s 可能缺少实例化方法" % key
					LogAccess.new().log_message(LogAccess.LogLevel.INFO, "static", message) # 记录日志
					break
		else:
			dic[key] = d
	
	return dic
