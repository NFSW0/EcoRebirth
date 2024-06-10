class_name ChunkGenerator_Creature
extends ChunkGeneratorBase
# 生物生成器

func _init(_chunk_generator:ChunkGenerator):
	super._init(_chunk_generator)

func generate_chunk(world_data: Dictionary, chunk_pos: Vector2i) -> Chunk:
	var chunk: Chunk = super.generate_chunk(world_data, chunk_pos)
	
	_traverse_chunk(world_data, chunk_pos, func(map_pos):
		if true:
			var creatures: Dictionary = {"生物1":{"pos":map_pos}}
			chunk.update_chunk_data("creatures", creatures)
		)
	
	return chunk
