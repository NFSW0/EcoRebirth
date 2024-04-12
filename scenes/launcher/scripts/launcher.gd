extends Control
# 项目启动器 注册资源 处理进入标题界面前的事件 完成资源注册后进入标题界面

const mod_pack_file_name = "pack.json" # 模组注册文件的固定名称
const mods_dir = "res://mod/" # 模组文件识别起始目录

var message_id = 1 # 消息编号 用于产生唯一名称
var message_duration = 1 # 消息持续时间
var message_fade_time = 0.5 # 消息淡出时间
var interval = 0.05 # 处理间隔
var mod_dir_paths = ["res://mod/ecorebirth/"] # 存储模组目录
var main_scene_path = "res://scenes/main/scenes/main.tscn" # 主场景路径

func _ready():
	if not OS.has_feature("editor"): # 如果是导出项目
		mod_dir_paths.clear() # 清理目录集合
		await _link_mods() # 加载MOD
	await _register_resources() # 注册资源
	_launcher_game(main_scene_path) # 进入标题屏

func _add_message(label_text): # 显示加载信息
	# 添加Label
	var new_label = Label.new()
	new_label.text = label_text
	new_label.name = str(message_id)
	%MessageBox.add_child(new_label)
	# 淡出Label
	message_id += 1
	var tween = new_label.create_tween()
	tween.tween_interval(message_duration)
	tween.tween_property(new_label, "self_modulate", Color.TRANSPARENT, message_fade_time)
	tween.tween_callback(new_label.queue_free)

func _link_mods(): # 加载PCK
	# 获取程序目录路径
	var exe_directory_path = _get_exe_directory_path()
	if exe_directory_path:
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "获取程序目录路径: %s" % exe_directory_path) # 记录日志
	# 生成模组目录路径
	var mods_directory_path = _generate_mods_directory(exe_directory_path)
	if mods_directory_path:
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "生成模组目录路径: %s" % mods_directory_path) # 记录日志
	# 获取模组文件路径数组
	var mod_file_path_array = await _get_mod_file_path_array(mods_directory_path)
	if mod_file_path_array:
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "发现模组文件: %s" % mod_file_path_array) # 记录日志
	# 加载模组文件
	var invalid_mods = _load_mod_files(mod_file_path_array)
	if invalid_mods:
		LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "无效模组文件: %s" % invalid_mods) # 记录日志

func _get_exe_directory_path() -> String: # 获取程序目录路径
	return OS.get_executable_path().get_base_dir() # 返回程序所在地址

func _generate_mods_directory(exe_directory_path: String) -> String: # 生成模组目录路径
	return exe_directory_path.path_join("mods")

func _get_mod_file_path_array(mods_directory_path: String) -> Array: # 获取模组文件路径数组
	var mod_file_path_array: Array = []
	var mods_directory = DirAccess.open(mods_directory_path)
	if mods_directory: # 如果正常打开模组文件夹
		mods_directory.list_dir_begin()
		var file_name = mods_directory.get_next()
		while file_name != "":
			if not mods_directory.current_is_dir() and file_name.get_extension() == "pck":
				mod_file_path_array.append(mods_directory_path.path_join(file_name))
			file_name = mods_directory.get_next()
		mods_directory.list_dir_end()
	else: # 如果未能打开文件夹
		var error_message = "尝试访问模组文件夹时出错，请确认文件夹可访问:%s" % mods_directory_path
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), error_message) # 记录错误日志
		var accept_dialog = AcceptDialog.new() # 创建并弹出错误提示对话框
		accept_dialog.borderless = true
		accept_dialog.always_on_top = true
		accept_dialog.dialog_autowrap = true
		accept_dialog.dialog_text = error_message
		accept_dialog.ok_button_text = "确认"
		add_child(accept_dialog)
		accept_dialog.popup_centered_ratio(0.3)
		await accept_dialog.confirmed # 等待用户确认后退出应用，因为游戏主体也是mod
		get_tree().quit()
	return mod_file_path_array

func _load_mod_files(mod_file_path_array: Array) -> Array: # 加载模组文件
	var invalid_mods: Array = []
	for mod_file_path in mod_file_path_array:
		if not ProjectSettings.load_resource_pack(mod_file_path): # 加载失败
			invalid_mods.append(mod_file_path) # 记录无效PCK
		else: # 如果加载成功 保留模组名称和文件路径
			mod_dir_paths += _find_mod_folder(mods_dir) # 检索包含的模组并获取目录
			_add_message(mod_file_path) # 输出进度
	return invalid_mods

