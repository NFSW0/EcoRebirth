class_name _EnvironmentManager
extends Node
# 环境管理器 注册环境和有关数据 用于生成世界时设置环境
# 获取数据包含:环境类型名environment_name，环境数据environment_data，特定数据taget_data

const environment_noise_resource_path = "res://world/envionment_niose.tres" # 环境噪声资源路径
var noise: FastNoiseLite # 噪声生成器
var environment_kinds := {
"环境1":{"name":"岩石", "cell_data":{"source_id": 2, "atlas_coords": Vector2i(0, 0)}},
"环境2":{"name":"草地", "cell_data":{"source_id": 2, "atlas_coords": Vector2i(1, 0)}},
"环境3":{"name":"戈壁", "cell_data":{"source_id": 2, "atlas_coords": Vector2i(2, 0)}},
"环境4":{"name":"河流", "cell_data":{"source_id": 2, "atlas_coords": Vector2i(3, 0)}},
}

func _ready():
	noise = load(environment_noise_resource_path) # 加载噪声资源

func register_environment(environment_name: String, environment_data: Dictionary) -> String:
	var final_name = _generate_final_name(environment_name) # 生成唯一名称
	environment_kinds[final_name] = environment_data # 写入环境数据
	var message = "已注册环境: %s %s" % [final_name, environment_name] # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志
	return final_name

func get_environment_data(noise_seed: int, pos: Vector2) -> Dictionary:
	noise.seed = noise_seed
	var noise_value = noise.get_noise_2d(pos.x, pos.y)
	return _get_environment_data_by_noise_value(noise_value)

func get_environment_array(noise_seed: int, pos_array: Array[Vector2i]) -> Array:
	noise.seed = noise_seed
	var environment_array = []
	for pos in pos_array:
		var noise_value = noise.get_noise_2d(pos.x, pos.y)
		environment_array.append(_get_tile_type_based_on_noise(noise_value))
	return environment_array

func _generate_final_name(environment_name):
	var final_name = environment_name # 存储最终注册的名称
	var count = 1 # 用于循环改进名称
	while final_name in environment_kinds: # 如果名称重复
		final_name = "%s_%d" % [environment_name, count] # 改进名称
		count += 1 # 循环变量
	return final_name # 返回最终注册的名称

func _get_tile_type_based_on_noise(noise_value) -> Dictionary: # 基于噪声值决定瓦片类型
	if noise_value < 0.2:
		return environment_kinds["环境1"]["cell_data"]
	elif noise_value < 0.4:
		return environment_kinds["环境2"]["cell_data"]
	elif noise_value < 0.6:
		return environment_kinds["环境3"]["cell_data"]
	else:
		return environment_kinds["环境4"]["cell_data"]

func _get_environment_data_by_noise_value(noise_value) -> Dictionary:
	if noise_value < 0.1:
		return environment_kinds["环境1"]
	elif noise_value < 0.25:
		return environment_kinds["环境2"]
	elif noise_value < 0.6:
		return environment_kinds["环境3"]
	else:
		return environment_kinds["环境4"]
