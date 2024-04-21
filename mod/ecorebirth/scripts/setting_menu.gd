class_name SettingMenu
extends Control
# 加载设置选项 响应选择

var option_path = "" # 选项路径
@onready var option_box = %OptionBox # 选项盒
@onready var back = %Back # 返回按钮

func _ready():
	_refresh_optioins()

func _input(event): # 通过数字实现快速点击对应按钮
	if event.is_released() and event is InputEventKey: # 键盘松开
		_handle_numeric_input(event) # 处理数字输入的函数
	elif event.is_action_pressed("ui_cancel"): # ESC输入
		_on_back_pressed() # 触发返回

func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if "1" <= key_str and key_str <= "9": # 确认是数字键
		var index = int(key_str) - 1 # 获取索引
		if index < option_box.get_child_count(): # 防止溢出
			var button = option_box.get_child(index) # 获取按钮
			button.emit_signal("pressed") # 触发点击事件

func _close(): # 关闭此面板 主要用于切换面板时剔除原面板
	queue_free()

func _refresh_optioins(): # 刷新选项显示
	for child in option_box.get_children(): # 遍历所有选项
		child.queue_free() # 清理选项
	var options = SettingManager.get_options(option_path) # 获取选项
	var is_option = options[0] # 获取标识位
	options.remove_at(0) # 移除标识位
	if is_option: # 如果是选项值
		#region 类型判断 布尔 字符 数值 安排设置控件
		var is_boolean = true
		var is_string = true
		var is_float = true
		for element in options:
			if typeof(element) != TYPE_BOOL:
				is_boolean = false
			if typeof(element) != TYPE_STRING:
				is_string = false
			if typeof(element) != TYPE_FLOAT:
				is_float = false
		if is_boolean:
			_add_option(options) # 添加单选选项
		elif is_string:
			_add_option(options) # 添加单选选项
		elif is_float:
			var control = _add_num_option(options) # 添加数值选项
			control.grab_focus() # 获取焦点
		else:
			return "Array contains mixed types"
		#endregion
	else: # 如果是选项组
		_add_group(options) # 添加选项组

#region 处理数值选项
func _add_num_option(values: Array) -> LineEdit: # 添加并返回输入框
	var max_value = find_max_value(values) # 计算最大值
	var min_value = find_min_value(values) # 计算最小值
	var line_edit = _generate_line_edit(min_value, max_value) # 新建输入框
	option_box.add_child(line_edit) # 添加到选项盒
	return line_edit # 返回添加的控件
func find_max_value(values: Array) -> float: # 求最大值
	assert(values.size() > 0, "数组不能为空")
	var max_val = values[0]
	for value in values:
		if value > max_val:
			max_val = value
	return max_val
func find_min_value(values: Array) -> float: # 求最小值
	assert(values.size() > 0, "数组不能为空")
	var min_val = values[0]
	for value in values:
		if value < min_val:
			min_val = value
	return min_val