func _find_mod_folder(start_path: String) -> Array: # 递归识别模组目录
	var directories_with_pack = [] # 存储模组目录
	if DirAccess.dir_exists_absolute(mods_dir): # 如果模组库路径存在
		var dir = DirAccess.open(start_path) # 打开文件夹
		if dir: # 如果成功打开
			dir.list_dir_begin() # 开始列举目录
			var file_name = dir.get_next() # 获取下一个文件
			while file_name != "": # 如果文件有效
				if dir.current_is_dir() and not file_name.begins_with("."): # 跳过导航点文件
					directories_with_pack += _find_mod_folder(start_path.path_join(file_name)) # 递归查找子文件夹
				elif file_name == "pack.json": # 如果文件名是"pack.json"
					directories_with_pack.append(start_path) # 添加当前路径到结果列表
					break # 只要找到一个就可以跳出循环 每个文件夹下只有一个pack.json
				file_name = dir.get_next() # 获取下一个文件名
			dir.list_dir_end() # 结束列举
	return directories_with_pack # 返回识别出的目录路径

func _register_resources(): # 注册资源
	for mod_dir_path in mod_dir_paths: # 遍历全部模组文件夹
		var register_data = _load_register_data(mod_dir_path) # 获取模组注册数据
		await _register_audio_resources(register_data["audio"]) # 注册外部音频资源
		await _register_ui_resources(register_data["ui"]) # 注册外部UI资源
		await _register_texture_resource(register_data["texture"]) # 注册外部材质
		await _register_setting_resource(register_data["setting"]) # 注册外部设置

func _load_register_data(mod_path : String) -> Dictionary: # 获取pack.json存储的注册数据
	var register_data = {} # 待存储解析的数据
	var register_file_path = mod_path.path_join(mod_pack_file_name) # 生成文件路径
	if ResourceLoader.exists(register_file_path): # 如果文件存在
		var file = FileAccess.open(register_file_path,FileAccess.READ) # 创建文件处理器
		if file: # 如果文件正常打开
			var json_text = file.get_as_text() # 读取文件字符
			var json_handler = JSON.new() # 创建JSON处理器
			var error = json_handler.parse(json_text) # 尝试解析JSON文本
			if error == OK: # JSON文本解析成功
				register_data = json_handler.data # 保留解析数据
			else: # JSON文本解析失败
				var error_message = "数据文件解析失败:[行%s]%s" % [json_handler.get_error_line(), json_handler.get_error_message()] # 生成错误信息
				LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), error_message) # 输出错误日志
		else: # 如果文件无法打开
			LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), "无法打开文件: %s" % register_file_path) # 输出日志
	return register_data # 返回解析的数据

func _register_audio_resources(_audio_resources): # 注册音频资源
	for audio in _audio_resources:
		_add_message(audio["path"])
		if ResourceLoader.exists(audio["path"]):
			var audio_stream = load(audio["path"])
			var audio_bus = AudioManager.get_audio_bus_by_name(audio["bus"])
			AudioManager.register_audio(audio["name"], audio_bus, audio_stream)
			await get_tree().create_timer(interval).timeout

func _register_ui_resources(_ui_resources): # 注册UI资源
	for ui in _ui_resources:
		_add_message(ui["path"])
		if ResourceLoader.exists(ui["path"]):
			var ui_scene = load(ui["path"])
			var callback = Callable(load(ui["callback_script"]),ui["callback_method"])
			UIManager.register_ui(ui["name"], ui_scene, callback)
			await get_tree().create_timer(interval).timeout

func _register_texture_resource(_texture_resource): # 注册材质
	for texture in _texture_resource:
		_add_message(texture["path"])
		if ResourceLoader.exists(texture["path"]):
			var _texture = load(texture["path"])
			TextureManager.register_texture(texture["name"], _texture)
			await get_tree().create_timer(interval).timeout

func _register_setting_resource(_setting_resource): # 注册设置
	for setting in _setting_resource:
		_add_message(setting["path"])
		var callback = Callable(load(setting["callback_script"]),setting["callback_method"])
		SettingManager.register_option(setting["path"], setting["options"], [callback])
		await get_tree().create_timer(interval).timeout

func _launcher_game(_main_scene_path: String) -> String: # 进入开始菜单(标题屏幕)
	if not ResourceLoader.exists(_main_scene_path):
		LogAccess.new().log_message(LogAccess.LogLevel.ERROR, type_string(typeof(self)), "主场景路径无效: %s" % _main_scene_path) # 记录错误日志
		return "游戏启动失败"
	get_tree().call_deferred("change_scene_to_file", _main_scene_path)
	return "游戏启动成功"
