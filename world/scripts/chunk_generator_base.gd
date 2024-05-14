class_name ChunkGeneratorBase
extends ChunkGenerator

var chunk_generator:ChunkGenerator

func _init(_chunk_generator:ChunkGenerator):
	chunk_generator = _chunk_generator

func generate_chunk(chunk_pos: Vector2i) -> Chunk:
	return chunk_generator.generate_chunk(chunk_pos)
