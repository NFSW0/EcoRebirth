class_name ChunkGenerator_Environment
extends ChunkGeneratorBase
# 环境生成器

func _init(_chunk_generator:ChunkGenerator):
	super._init(_chunk_generator)

func generate_chunk(world_data: Dictionary, chunk_pos: Vector2i) -> Chunk:
	var chunk: Chunk = super.generate_chunk(world_data, chunk_pos)
	# 获取区块数据
	var chunk_data: Dictionary = chunk.get_chunk_data()
	# 获取当前区块的全部图格数据
	var map_grids: Dictionary = chunk_data.get("map_grids",{})
	## 获取区块内图格坐标组
	#var grid_pos_array = []
	#_traverse_chunk(world_data, chunk_pos, func(map_pos):grid_pos_array.append(map_pos))
	## 获取区块内图格数据组
	#var grid_data_array = grid_pos_array.map(func(number):return map_grids.get(number, MapGrid.new(number)))
	
	# 更新图格数据 待被批处理替换
	_traverse_chunk(world_data, chunk_pos, func(map_pos):
		# 获取坐标图格数据
		var map_grid: MapGrid = map_grids.get(map_pos, MapGrid.new(map_pos))
		# 获取地面瓦片数据
		var layer_data: Dictionary = {"source_id": 2, "atlas_coords": Vector2i(1, 0)}
		# 添加地面瓦片数据
		map_grid.update_grid_data("ground_layer",layer_data)
		# 覆写坐标数据
		map_grids[map_pos] = map_grid
		)
	
	return chunk
