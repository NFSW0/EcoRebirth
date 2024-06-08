class_name ChunkGenerator_Environment
extends ChunkGeneratorBase

func _init(_chunk_generator:ChunkGenerator):
	super._init(_chunk_generator)

func generate_chunk(chunk_pos: Vector2i) -> Chunk:
	var chunk: Chunk = super.generate_chunk(chunk_pos)
	
	var chunk_data: Dictionary = chunk.get_chunk_data()
	var map_grids: Dictionary = chunk_data.get("map_grids",{})
	_traverse_chunk(chunk_pos, func(map_pos):
		var map_grid: MapGrid = map_grids.get(map_pos, MapGrid.new(map_pos))
		var environment_data = "环境0"
		var layer_data: Dictionary = {"source_id": 2, "atlas_coords": Vector2i(1, 0)}
		map_grid.update_grid_data("environment",environment_data)
		map_grid.update_grid_data("ground_layer",layer_data)
		map_grids[map_pos] = map_grid
		)
	
	return chunk
