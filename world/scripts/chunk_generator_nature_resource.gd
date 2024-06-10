class_name ChunkGenerator_NatureResource
extends ChunkGeneratorBase
# 自然资源生成器

func _init(_chunk_generator:ChunkGenerator):
	super._init(_chunk_generator)

func generate_chunk(world_data: Dictionary, chunk_pos: Vector2i) -> Chunk:
	var chunk: Chunk = super.generate_chunk(world_data, chunk_pos)

	var chunk_data: Dictionary = chunk.get_chunk_data()
	var map_grids: Dictionary = chunk_data.get("map_grids",{})
	_traverse_chunk(world_data, chunk_pos, func(map_pos):
		var map_grid: MapGrid = map_grids.get(map_pos, MapGrid.new(map_pos))
		var layer_data: Dictionary = {"source_id": 1, "atlas_coords": Vector2i(1, 0)}
		map_grid.update_grid_data("wall_layer", layer_data)
		map_grids[map_pos] = map_grid
		)

	return chunk
