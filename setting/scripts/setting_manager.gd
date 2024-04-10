class_name _SettingManager
extends Node
# 设置管理器 处理设置选项前后分层 选项名称 选项路径 选项数据

# 用于存储所有设置项的字典
var settings = {}

# 注册一个新的设置项
func register_setting(option_path: String, option_type: Variant.Type, default_value: Variant) -> void:
	var item = SettingItem.new(option_path, option_type, default_value)
	settings[option_path] = item

# 获取一个设置项的值
func get_setting(option_path: String) -> Variant:
	if settings.has(option_path):
		return settings[option_path].value
	return null

# 设置一个设置项的值
func set_setting(option_path: String, value: Variant) -> void:
	if settings.has(option_path):
		settings[option_path].value = value
