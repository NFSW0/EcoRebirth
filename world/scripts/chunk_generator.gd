class_name ChunkGenerator
extends Resource

# 生成区块
func generate_chunk(_world_data: Dictionary, chunk_pos: Vector2i) -> Chunk:
	return Chunk.new(chunk_pos)

# 遍历区块
func _traverse_chunk(world_data: Dictionary, chunk_pos: Vector2i, call_back:Callable):
	var x_orgin = chunk_pos.x * world_data["chunk_size"]
	var y_orgin = chunk_pos.y * world_data["chunk_size"]
	for x in range(world_data["chunk_size"]):
		for y in range(world_data["chunk_size"]):
			var world_x = x_orgin + x
			var world_y = y_orgin + y
			call_back.call(Vector2i(world_x, world_y))
