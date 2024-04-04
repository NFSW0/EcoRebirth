class_name _UIManager
extends CanvasLayer
# UI界面管理器

var ui_resources := {} # 存储UI资源

# 判断名称可用 通常与注册方法一起使用
func name_available(ui_name: String) -> bool:
	return not ui_resources.has(ui_name) # 如果名称不唯一则返回false

# 注册UI界面
func register_ui(ui_name : String, ui_scene : PackedScene):
	if ui_name not in ui_resources: # 如果名称不重复
		ui_resources[ui_name] = {"ui_name":ui_name, "ui_scene":ui_scene} # 注册新UI界面
	else: # 如果名称重复
		var message = "(重复注册UI-已忽略)Warning: UI resource '%s' already exists." % ui_name # 生成错误信息
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), message) # 输出日志

# 获取UI界面
func get_ui(ui_name : String):
	# 检查UI是否已经加载
	for child_node in get_children(): # 遍历全部子节点
		if child_node.name == ui_name: # 如果同名子节点存在
			LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "UI已存在，直接返回: %s" % ui_name) # 输出新日志
			return child_node # 返回该节点
	# 加载新UI
	if ui_resources.has(ui_name): # 如果没有同名子节点且资源中有同名节点
		if (ui_resources[ui_name] as PackedScene).can_instantiate(): # 如果该资源可实例化
			var new_node = (ui_resources[ui_name] as PackedScene).instantiate() # 实例化UI界面
			new_node.name = ui_name # 设置UI名称
			add_child(new_node) # 设为当前节点的子节点
			LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "实例化新UI: %s" % ui_name) # 输出新日志
			return new_node # 返回新节点
		else: # 如果资源不可实例化
			LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), "UI资源无法实例化: %s" % ui_name) # 输出新日志
	else: # 如果不存在同名资源
		LogAccess.new().log_message(LogAccess.LogLevel.WARNING, type_string(typeof(self)), "未找到UI资源: %s" % ui_name) # 输出新日志
	return null # 缺失资源
