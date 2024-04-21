class_name MultiHost
extends Control
# 创建多人游戏

var edit_line_has_focus = false # 是否有焦点 用于处理点击数字键和输入框冲突
@onready var max_connections = %MaxConnections # 最大连接数
@onready var port = %Port # 端口
@onready var host = %Host # 创建
@onready var back = %Back # 返回

func _input(event): # 通过数字实现快速点击对应按钮
	if event.is_released() and event is InputEventKey: # 键盘松开
		_handle_numeric_input(event) # 处理数字输入的函数
	elif event.is_action_pressed("ui_cancel"): # ESC输入
		_on_back_pressed() # 触发返回事件
	elif event.is_action_pressed("ui_accept") and not edit_line_has_focus: # 按下回车且没有焦点时
		_on_host_pressed() # 触发创建事件

func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if not edit_line_has_focus: # 如果没有焦点
		match key_str:
			"1":
				max_connections.grab_focus() # 最大连接数输入框获取焦点
			"2":
				port.grab_focus() # 端口输入框获取焦点

func _close():
	queue_free()

#region 返回按钮
func _on_back_pressed():
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MultiMenu", self) # 加载多人面板
	_close() # 关闭此面板
func _on_back_mouse_entered():
	AudioManager.play_audio("Focus") # 聚焦音效
#endregion

#region 创建按钮
func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(12766 if port.text.is_empty() else int(port.text), 5 if max_connections.text.is_empty() else int(max_connections.text))
	if error != OK:
		AudioManager.play_audio("Warning") # 警告音效
		UIManager.get_ui("MessageBox", self).send_message("Failed to host. Please try to replace the port.") # 发送提示信息
		return
	multiplayer.multiplayer_peer = peer
	LogAccess.new().log_message(LogAccess.LogLevel.INFO, type_string(typeof(self)), "创建多人游戏") # 记录日志
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("ArchiveMenu", self) # 加载存档面板
	_close() # 关闭此面板
func _on_host_mouse_entered():
	AudioManager.play_audio("Focus") # 聚焦音效
#endregion

#region 最大链接数输入框
func _on_max_connections_focus_entered():
	edit_line_has_focus = true
	AudioManager.play_audio("Focus") # 聚焦音效
func _on_max_connections_text_submitted(_new_text):
	edit_line_has_focus = false
	max_connections.release_focus()
	AudioManager.play_audio("Interaction") # 点击音效
func _on_max_connections_text_changed(new_text): # 输入合理性检测
	if new_text.is_valid_int(): # 如果可以转为数值
		if int(new_text) > 4095 or int(new_text) < 1:
			port.self_modulate = Color.RED # 设置为红色
			AudioManager.play_audio("Warning") # 警告音效
			UIManager.get_ui("MessageBox", self).send_message("Value overflow, please enter a value between 1 and 4095.") # 发送提示信息
		max_connections.self_modulate = Color.WHITE # 设置为默认颜色
	else: # 如果不可转到数值
		max_connections.self_modulate = Color.RED # 设置为红色
		AudioManager.play_audio("Warning") # 警告音效
		UIManager.get_ui("MessageBox", self).send_message("Please enter the number (0-9).") # 发送提示信息
#endregion

#region 端口输入框
func _on_port_focus_entered():
	edit_line_has_focus = true
	AudioManager.play_audio("Focus") # 聚焦音效
func _on_port_text_submitted(_new_text):
	edit_line_has_focus = false
	port.release_focus()
	AudioManager.play_audio("Interaction") # 点击音效
func _on_port_text_changed(new_text): # 输入合理性检测
	if new_text.is_valid_int(): # 如果可以转为数值
		if int(new_text) > 65535 or int(new_text) < 0:
			port.self_modulate = Color.RED # 设置为红色
			AudioManager.play_audio("Warning") # 警告音效
			UIManager.get_ui("MessageBox", self).send_message("Value overflow, please enter a value between 0 and 65535.") # 发送提示信息
		port.self_modulate = Color.WHITE # 设置为默认颜色
	else: # 如果不可转到数值
		port.self_modulate = Color.RED # 设置为红色
		AudioManager.play_audio("Warning") # 警告音效
		UIManager.get_ui("MessageBox", self).send_message("Please enter the number (0-9).") # 发送提示信息
#endregion
