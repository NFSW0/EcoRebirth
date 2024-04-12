class_name _SettingManager
extends Node
# 设置管理器 负责注册设置项和检索设置项

var root_group = SettingGroup.new() # 根选项组

func register_option(path: String, values: Array, callbacks: Array): # 注册设置数据
	var path_array = path.split("/") # 路径划分
	var option = SettingOption.new(path_array[-1], values, callbacks) # 新建设置选项
	root_group.add_option(path_array, option) # 添加新设置选项
	var message = "已注册设置: %s" % [path] # 生成日志信息
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 记录日志

func get_options(path: String) -> Array: # 获取层级数据 首个元素用于确认是否为选项值
	var path_array = path.split("/") # 路径划分
	var result = [] # 存储检索结果
	var current_element = root_group.get_option(path_array) # 通过参数获取元素
	if current_element is SettingOption: # 如果元素是选项
		return [true] + current_element.values # 返回值的集合
	elif current_element is SettingGroup: # 如果元素是选项组
		for key in current_element.children.keys(): # 获取选项组下子选项组
			result.append(key) # 组合成集合
	return [false] + result # 返回选项组的集合

func setting_value(path: String, value): # 应用设置
	var path_array = path.split("/") # 路径划分
	var current_element = root_group.get_option(path_array) # 通过参数获取元素
	if current_element is SettingOption: # 如果元素是选项
		for callback in current_element.callbacks: # 遍历全部回调
			callback.call(value) # 触发回调
