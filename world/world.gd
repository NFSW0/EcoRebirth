extends Node2D

signal init_completed() # 初始化完成信号
const CHUNK_SIZE = 16 # 区块大小 用于划分区块
var world_data := {"seed":"123"} # 世界数据 从存档数据获取
var noise = FastNoiseLite.new() # 创建噪声资源 用于随机化生成
var map_data = {} # 用于存储区块数据的字典
@onready var tile_map_preview = $Preview
@onready var tile_map_environment = $Environment
@onready var tile_map_surface = $Surface
@onready var tile_map_ground = $Ground # 用于Ground层生成


func _ready():
	_multi_ready()
	_noise_ready()
	load_chunk(get_chunk_pos_from_world_pos(17,0))

# 从世界坐标获取区块坐标
func get_chunk_pos_from_world_pos(world_x, world_y):
	var chunk_x = int(world_x / CHUNK_SIZE)
	var chunk_y = int(world_y / CHUNK_SIZE)
	return Vector2(chunk_x, chunk_y)

# 加载区块
func load_chunk(chunk_pos):
	if multiplayer.is_server():
		_load_chunk(chunk_pos)
	else:
		rpc_id(1, "_load_chunk", chunk_pos)

# 卸载区块
func unload_chunk(chunk_pos):
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = chunk_pos.x * CHUNK_SIZE + x
			var world_y = chunk_pos.y * CHUNK_SIZE + y
			tile_map_ground.set_cell(0, Vector2i(world_x, world_y), -1) # 清除TileMap中的瓦片

#region 多人准备
func _multi_ready():
	if multiplayer.is_server():
		_init_world_data(world_data)
	else:
		rpc_id(1, "_send_world_data")

## 服务端-发送特效数据
@rpc("any_peer", "reliable")
func _send_world_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_world_data", world_data)

## 属性赋值
@rpc("reliable")
func _init_world_data(_world_data):
	world_data = _world_data
	init_completed.emit()
#endregion

#region Ground层生成-无环境参与
func _noise_ready(): # 准备噪声生成器
	noise.noise_type = 2 # 设置蜂窝噪声算法
	noise.seed = hash(world_data["seed"]) + rand_from_seed(hash(world_data["seed"]))[0] # 设置随机种子
	noise.domain_warp_frequency = 0.05 # 噪声频率 低->平滑 高->嘈杂
	noise.domain_warp_fractal_lacunarity = 4 # 音阶空隙 决定噪声细致或者粗糙
	noise.domain_warp_fractal_gain = 0.5 # 
	noise.fractal_lacunarity = 2 # 音阶倍频

func _generate_chunk(chunk_pos): # 生成特定区块的瓦片地图数据
	var chunk = {}
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = chunk_pos.x * CHUNK_SIZE + x
			var world_y = chunk_pos.y * CHUNK_SIZE + y
			var noise_value = noise.get_noise_2d(world_x, world_y)
			var tile_type = _get_tile_type_based_on_noise(noise_value)
			chunk[Vector2(x, y)] = tile_type
	return chunk

func _get_tile_type_based_on_noise(noise_value): # 基于噪声值决定瓦片类型
	if noise_value < 0.2:
		return Vector2i(0,0)
	elif noise_value < 0.5:
		return Vector2i(1,0)
	elif noise_value < 0.8:
		return Vector2i(2,0)
	else:
		return Vector2i(3,0)

@rpc("any_peer", "reliable") # 任意发起 低频重要
func _load_chunk(chunk_pos): # 加载区块
	if not chunk_pos in map_data: # 如果没有区块数据
		var chunk = _generate_chunk(chunk_pos) # 生成区块数据
		map_data[chunk_pos] = chunk # 存储区块数据
	if multiplayer.is_server():
		_chunk_instance(chunk_pos, map_data[chunk_pos])
	else:
		rpc_id(multiplayer.get_remote_sender_id(), "_chunk_instance", chunk_pos, map_data[chunk_pos]) # 主机让发起端实例化

@rpc("reliable") # 仅主机发起 低频重要
func _chunk_instance(chunk_pos, chunk_data): # 实例化区块 传入 区块坐标 区块数据
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = chunk_pos.x * CHUNK_SIZE + x
			var world_y = chunk_pos.y * CHUNK_SIZE + y
			tile_map_ground.set_cell(0, Vector2i(world_x, world_y), 2, chunk_data[Vector2(x, y)]) # 设置TileMap中的瓦片
#endregion
