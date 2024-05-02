extends Node2D

signal init_completed() # 初始化完成信号
const CHUNK_SIZE = 16 # 区块大小 用于划分区块
const TILE_HEIGHT = 16 # 瓦片大小 用于玩家坐标转瓦片坐标
const TILE_WIDTH = 32 # 瓦片大小 用于玩家坐标转瓦片坐标
var world_data := {"seed":"123"} # 世界数据 从存档数据获取
var noise = FastNoiseLite.new() # 创建噪声资源 用于随机化生成
var ground_map_data = {} # 用于存储区块数据的字典
var loaded_chunk_center # 记录上次区块加载中心 用于避免重复加载
var old_chunk_array : Array # 记录加载的区块
@onready var tile_map_ground = $Ground # 用于Ground层生成
@onready var tile_map_preview = $Preview
@onready var tile_map_environment = $Environment
@onready var tile_map_surface = $Surface


func _ready():
	_multi_ready()
	_noise_ready()

func _physics_process(_delta):
	_update_chunks_near_player()

# 从世界坐标获取区块坐标
func get_chunk_pos_from_world_pos(global_pos : Vector2):
	var map_pos:Vector2 = tile_map_ground.local_to_map(global_pos) # 获取地图坐标
	return Vector2i(floor(map_pos.x / CHUNK_SIZE), floor(map_pos.y / CHUNK_SIZE))

# 加载区块
func load_chunk(chunk_pos):
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
	if not multiplayer.is_server(): # 如果是客户端
		await multiplayer.connected_to_server # 等待连接完成
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

#region 噪声与区块生成
func _noise_ready(): # 准备噪声生成器
	noise.noise_type = FastNoiseLite.TYPE_CELLULAR # 设置噪声类型为蜂窝
	noise.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN # 设置蜂窝噪声的距离计算方式
	noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE # 设置蜂窝返回类型为距离
	noise.frequency = 0.01 # 调整噪声的频率
	noise.cellular_jitter = 1.0 # 可选：调整Jitter，让蜂窝图更不规则
	noise.seed = hash(world_data["seed"]) + rand_from_seed(hash(world_data["seed"]))[0] # 可选：设置种子以获取可重复的结果

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
	if noise_value < 0.1:
		return Vector2i(0, 0)
	elif noise_value < 0.25:
		return Vector2i(1, 0)
	elif noise_value < 0.6:
		return Vector2i(2, 0)
	else:
		return Vector2i(3, 0)
#endregion

#region 区块加载
func _update_chunks_near_player(): # 更新玩家周围的区块
	if get_tree().current_scene.player == null: return # 确认玩家存在
	var player_pos = get_tree().current_scene.player.position # 获取玩家坐标
	var player_chunk_pos = get_chunk_pos_from_world_pos(player_pos) # 获取所在区块
	if player_chunk_pos == loaded_chunk_center: return # 区块加载中心相同则忽略
	loaded_chunk_center = player_chunk_pos # 更新区块加载中心
	var new_chunk_array = _get_chunks_by_chunk_center(player_chunk_pos) # 计算范围内的区块组
	var chunks_to_load = new_chunk_array.filter(func(array_number):return not old_chunk_array.has(array_number)) # 计算需要加载的区块
	var chunks_to_unload = old_chunk_array.filter(func(array_number):return not new_chunk_array.has(array_number)) # 记录需要卸载的区块
	for chunk_pos in chunks_to_unload: # 卸载旧区块
		unload_chunk(chunk_pos) # 完成区块卸载
		old_chunk_array.erase(chunk_pos) # 剔除卸载的区块记录
	for chunk_pos in chunks_to_load: # 加载新区块
		load_chunk(chunk_pos) # 完成区块加载
		old_chunk_array.append(chunk_pos) # 添加加载的区块记录

func _get_chunks_by_chunk_center(chunk_pos): # 获取需要加载区块集合
	return [chunk_pos, chunk_pos + Vector2i(-1, 0), chunk_pos + Vector2i(1, 0), chunk_pos + Vector2i(0, -1), chunk_pos + Vector2i(0, 1)]

@rpc("any_peer", "call_local", "reliable") # 任意发起 低频重要
func _load_chunk(chunk_pos): # 加载区块
	if not chunk_pos in ground_map_data: # 如果没有区块数据
		var chunk = _generate_chunk(chunk_pos) # 生成区块数据
		ground_map_data[chunk_pos] = chunk # 存储区块数据
	rpc_id(multiplayer.get_remote_sender_id(), "_chunk_instance", chunk_pos, ground_map_data[chunk_pos]) # 主机让发起端实例化

@rpc("call_local", "reliable") # 仅主机发起 低频重要
func _chunk_instance(chunk_pos, chunk_data): # 实例化区块 传入 区块坐标 区块数据
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			var world_x = chunk_pos.x * CHUNK_SIZE + x
			var world_y = chunk_pos.y * CHUNK_SIZE + y
			tile_map_ground.set_cell(0, Vector2i(world_x, world_y), 2, chunk_data[Vector2(x, y)]) # 设置TileMap中的瓦片
#endregion
