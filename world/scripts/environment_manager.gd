class_name _EnvironmentManager
extends Node
# 注册环境和有关数据 用于生成世界时设置环境

const environment_noise_resource_path = "res://world/envionment_niose.tres" # 环境噪声资源路径
var noise: FastNoiseLite # 噪声生成器
var environment_kinds := {} # 环境种类

func _ready():
	noise = load(environment_noise_resource_path) # 加载噪声资源

func register_environment(environment_name: String, environment_data: Dictionary) -> String:
	var final_name = _generate_final_name(environment_name) # 生成唯一名称
	environment_kinds[final_name] = environment_data # 写入环境数据
	var message = "已注册环境: %s %s" % [final_name, environment_name] # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	return final_name

func _generate_final_name(environment_name):
	var final_name = environment_name # 存储最终注册的名称
	var count = 1 # 用于循环改进名称
	while final_name in environment_kinds: # 如果名称重复
		final_name = "%s_%d" % [environment_name, count] # 改进名称
		count += 1 # 循环变量
	return final_name # 返回最终注册的名称

func get_environment_array(noise_seed: int, pos_array: Array[Vector2]) -> Array:
	var environment_array = []
	noise.seed = noise_seed
	for pos in pos_array:
		var noise_value = noise.get_noise_2d(pos.x, pos.y)
		environment_array.append(_get_tile_type_based_on_noise(noise_value))
	return environment_array

func _get_tile_type_based_on_noise(noise_value): # 基于噪声值决定瓦片类型
	if noise_value < 0.1:
		return "环境1"
	elif noise_value < 0.25:
		return "环境2"
	elif noise_value < 0.6:
		return "环境3"
	else:
		return "环境4"
