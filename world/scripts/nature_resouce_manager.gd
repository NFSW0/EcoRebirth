class_name _NatureResourceManager
extends Node
# 自然资源管理器 用于世界生成时添加自然资源
# 每种自然资源有不同的的合理性检查方法需要注册

const nature_resource_noise_resource_path = "res://world/nature_resource_noise.tres" # 自然资源噪声资源路径
var noise: FastNoiseLite # 噪声生成器
var nature_resource_kinds := {
"自然资源1":{"name":"岩石", "cell_data":{"source_id": 1, "atlas_coords": Vector2i(0, 0)}},
"自然资源2":{"name":"树木", "cell_data":{"source_id": 1, "atlas_coords": Vector2i(1, 0)}},
"自然资源3":{"name":"青草", "cell_data":{"source_id": 1, "atlas_coords": Vector2i(2, 0)}},
"自然资源4":{"name":"冰花", "cell_data":{"source_id": 1, "atlas_coords": Vector2i(3, 0)}},
}

func _ready():
	noise = load(nature_resource_noise_resource_path) # 加载噪声资源

func get_environment_array(noise_seed: int, pos_array: Array[Vector2i]) -> Array:
	noise.seed = noise_seed
	var nature_resource_array = [{}]
	for pos in pos_array:
		var noise_value = noise.get_noise_2d(pos.x, pos.y)
		nature_resource_array.append(_get_tile_type_based_on_noise(noise_value))
	return _second_fixed_array(noise_seed, pos_array, nature_resource_array)

func _second_fixed_array(noise_seed: int, pos_array: Array[Vector2i], nature_resource_array):
	var cell_data_array = []
	for index in pos_array.size():
		var environment = EnvironmentManager.get_environment_data(noise_seed, pos_array[index])
		var cell_data = nature_resource_array[index]
		# NOTE 临时的合理性判断， 应当调用数据中存储的合理性检测方法
		if cell_data is Dictionary and cell_data.is_empty():
			cell_data_array.append({})
			continue
		match cell_data["name"]:
			"岩石":
				match environment["name"]:
					"岩石":
						cell_data_array.append(cell_data["cell_data"])
					_:
						cell_data_array.append({})
			"树木":
				match environment["name"]:
					"草地":
						cell_data_array.append(cell_data["cell_data"])
					_:
						cell_data_array.append({})
			"青草":
				match environment["name"]:
					"草地":
						cell_data_array.append(cell_data["cell_data"])
					_:
						cell_data_array.append({})
			"冰花":
				match environment["name"]:
					"河流":
						cell_data_array.append(cell_data["cell_data"])
					_:
						cell_data_array.append({})
	return cell_data_array

func _get_tile_type_based_on_noise(noise_value) -> Dictionary: # 基于噪声值决定瓦片类型
	if noise_value > 0.1 && noise_value < 0.2:
		return nature_resource_kinds["自然资源4"]
	elif noise_value > 0.2 && noise_value < 0.3:
		return nature_resource_kinds["自然资源2"]
	elif noise_value > 0.3 && noise_value < 0.4:
		return nature_resource_kinds["自然资源3"]
	elif noise_value > 0.4 && noise_value < 0.5:
		return nature_resource_kinds["自然资源1"]
	else:
		return {}
