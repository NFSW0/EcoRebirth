class_name NewRoleMenu
extends Control

const player_data_name = "ecorebirth_player" # 玩家数据集索引值
var edit_line_has_focus = false # 是否有焦点 用于处理点击数字键和输入框冲突
@onready var option_box = %OptionBox # 选项盒子 用于处理数字快捷键
@onready var player_name = %Name # 玩家名称输入框
@onready var player_body = %Body # 玩家身体选择按钮
@onready var player_face = %Face # 玩家表情选择按钮
@onready var create = %Create # 创建按钮
@onready var cancel = %Cancel # 取消按钮

func _input(event): # 通过数字实现快速点击对应按钮
	if event.is_released() and event is InputEventKey and not edit_line_has_focus: # 键盘松开
		get_viewport().set_input_as_handled() # 阻止ESC事件进一步传递
		_handle_numeric_input(event) # 处理数字输入的函数
	elif event.is_action_pressed("ui_cancel"): # ESC输入
		get_viewport().set_input_as_handled() # 阻止ESC事件进一步传递
		_on_cancel_pressed() # 触发取消按钮的点击事件
	elif event.is_action_pressed("ui_accept") and not edit_line_has_focus: # 按下回车且没有焦点时
		_on_create_pressed() # 触发创建存档事件

func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if "1" <= key_str and key_str <= "9" and not edit_line_has_focus: # 确认是数字键
		var index = int(key_str) - 1 # 获取索引
		if index < option_box.get_child_count(): # 防止溢出
			var control = option_box.get_child(index) # 获取按钮
			control.grab_focus() # 获取焦点

func _close(): # 关闭此面板 主要用于切换面板时剔除原面板
	queue_free()

#region 创建和取消按钮
func _on_cancel_pressed():
	UIManager.get_ui("RoleMenu", self) # 加载存档面板
	AudioManager.play_audio("Interaction") # 点击音效
	_close() # 关闭此面板
func _on_cancel_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
func _on_create_pressed():
	if player_name.text.is_empty(): # 空名称判断
		AudioManager.play_audio("Warning") # 点击音效
		player_name.self_modulate = Color.RED # 设置为红色
		return # 结束处理
	else: # 判断名称有效
		player_name.self_modulate = Color.WHITE # 设置为默认颜色
	var player_data := {} # 新建玩家数据
	player_data["body"] = "Body1" # 设置玩家数据
	player_data["face"] = "Face1" # 设置玩家数据
	if DataManager.has_registered(player_data_name): # 如果数据已有玩家列表
		var player_datas:Dictionary = DataManager.get_data(player_data_name) # 获取玩家列表
		player_datas[player_name.text] = player_data # 添加新玩家数据
		DataManager.set_data(player_data_name, player_datas) # 覆盖旧玩家列表
	else: # 如果没有存档列表
		DataManager.register_data(player_data_name, {player_name.text:player_data}) # 新注册存档列表
	UIManager.get_ui("RoleMenu", self) # 加载存档面板
	AudioManager.play_audio("Interaction") # 点击音效
	_close() # 关闭面板
func _on_create_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
#endregion

#region 名称输入框
func _on_name_text_submitted(_new_text):
	AudioManager.play_audio("Interaction") # 点击音效
	edit_line_has_focus = false
	player_name.release_focus()
func _on_name_focus_entered():
	edit_line_has_focus = true
#endregion
