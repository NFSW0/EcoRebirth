class_name _UIManager
extends CanvasLayer
# UI界面管理器 无需多人RPC

var ui_registry = {} # 存储所有注册的UI

func register_ui(ui_name: String, callback: Callable, scene: PackedScene) -> String: # 注册UI 会自动改进名称 返回最终注册的名称
	var final_name = ui_name # 存储最终注册的名称
	var count = 1 # 用于循环改进名称
	while final_name in ui_registry: # 如果名称重复
		final_name = "%s_%d" % [ui_name, count] # 改进名称
		count += 1 # 循环变量
	ui_registry[final_name] = {"scene": scene, "callback": callback} # 注册UI
	return final_name # 返回最终注册的名称

func get_ui(ui_name: String, requester: Node) -> Node: # 获取UI
	if ui_name in ui_registry: # 如果UI已注册
		var ui_node = _find_child_by_name(ui_name) # 尝试获取已加载的同名UI
		if ui_node: # 如果有已加载的同名UI
			return ui_node # 返回加载的UI实例
		else: # 如果没有同名UI被加载
			var ui_instance = (ui_registry[ui_name]["scene"] as PackedScene).instantiate() # 实例化UI场景
			ui_instance.name = ui_name # 设置节点名称用于防止重复加载UI
			add_child(ui_instance) # 添加为子物体
			ui_registry[ui_name]["callback"].call(requester) # 加载回调，传递请求者
			return ui_instance # 返回UI实例
	else: # 如果UI没注册
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), "UI not found: %s" % ui_name) # 输出日志
		return null # 返回空

func _find_child_by_name(ui_name: String) -> Node: # 通过名称检索UI实例
	for child in get_children(): # 遍历全部子对象
		if child.name == ui_name: # 如果名称相同
			return child # 返回该节点
	return null # 如果没有同名节点则返回空
