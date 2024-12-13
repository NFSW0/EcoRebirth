extends Node2D

signal multi_sync_finished() # 多人同步完成信号，用于触发因多人数据没同步而暂停的方法
var world_data = {"name":"name","chunk_size":16, "seed":123 } # 世界数据 从存档数据获取
var chunk_generator : ChunkGenerator # 区块生成器
var loaded_chunks := {} # 已加载区块 用字典存放区块相关数据
var under_construction = false # 是否处于建造模式
var preview_source_id = -1 # 预览瓦片源id
var preview_atlas_coords = Vector2() # 预览瓦片编号
var preview_map_pos = Vector2i() # 预览网格点
var multi_sync = false # 多人同步完成标志
@onready var tile_map_layers = [$preview_layer, $wall_layer, $ground_layer] # 瓦片地图

# 初始化
func _ready():
	# 获取世界信息
	#world_data = DataManager.get_data("using_archive_data")
	# 初始化区块生成器
	chunk_generator = ChunkGenerator_NatureResource.new(ChunkGenerator_Environment.new(ChunkGenerator.new()))
	# 多人初始化
	_multi_ready()

# 预览功能的更新
func _process(_delta):
	if under_construction:
		var mouse_pos = get_global_mouse_position()
		var map_pos = get_map_pos_from_global_pos(mouse_pos)
		if map_pos == preview_map_pos:
			return
		preview_map_pos = map_pos
		_update_preview_layer(map_pos)

# 进入建造模式(瓦片数据)
func enter_build_mode(source_id = -1, atlas_coords = Vector2i()):
	preview_source_id = source_id
	preview_atlas_coords = atlas_coords
	under_construction = true

# 退出建造模式
func exit_build_mode():
	under_construction = false
	tile_map_layers[0].clear() # 清理预览残留

# 放置瓦片 默认放置预览的瓦片
func place_tile(layer_index: int = 1, map_pos: Vector2i = get_map_pos_from_global_pos(get_global_mouse_position()), source_id: int = preview_source_id, atlas_coords:Vector2i = preview_atlas_coords):
	if multiplayer.has_multiplayer_peer():
		rpc("_place_tile", layer_index, map_pos, source_id, atlas_coords)
	else:
		_place_tile(layer_index,map_pos,source_id,atlas_coords)

# 获取区块
func get_chunk(chunk_pos: Vector2i) -> Chunk:
	var chunk:Chunk
	if loaded_chunks.has(chunk_pos):
		chunk = loaded_chunks[chunk_pos]
	else:
		chunk = await _read_chunk(chunk_pos)
	return chunk

# 获取已加载区块组
func get_the_loaded_chunks_array() -> Array:
	return loaded_chunks.keys()

# 加载目标区块
func load_chunk(chunk_pos: Vector2i):
	# 等待多人数据传递完成
	await _await_multi()
	# 剔除已加载区块
	if loaded_chunks.has(chunk_pos):
		return
	var chunk: Chunk = await _read_chunk(chunk_pos)
	var chunk_data: Dictionary = chunk.get_chunk_data()
	var map_grids:Dictionary = chunk_data.get("map_grids", {})
	# 加载瓦片
	_traverse_chunk(chunk_pos,func(map_pos:Vector2i):
		var map_grid: MapGrid = map_grids.get(map_pos, MapGrid.new(map_pos))
		_traverse_layer(func(index):
			var map_grid_data = map_grid.get_grid_data()
			var tile_map_layer:TileMapLayer = tile_map_layers[index]
			var layer_name: String = tile_map_layer.name
			var layer_data: Dictionary = map_grid_data.get(layer_name, {})
			var source_id: int = layer_data.get("source_id", -1)
			var layer_atlas_coords = layer_data.get("atlas_coords", Vector2i(-1, -1))
			var atlas_coords: Vector2i = layer_atlas_coords if layer_atlas_coords is Vector2i else DataTool.parse_vector2i(layer_atlas_coords)
			tile_map_layer.set_cell(map_pos, source_id, atlas_coords)
			)
		)
	# TODO 加载生物 依赖实体生成系统
	
	# 保存数据
	var success = await _save_chunk(chunk)
	if not success:
		var message = "区块 %s 保存失败" % chunk_pos # 生成日志信息
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录日志
	# 附属更新
	loaded_chunks[chunk_pos] = chunk

# 卸载目标区块
func unload_chunk(chunk_pos: Vector2i):
	if not loaded_chunks.has(chunk_pos):
		return
	# 卸载瓦片
	_traverse_chunk(chunk_pos,func(map_pos:Vector2i):
		_traverse_layer(func(index):
			var tile_map_layer:TileMapLayer = tile_map_layers[index]
			tile_map_layer.set_cell(map_pos)))
	# TODO 卸载生物 依赖实体生成系统
	
	# 保存数据
	var chunk:Chunk = loaded_chunks[chunk_pos]
	var success = await _save_chunk(chunk)
	if not success:
		var message = "区块 %s 保存失败" % chunk_pos # 生成日志信息
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录日志
	# 附属更新
	loaded_chunks.erase(chunk_pos)

