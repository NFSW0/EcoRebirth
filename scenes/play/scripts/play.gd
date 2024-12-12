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
var entity_limit = 100 # 实体数量限制(软限制)
var current_entity_count = 0 # 当前实体数量
var generate_interval = 0.2 # 敌人生成间隔
var timer:Timer = Timer.new() # 敌人生成计时器
var no_enemy_range = 400 # 不可生成敌人的半径
var to_enemy_range = 400 # 可以生成敌人的半径(基于不可生成半径的额外范围)
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
	add_child(timer)
	timer.start(generate_interval)
	timer.timeout.connect(_generate_enemy)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): # ESC
		if world2.under_construction: # 建造模式退出
			world2.exit_build_mode()
			return
		UIManager.get_ui("GreyScreen", self) # ESC 打开灰幕与游戏菜单
	if event.is_action_pressed("ui_accept"): # Space Enter
		EffectManager.play_effect("ExampleEffect", Vector2i(100,50)) # 特效功能测试
	if event.is_action_pressed("primary_interact"):
		if world2.under_construction: # 建造模式放置
			world2.place_tile()
			return
	if event.is_action_pressed("secondary_interact"):
		world2.enter_build_mode()
		#var debug_adjunct = AdjunctActive.new("eco_rebirth:debug",player,null,false,1,0,0,5) # 附益功能测试
		#AdjunctManager.add_active_adjunct(debug_adjunct)

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
	if camera == null or world2 == null:
		return
	# 获取玩家区块坐标
	var camera_chunk_pos = world2.get_chunk_pos_from_map_pos(world2.get_map_pos_from_global_pos(camera.global_position))
	# 获取需要加载的区块组
	if camera_chunk_pos == loaded_chunk_center: return
	loaded_chunk_center = camera_chunk_pos
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

# 获取需要加载区块组 TODO 调整以适配屏幕 调整屏幕大小会看见远景 动态加载考虑加入相机视野参数
func _get_chunks_by_chunk_center(chunk_pos, radius=1):
	var chunks = []
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			chunks.append(chunk_pos + Vector2i(x, y))
	return chunks

# 生成敌人
func _generate_enemy(_center_position: Vector2 = player.position, _no_enemy_range: float = no_enemy_range, _to_enemy_range: float = to_enemy_range):
	if current_entity_count < entity_limit and player:
		var enemy_data: Dictionary = EcoEntityFactory.new_entity("Slim")
		# 计算生成敌人的位置
		var random_angle = randf() * TAU  # 随机角度，TAU 是 2 * PI
		var random_distance = randf_range(_no_enemy_range, _no_enemy_range + _to_enemy_range)
		var random_position: Vector2 = _center_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
		enemy_data = enemy_data.merged({"position": random_position}, true)
		EcoMultiSpawner.generate_entity(enemy_data)
		current_entity_count += 1
