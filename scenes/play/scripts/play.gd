extends Node
# 游玩场景 主要负责协调玩家游玩体验 监听玩家信号

#region 属性:本机玩家
var player # 记录本机玩家节点 由玩家节点主动赋值 因多人生成的实体难以直接获取
func set_player(_player : Node):
	player = _player
	# 添加监听:动态加载世界区块
	player.connect("position_changed",_load_chunks_around_the_player)
func get_player():
	return player
#endregion
var loaded_chunk_center
@onready var multiplayer_spawner = $MultiplayerSpawner # 多人生成器
@onready var world2 = $World2 # 世界节点


func _ready():
	if not multiplayer.is_server(): # 如果是客户端
		await multiplayer.connected_to_server # 等待连接完成
	var role_menu = UIManager.get_ui("RoleMenu",self) # 打开角色选择界面
	await role_menu.player_selected # 等待玩家完成角色选择
	var using_player_data = DataManager.get_data("using_player_data",{"body":"Body1", "face":"Face1"}) # 获取选择的角色数据
	using_player_data["resource_path"] = "res://character/scenes/character_model.tscn" # 补充预制体路径
	EcoMultiSpawner.generate_entity(using_player_data) # 多人生成实体

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # 打开灰幕与游戏菜单
		UIManager.get_ui("GreyScreen", self) # 打开灰幕与游戏菜单
	if event.is_action_pressed("ui_accept"): # 特效功能测试
		EffectManager.play_effect("ExampleEffect", Vector2i(100,50)) # 特效功能测试

# 获取需要加载区块组 TODO 调整以适配屏幕
func _get_chunks_by_chunk_center(chunk_pos):
	return [chunk_pos, chunk_pos + Vector2i(-1, 0), chunk_pos + Vector2i(1, 0), chunk_pos + Vector2i(0, -1), chunk_pos + Vector2i(0, 1)]

# 加载玩家周围区块
func _load_chunks_around_the_player(player_pos:Vector2):
	# 获取玩家区块坐标
	var player_chunk_pos = world2.get_chunk_pos_from_map_pos(world2.get_map_pos_from_global_pos(player_pos))
	# 获取需要加载的区块组
	if player_chunk_pos == loaded_chunk_center: return
	loaded_chunk_center = player_chunk_pos
	var new_chunk_array = _get_chunks_by_chunk_center(loaded_chunk_center)
	# 获取已加载的区块组
	var old_chunk_array = world2.get_the_loaded_chunks_array()
	# 剔除重复区块
	var chunks_to_load = new_chunk_array.filter(func(array_number):return not old_chunk_array.has(array_number))
	var chunks_to_unload = old_chunk_array.filter(func(array_number):return not new_chunk_array.has(array_number))
	# 加载新区块
	for chunk_pos in chunks_to_load:
		world2.load_chunk(chunk_pos)
	# 卸载旧区块
	for chunk_pos in chunks_to_unload:
		world2.unload_chunk(chunk_pos)
