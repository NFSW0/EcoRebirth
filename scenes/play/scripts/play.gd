extends Node
# 游玩场景 同步玩家和世界

const character_model_path = "res://character/scenes/character_model.tscn" # 角色实例模板路径
var unique_id = 0 # 唯一编号 用于设置唯一名称
@onready var multiplayer_spawner = $MultiplayerSpawner # 多人生成器


func _ready():
	if not multiplayer.is_server(): # 如果是客户端
		await multiplayer.connected_to_server # 等待连接完成
	multiplayer_spawner.spawn_function = _generate_character # 设置多人生成方法
	# 生成地图
	var role_menu = UIManager.get_ui("RoleMenu",self) # 打开角色选择界面
	await role_menu.player_selected # 等待角色选择完成
	var using_player_data = DataManager.get_data("using_player_data",{"body":"Body1", "face":"Face1"}) # 获取角色数据
	generate_character(using_player_data,Vector2(50,50)) # 生成角色


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"): # 特效功能测试
		EffectManager.play_effect("ExampleEffect", Vector2i(100,50)) # 特效功能测试
	if event.is_action_pressed("ui_cancel"): # 打开灰幕与游戏菜单
		UIManager.get_ui("GreyScreen", self) # 打开灰幕与游戏菜单


func generate_character(character_data: Dictionary, position: Vector2): # 生成角色 接收角色数据和位置
	if not multiplayer.is_server(): # 如果是客户端
		rpc_id(1, "_generate_sync_character", character_data, position) # 向主机发出请求
	else: # 如果是服务端
		_generate_sync_character(character_data, position) # 直接调用方法


#region 私有方法
@rpc("any_peer","call_local","reliable")
func _generate_sync_character(character_data, position): # 生成同步实例 如玩家、物品等 特效已通过特效管理器处理
	if multiplayer.is_server(): # 仅服务端处理
		var sync_node = multiplayer_spawner.spawn(character_data) # 调用生成方法
		sync_node.position = position # 位置修正
func _generate_character(character_data) -> Node: # 初始化并播放特效并返回节点
	var character_instance = load(character_model_path).instantiate() # 实例化
	character_instance.name = "character_" + str(unique_id) # 设置名称为唯一编号
	unique_id += 1 # 累加编号
	character_instance.character_data = character_data # 设置角色数据
	return character_instance # 返回特效实例节点
#endregion