# 世界坐标转地图坐标
func get_map_pos_from_global_pos(global_pos: Vector2) -> Vector2i:
	return tile_map_layers[0].local_to_map(global_pos)

# 地图坐标转区块坐标
func get_chunk_pos_from_map_pos(map_pos: Vector2) -> Vector2i:
	return Vector2i(floor(map_pos.x / world_data["chunk_size"]), floor(map_pos.y / world_data["chunk_size"]))

#region 多人
func _multi_ready():
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			rpc_id(1, "_send_main_data")
			return
	_init_main_data(DataManager.get_data("using_archive_data"))

# 多人请求数据
@rpc("any_peer", "reliable")
func _send_main_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_main_data", world_data)

# 多人初始化
@rpc("any_peer", "reliable")
func _init_main_data(_main_data):
	world_data = _main_data
	multi_sync = true
	multi_sync_finished.emit()

# 多人放置瓦片
@rpc("any_peer","call_local","reliable")
func _place_tile(layer_index: int, map_pos: Vector2i, source_id: int, atlas_coords:Vector2i):
	if layer_index < tile_map_layers.size():
		# 出现重合且不是移除
		if source_id >= 0 and not _can_place([map_pos]):
			return
		tile_map_layers[layer_index].set_cell(map_pos, source_id, atlas_coords)
		_update_preview_layer(map_pos)
		# 数据更新
		var chunk_pos:Vector2i = get_chunk_pos_from_map_pos(map_pos)
		var target_chunk:Chunk = await get_chunk(chunk_pos)
		target_chunk.chunk_data["map_grids"][map_pos]["grid_data"]["wall_layer"] = {"source_id":source_id,"atlas_coords":atlas_coords}
#endregion

#region 私有方法
# 读取区块
func _read_chunk(chunk_pos: Vector2i) -> Chunk:
	# 等待多人数据传递完成
	await _await_multi()
	var chunk:Chunk = Chunk.new(chunk_pos)
	var data_name = "world_data_%s_%s" % [world_data["name"], chunk.chunk_pos]
	var saved_chunk = DataManager.get_data(data_name)
	if saved_chunk && saved_chunk["chunk_data"].get("map_grids"):
		chunk = Chunk.new_from_data(saved_chunk)
	else:
		chunk = chunk_generator.generate_chunk(world_data, chunk_pos)
	return chunk
# 保存区块
func _save_chunk(chunk: Chunk) -> bool:
	if multiplayer.has_multiplayer_peer():
		if not multiplayer.is_server():
			return true
	await _await_multi()
	var data_name = "world_data_%s_%s" % [world_data["name"], chunk.chunk_pos]
	if DataManager.has_registered(data_name):
		DataManager.set_data(data_name, chunk.to_data())
	else:
		DataManager.register_data(data_name, chunk.to_data())
	return true
# 遍历区块
func _traverse_chunk(chunk_pos: Vector2i, call_back:Callable):
	var x_orgin = chunk_pos.x * world_data["chunk_size"]
	var y_orgin = chunk_pos.y * world_data["chunk_size"]
	for x in range(world_data["chunk_size"]):
		for y in range(world_data["chunk_size"]):
			var world_x = x_orgin + x
			var world_y = y_orgin + y
			call_back.call(Vector2i(world_x, world_y))
# 遍历图层
func _traverse_layer(call_back:Callable):
	for index in tile_map_layers.size():
		call_back.call(index)
# 更新预览层
func _update_preview_layer(map_pos):
	tile_map_layers[0].clear()
	
	if not preview_source_id >= 0:
		tile_map_layers[0].modulate = Color("#FF6347", 0.5)
		
		var target_source_id = tile_map_layers[1].get_cell_source_id(map_pos)
		var target_atlas_coords = tile_map_layers[1].get_cell_atlas_coords(map_pos)
		tile_map_layers[0].set_cell(map_pos, target_source_id, target_atlas_coords)
	else:
		if _can_place([map_pos]):
			tile_map_layers[0].modulate = Color("#4682B4", 1)
		else:
			tile_map_layers[0].modulate = Color("#FF6347", 0.5)
		
		tile_map_layers[0].set_cell(map_pos, preview_source_id, preview_atlas_coords)
# 是否可以放置(阻止重叠)
func _can_place(positionList:Array[Vector2i]) -> bool:
	for map_pos in positionList:
		if tile_map_layers[1].get_cell_source_id(map_pos) != -1:
			return false
	return true
# 等待多人同步(添加到每个方法前用于暂停处理)
func _await_multi():
	if not multi_sync:
		await multi_sync_finished

#endregion
