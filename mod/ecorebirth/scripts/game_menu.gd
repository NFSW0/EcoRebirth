class_name GameMenu
extends Control


signal on_close() # 关闭信号 用于关闭灰幕
var main_scene_path = "res://scenes/main/scenes/main.tscn" # 主场景路径
@onready var option_box = %OptionBox # 选项盒

func on_ui_loaded(_requester): # 被灰幕加载后执行
	pass


func _unhandled_input(event): # 通过数字实现快速点击对应按钮
	if visible and event.is_action_pressed("ui_cancel"): # ESC输入
		_on_resume_game_pressed() # 触发返回
	elif visible and event.is_released() and event is InputEventKey: # 键盘松开
		_handle_numeric_input(event) # 处理键盘松开


func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if "1" <= key_str and key_str <= "9": # 确认是数字键
		var index = int(key_str) - 1 # 获取索引
		if index < option_box.get_child_count(): # 防止溢出
			var button = option_box.get_child(index) # 获取按钮
			button.emit_signal("pressed") # 触发点击事件


func _close(): # 关闭游戏菜单
	queue_free()
	on_close.emit()


func _on_resume_game_pressed(): # 点击继续游戏
	AudioManager.play_audio("Interaction") # 点击音效
	_close()
func _on_resume_game_mouse_entered():
	AudioManager.play_audio("Focus") # 聚焦音效


func _on_setting_pressed():
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("SettingMenu", self) # 设置界面
	hide()
func _on_setting_mouse_entered():
	AudioManager.play_audio("Focus") # 聚焦音效


func _on_exit_pressed():
	AudioManager.play_audio("Interaction") # 点击音效
	get_tree().change_scene_to_file(main_scene_path) # 返回主菜单
	_close()
func _on_exit_mouse_entered():
	AudioManager.play_audio("Focus") # 聚焦音效
