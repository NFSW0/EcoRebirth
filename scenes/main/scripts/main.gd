extends Node

func _ready():
	await _load_setting("") # 应用玩家设置
	UIManager.get_ui("TitleScreen", self) # 标题界面

func _load_setting(path: String): # 加载设置
	var array = SettingManager.get_options(path) # 获取全部注册的设置
	var is_option = array[0] # 获取标识位
	array.remove_at(0) # 移除标识位
	if is_option: # 如果是选项
		var save_value = DataManager.get_data(path) # 读取保存的数值
		if save_value != null: # 如果有存储的值
			SettingManager.apply_setting(path, save_value) # 应用设置
	else: # 如果是组
		for group_name in array: # 递归加载设置
			var new_path = path + "/" + group_name # 生成新路径
			await _load_setting(new_path) # 递归
