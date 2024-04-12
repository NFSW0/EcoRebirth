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
	elif event.is_action_released("ui_cancel"): # ESC输入
		_on_back_pressed() # 触发返回

func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if "1" <= key_str and key_str <= "9": # 确认是数字键
		var index = int(key_str) - 1 # 获取索引
		if index < option_box.get_child_count(): # 防止溢出
			var button = option_box.get_child(index) # 获取按钮
			if button.has_focus(): # 如果有焦点
				button.emit_signal("pressed") # 触发点击事件
			else: # 如果没有焦点
				AudioManager.play_audio("Focus")
				button.grab_focus() # 获得焦点

func _close(): # 关闭此面板 主要用于切换面板时剔除原面板
	queue_free()

func _refresh_optioins(): # 刷新选项显示
	for child in option_box.get_children(): # 遍历所有选项
		child.queue_free() # 清理选项
	var options = SettingManager.get_options(option_path) # 获取选项
	var is_option = options[0] # 获取标识位
	options.remove_at(0) # 移除标识位
	if is_option: # 如果是选项值
		_add_option(options) # 添加选项
	else: # 如果是选项组
		_add_group(options) # 添加选项组

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
	setting_button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置按钮点击事件
	return setting_button
func _on_group_button_pressed(group_name): # 选项点击事件
	AudioManager.play_audio("Interaction") # 点击音效
	var old_path = option_path # 获取旧路径
	var new_path = old_path + "/" + group_name # 生成新路径
	option_path = new_path # 应用新路径
	_refresh_optioins() # 刷新选项
#endregion
#region 处理调整选项值
func _add_option(options: Array): # 添加选项
	for index in options.size(): # 遍历全部选项
		var button = _generate_option_button(options[index]) # 生成选项按钮
		button.name = str(index + 1) # 设置节点编号
		option_box.add_child(button) # 添加到选项盒
func _generate_option_button(value) -> Button: # 构造选项按钮
	var setting_button = Button.new() # 新建按钮节点
	setting_button.text = str(value) # 设置按钮显示的文本
	setting_button.connect("pressed", _on_option_button_pressed.bind(value)) # 设置按钮点击事件
	return setting_button # 返回选项按钮
func _on_option_button_pressed(value): # 点击选项值事件
	AudioManager.play_audio("Interaction") # 点击音效
	SettingManager.setting_value(option_path, value) # 应用设置
	_on_back_pressed() # 回到主菜单
#endregion
#region 返回按钮
func _on_back_pressed(): # 返回按钮点击事件
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MainMenu", self) # 加载主菜单面板
	_close()
func _on_back_mouse_entered(): # 返回按钮触碰事件
	AudioManager.play_audio("Focus")
#endregion
