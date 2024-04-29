class_name _EffectManager
extends MultiplayerSpawner
# 特效管理器 用于在多人游戏中生成特效 使用AnimatedSprite2D实现 监听animation_finished信号销毁

var effect_model = preload("res://effect/scenes/effect_model.tscn") # 特效实例模板
var effect_resources := {} # 存储注册的特效资源
var unique_id = 0 # 唯一编号 用于设置唯一名称

func _enter_tree():
	spawn_path = self.get_path() # 设置同步节点为自己
	spawn_function = _initialize_and_play # 设置spawn方法
	unique_id = 0 # 初始化唯一编号

func register_effect(effect_name: String, effect_resource_path: String, position: Vector2, size: Vector2) -> String: # 注册特效
	var final_name = _generate_final_name(effect_name) # 生成唯一名称
	effect_resources[final_name] = {"effect_resource_path": effect_resource_path, "position": position, "size": size} # 注册特效
	var message = "已注册特效: %s" % final_name # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	return final_name # 返回最终注册的名称

func play_effect(effect_name: String, position: Vector2): # 播放特效 接收角色数据和位置
	if not multiplayer.is_server(): # 如果是客户端
		rpc_id(1, "_play_effect", effect_name, position) # 向主机发出请求
	else: # 如果是服务端
		_play_effect(effect_name, position) # 直接调用方法

func get_effect_data(effect_name: String) -> Dictionary: # 获取特效数据
	return effect_resources[effect_name] # 返回特效数据

#region 私有方法
func _generate_final_name(effect_name: String) -> String: # 生成唯一名称
	var final_name = effect_name
	var count = 1
	while final_name in effect_resources:
		final_name = "%s_%d" % [effect_name, count]
		count += 1
	return final_name

func _initialize_and_play(effect_name) -> Node: # 初始化并播放特效并返回节点
	var effect_instance = effect_model.instantiate() # 实例化
	effect_instance.name = effect_name + "_" + str(unique_id) # 设置名称为唯一编号
	unique_id += 1 # 累加编号
	effect_instance.effect_data = effect_resources[effect_name] # 设置特效数据
	return effect_instance # 返回特效实例节点

@rpc("any_peer","call_local") # 自我生效 客机可请求
func _play_effect(effect_name: String, _position: Vector2) -> Node: # RPC播放特效
	if multiplayer.is_server(): # 仅主机执行
		if effect_name in effect_resources: # 如果特效已注册
			var node = spawn(effect_name) # 等效于_initialize_and_play(effect_name)
			node.position = _position # 特效位置修正
			return node # 返回特效
		else: # 如果特效未注册
			var message = "(特效缺失)Error: Effect resource '%s' not found." % effect_name # 生成错误信息
			LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 记录错误日志
	return null # 返回空
#endregion
