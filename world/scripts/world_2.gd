extends Node2D

var world_data = { "chunk_size":16, "seed":123 } # 世界数据 从存档数据获取
var chunk_generator : ChunkGenerator # 区块生成器
var loaded_chunks := {} # 已加载区块 用字典存放区块相关数据
@onready var tile_map :TileMap = $TileMap # 瓦片地图

func _ready():
	# TODO 获取世界数据
	# 初始化区块生成器
	chunk_generator = ChunkGenerator_NatureResource.new(ChunkGenerator_Environment.new(ChunkGenerator.new()))

# 获取区块
func get_chunk(chunk_pos: Vector2i) -> Chunk:
	var chunk:Chunk
	if loaded_chunks.has(chunk_pos):
		chunk = loaded_chunks[chunk_pos]
	else:
		chunk = _read_chunk(chunk_pos)
	return chunk

# 获取已加载区块组
func get_the_loaded_chunks_array() -> Array:
	return loaded_chunks.keys()

# 加载区块
func load_chunk(chunk_pos: Vector2i):
	if loaded_chunks.has(chunk_pos):
		return
	var chunk: Chunk = _read_chunk(chunk_pos)
	var chunk_data: Dictionary = chunk.get_chunk_data()
	var map_grids:Dictionary = chunk_data.get("map_grids", [])
	# 加载瓦片
	_traverse_chunk(chunk_pos,func(map_pos:Vector2i):
		var map_grid: MapGrid = map_grids.get(map_pos, MapGrid.new(map_pos))
		_traverse_layer(func(layer_id):
			var map_grid_data = map_grid.get_grid_data()
			var layer_name: String = tile_map.get_layer_name(layer_id)
			var layer_data: Dictionary = map_grid_data.get(layer_name, {})
			var source_id: int = layer_data.get("source_id", -1)
			var atlas_coords: Vector2i = layer_data.get("atlas_coords", Vector2i(-1, -1))
			tile_map.set_cell(layer_id, map_pos, source_id, atlas_coords)
			)
		)
	# TODO 加载生物
	
	# 附属更新
	loaded_chunks[chunk_pos] = chunk

# 卸载区块
func unload_chunk(chunk_pos: Vector2i):
	if not loaded_chunks.has(chunk_pos):
		return
	# 卸载瓦片
	_traverse_chunk(chunk_pos,func(map_pos:Vector2i):
		_traverse_layer(func(layer_id):
			tile_map.set_cell(layer_id,map_pos)))
	# TODO 卸载生物
	
	# 保存数据
	var chunk:Chunk = loaded_chunks[chunk_pos]
	var success = _save_chunk(chunk)
	if not success:
		var message = "区块 %s 保存失败" % chunk_pos # 生成日志信息
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录日志
	# 附属更新
	loaded_chunks.erase(chunk_pos)

# 世界坐标转地图坐标
func get_map_pos_from_global_pos(global_pos: Vector2):
	return tile_map.local_to_map(global_pos)

# 地图坐标转区块坐标
func get_chunk_pos_from_map_pos(map_pos: Vector2):
	return Vector2i(floor(map_pos.x / world_data["chunk_size"]), floor(map_pos.y / world_data["chunk_size"]))

#region 私有方法
# 读取区块
func _read_chunk(chunk_pos: Vector2i) -> Chunk:
	var chunk:Chunk = Chunk.new(chunk_pos)
	# TODO 添加区块持久化数据读取逻辑
	chunk = chunk_generator.generate_chunk(world_data, chunk_pos)
	return chunk
# 保存区块
func _save_chunk(_chunk: Chunk) -> bool:
	# TODO 添加区块持久化数据保存逻辑
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
	for layer_id: int in tile_map.get_layers_count():
		call_back.call(layer_id)
#endregion
