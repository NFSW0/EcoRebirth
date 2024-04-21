class_name MultiManu
extends Control

@onready var option_box = %OptionBox # 选项盒
@onready var back = %Back # 返回按钮
@onready var host_game = %HostGame # 创建游戏
@onready var join_game = %JoinGame # 加入游戏

func _ready():
	multiplayer.multiplayer_peer.close() # 清理可能的占位

func _close():
	queue_free()

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

#region 返回按钮
func _on_back_pressed():
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MainMenu", self) # 加载主菜单面板
	_close()
func _on_back_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
#endregion

#region 创建按钮
func _on_host_game_pressed():
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MultiHost", self) # 加载主菜单面板
	_close()
func _on_host_game_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
#endregion

#region 加入按钮
func _on_join_game_pressed():
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MultiJoin", self) # 加载主菜单面板
	_close()
func _on_join_game_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
#endregion