func map_value(input_value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float: # 从0~100求原值
	return (input_value - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
func reverse_map_value(output_value: float, out_min: float, out_max: float, in_min: float, in_max: float) -> float: # 从原值求0~100的映射值
	return (output_value - out_min) / (out_max - out_min) * (in_max - in_min) + in_min
func _generate_line_edit(min_value, max_value) -> LineEdit: # 生成输入框
	var line_edit = LineEdit.new() # 新建输入框
	var save_value = DataManager.get_data(option_path, 0) # 读取保存的数值
	line_edit.placeholder_text = str(reverse_map_value(save_value, min_value, max_value, 0, 100)) # 设置占位符文本 显示当前设置的值
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER # 设置居中字符
	line_edit.caret_blink = true # 光标闪烁
	line_edit.connect("text_changed",func(new_text): # 设置text_changed响应事件
		if new_text.is_valid_int(): # 如果输入可有效转为数值
			line_edit.self_modulate = Color.WHITE # 设置为默认颜色 提示输入有效
			var input_value = int(new_text) # 获取数值
			input_value = clamp(input_value, 0, 100)  # 确保值在0到100之间
			line_edit.text = str(input_value) # 修正输入值
			var actual_value = map_value(input_value, 0, 100, min_value, max_value) # 求映射值
			SettingManager.apply_setting(option_path, actual_value) # 应用真值
			if DataManager.has_registered(option_path): # 判断已注册
				DataManager.set_data(option_path, actual_value) # 保存真值
			else: # 判断未注册
				DataManager.register_data(option_path, actual_value)# 保存真值
			var text_length = line_edit.text.length() # 获取文本长度
			line_edit.set_caret_column(text_length) # 设置光标位置到文本末尾
		else: # 如果输入无法转成数值
			line_edit.self_modulate = Color.RED) # 设置为红色 提示输入无效
	line_edit.connect("text_submitted",func(new_text): # 设置text_submitted响应事件
		if new_text.is_valid_int(): # 如果输入可有效转为数值
			AudioManager.play_audio("Interaction") # 点击音效
			_on_back_pressed()# 回到主菜单
		else:
			AudioManager.play_audio("Warning")) # 警告音效
	return line_edit # 返回添加的控件
func _on_text_submitted(new_text): # 完成设置
	AudioManager.play_audio("Interaction") # 点击音效
	SettingManager.apply_setting(option_path, float(new_text)) # 应用设置
	_on_back_pressed() # 回到主菜单
#endregion
#region 处理点击选项组
func _add_group(groups: Array): # 添加选项组
	for index in groups.size(): # 遍历全部组
		var button = _generate_group_button(groups[index]) # 生成组按钮
		button.name = str(index + 1) # 设置节点编号
		option_box.add_child(button) # 添加到选项盒
func _generate_group_button(group_name) -> Button: # 构造组按钮
	var setting_button = Button.new() # 新建按钮节点
	setting_button.text = group_name # 设置按钮显示的文本
	setting_button.connect("pressed", _on_group_button_pressed.bind(group_name)) # 设置按钮点击事件
	setting_button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置鼠标触碰事件
	return setting_button
func _on_group_button_pressed(group_name): # 选项点击事件
	AudioManager.play_audio("Interaction") # 点击音效
	var old_path = option_path # 获取旧路径
	var new_path = old_path + "/" + group_name # 生成新路径
	option_path = new_path # 应用新路径
	_refresh_optioins() # 刷新选项
#endregion
#region 处理调整选项值
func _add_option(values: Array): # 添加选项
	for index in values.size(): # 遍历全部选项
		var button = _generate_option_button(values[index]) # 生成选项按钮
		button.name = str(index + 1) # 设置节点编号
		option_box.add_child(button) # 添加到选项盒
func _generate_option_button(value) -> Button: # 构造选项控件 布尔和枚举采用按钮 数值采用输入框
	var setting_button = Button.new() # 新建按钮节点
	var save_value = DataManager.get_data(option_path) # 读取保存的数值
	if save_value != null and save_value == value: # 如果有存储的值且同名
		setting_button.disabled = true # 设置为不可用 提示这是当前的设置值
	setting_button.text = str(value) # 设置按钮显示的文本
	if not setting_button.disabled: # 由于disable按钮依然可以通过脚本触发 在此取消监听添加
		setting_button.connect("pressed", _on_option_button_pressed.bind(value)) # 设置按钮点击事件
		setting_button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置鼠标触碰事件
	return setting_button # 返回选项按钮
func _on_option_button_pressed(value): # 完成设置
	AudioManager.play_audio("Interaction") # 点击音效
	SettingManager.apply_setting(option_path, value) # 应用设置
	if DataManager.has_registered(option_path): # 判断已注册
		DataManager.set_data(option_path, value) # 保存映射值
	else: # 判断未注册
		DataManager.register_data(option_path, value)# 保存映射值
	_on_back_pressed() # 回到主菜单
#endregion
#region 返回按钮
func _on_back_pressed(): # 返回按钮点击事件
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MainMenu", self) # 加载主菜单面板
	DataManager.save_data() # 保存数据
	_close()
func _on_back_mouse_entered(): # 返回按钮触碰事件
	AudioManager.play_audio("Focus")
#endregion
