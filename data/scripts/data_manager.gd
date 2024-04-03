class_name _DataManager
extends Node


const DATA_PATH : String = "user://data.json" # 数据文件路径
var data := {} # 存放数据


# 初始化时从文件加载数据
func _init():
	_load_data()


# 从文件加载数据
func _load_data():
	if FileAccess.file_exists(DATA_PATH): # 如果文件存在
		var file = FileAccess.open(DATA_PATH,FileAccess.READ) # 打开文件
		var json_string = file.get_as_text() # 获取JSON文本
		var json_handler = JSON.new() # 创建JSON处理器
		var error = json_handler.parse(json_string) # 尝试解析JSON文本
		if error == OK: # JSON文本解析成功
			data = json_handler.data # 保留解析数据
		else: # JSON文本解析失败
			var message = "数据文件解析失败:[行%s]%s" % [json_handler.get_error_line(), json_handler.get_error_message()] # 生成错误信息
			LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), message) # 输出日志
	else: # 如果文件不存在
		save_data() # 保存新数据文件


# 保存数据到文件
func save_data():
	var file_directory = DATA_PATH.get_base_dir() # 获取数据目录路径
	if not DirAccess.dir_exists_absolute(file_directory): # 如果数据目录不存在
		DirAccess.make_dir_recursive_absolute(file_directory) # 创建完整数据目录
	var file = FileAccess.open(DATA_PATH,FileAccess.WRITE) # 创建数据文件并打开
	file.store_string(JSON.stringify(data)) # 写入字符化的数据


# 判断名称可用
func name_available(unique_name: String) -> bool:
	return not data.has(unique_name) # 如果名称不唯一则返回false


# 注册数据 返回是否成功注册
func register_data(unique_name: String, value) -> bool:
	if unique_name in data: # 如果数据名重复
		var message = "(重复注册数据-已忽略)Name already exists. Overwriting the value." # 生成提示信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志
		return false # 返回数据注册失败
	data[unique_name] = value # 如果数据名不重复则注册新数据
	return true # 返回数据注册成功


# 获取数据
func get_data(unique_name: String, default = null):
	if unique_name in data: # 如果数据记录存在
		return data[unique_name] # 返回数据内容
	else: # 如果数据记录不存在
		var message = "(缺失数据-已忽略)Data not found:%s" % unique_name # 生成提示信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志
		return default # 返回默认值


# 更新数据 返回是否成功
func set_data(unique_name: String, value) -> bool:
	if not unique_name in data: # 如果数据不存在
		var message = "(缺失数据-已忽略)Data not found:%s" % unique_name # 生成提示信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志
		return false # 返回更新失败
	data[unique_name] = value # 如果有数据则更新
	return true # 返回更新成功
