extends Node
# 游玩场景 主要负责协调玩家游玩体验 监听玩家信号

signal core_changed(node) # 主体变更信号

#region 属性:本机玩家 一切动态优化的参照体 保证玩家正常游玩
var player : Node # 记录本机玩家节点 由玩家节点主动赋值 因多人生成的实体难以直接获取
func set_player(_player : Node):
	player = _player
	core_changed.emit(player)
func get_player() -> Node:
	return player
#endregion
var loaded_chunk_center # 用于检查是否需要更新地图加载
var camera_offset = Vector2(0, 0) # 相机跟随偏移
@onready var camera = $Camera2D # 摄像机
@onready var world2 = $World2 # 世界节点
@onready var multi_entity = $MultiEntity # 实体载体

## 获取鼠标的世界坐标
func get_global_mouse_position() -> Vector2:
	return world2.get_global_mouse_position()

func _ready():
	EcoMultiSpawner.reset_spawn_path(multi_entity.get_path()) # 重设置多人实体根节点
	var role_menu = UIManager.get_ui("RoleMenu",self) # 打开角色选择界面
	await role_menu.player_selected # 等待玩家完成角色选择
	var using_player_data = DataManager.get_data("using_player_data",{"body":"Body1", "face":"Face1"}) # 获取选择的角色数据
	using_player_data["resource_path"] = "res://character/scenes/character_model.tscn" # 补充预制体路径
	EcoMultiSpawner.generate_entity(using_player_data) # 多人玩家实体

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # ESC 打开灰幕与游戏菜单
		UIManager.get_ui("GreyScreen", self) # ESC 打开灰幕与游戏菜单
	if event.is_action_pressed("ui_accept"): # Space 特效功能测试
		EffectManager.play_effect("ExampleEffect", Vector2i(100,50)) # Space 特效功能测试
	if event.is_action_pressed("primary_interact"):
		player.position = get_global_mouse_position()
	if event.is_action_pressed("secondary_interact"):
		var debug_adjunct = AdjunctActive.new("eco_rebirth:debug",player,null,false,1,0,0,5)
		AdjunctManager.add_active_adjunct(debug_adjunct)

func _physics_process(delta):
	_camera_follow(delta)
	_load_chunks_around_the_player(delta)

# 更新:相机跟随
func _camera_follow(delta):
	# 检查
	if player == null or camera == null:
		return
	# 计算摄像机应该跟随的位置
	var target_position = player.global_position + camera_offset # 调整Y坐标来移动摄像机 above the player
	# 使用Tween平滑地移动摄像机到目标位置
	var camera_follow_tween = self.create_tween()
	camera_follow_tween.tween_property(camera, "global_position", target_position, delta)

# 更新:动态加载区块
func _load_chunks_around_the_player(_delta):
	# 检查
	if player == null or world2 == null:
		return
	# 获取玩家区块坐标
	var player_chunk_pos = world2.get_chunk_pos_from_map_pos(world2.get_map_pos_from_global_pos(player.global_position))
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

# 获取需要加载区块组 TODO 调整以适配屏幕
func _get_chunks_by_chunk_center(chunk_pos):
	return [chunk_pos, chunk_pos + Vector2i(-1, 0), chunk_pos + Vector2i(1, 0), chunk_pos + Vector2i(0, -1), chunk_pos + Vector2i(0, 1)]
