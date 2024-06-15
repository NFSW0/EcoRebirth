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
	# 获取区块内图格坐标组 [(0,0),(1,1)]
	var grid_pos_array:Array[Vector2i] = []
	_traverse_chunk(world_data, chunk_pos, func(map_pos):grid_pos_array.append(map_pos))
	# 获取区块内图格数据组 [MapGrid]
	var grid_data_array = grid_pos_array.map(func(number):return map_grids.get(number, MapGrid.new(number)))
	# 获取对应瓦片数据组 [{{"source_id": 2, "atlas_coords": Vector2i(0, 0)}},{...}]
	var cell_data_array = EnvironmentManager.get_environment_array(1, grid_pos_array)
	# 更新区块内图格数据
	for index in grid_pos_array.size():
		grid_data_array[index].update_grid_data("ground_layer", cell_data_array[index])
		map_grids[grid_pos_array[index]] = grid_data_array[index]
	return chunk
