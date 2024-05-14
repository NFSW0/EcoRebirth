class_name ChunkGenerator
extends Resource

const CHUNK_SIZE = 16 # 定义区块尺寸

# 生成区块
func generate_chunk(chunk_pos: Vector2i) -> Chunk:
	return Chunk.new(chunk_pos)

# 遍历区块
func _traverse_chunk(chunk_pos: Vector2i, call_back:Callable):
	var x_orgin = chunk_pos.x * CHUNK_SIZE
	var y_orgin = chunk_pos.y * CHUNK_SIZE
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = x_orgin + x
			var world_y = y_orgin + y
			call_back.call(Vector2i(world_x, world_y))
