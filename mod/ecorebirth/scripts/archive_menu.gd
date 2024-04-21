class_name ArchiveMenu
extends Control
# 存档菜单 显示并选择已有存档或新建存档

const archives_data_name = "ecorebirth_archive" # 存档集合数据名
const play_scene_path = "res://scenes/play/scenes/play.tscn" # 游玩场景路径
@onready var archive_box = %ArchiveBox # 存档选项盒
@onready var back = %Back # 返回

func _ready():
	_refresh()

func _input(event): # 通过数字实现快速点击对应按钮
	if event.is_released() and event is InputEventKey: # 键盘松开
		_handle_numeric_input(event) # 处理数字输入的函数
	elif event.is_action_pressed("ui_cancel"): # ESC输入
		_on_back_pressed() # 触发返回

func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if "1" <= key_str and key_str <= "9": # 确认是数字键
		var index = int(key_str) - 1 # 获取索引
		if index < archive_box.get_child_count(): # 防止溢出
			var button = archive_box.get_child(index) # 获取按钮
			button.emit_signal("pressed") # 触发点击事件

func _close(): # 关闭此面板 主要用于切换面板时剔除原面板
	queue_free()

func _refresh(): # 刷新显示
	for child in archive_box.get_children(): # 遍历所有选项
		child.queue_free() # 清理选项
	var archive_array:Dictionary = DataManager.get_data(archives_data_name,{}) # 获取存档列表
	_add_archive_option(archive_array) # 添加存档选项(点击事件：使用存档)
	_add_new_archive_option() # 添加新建选项(点击事件：进入新建界面)

func _add_archive_option(archive_array:Dictionary): # 添加存档选项
	for archive in archive_array.keys(): # 遍历存档集合
		var button = Button.new() # 新建选项
		button.text = archive # 修改按钮文字
		button.connect("pressed", func(): # 设置按钮点击事件
			AudioManager.play_audio("Interaction") # 点击音效
			var archive_data = archive_array[archive] # 读取存档数据
			if DataManager.has_registered("using_archive_data"): # 设置为使用中的存档
				DataManager.set_data("using_archive_data",archive_data)
			else:
				DataManager.register_data("using_archive_data",archive_data)
			get_tree().change_scene_to_file(play_scene_path) # 场景跳转
			_close() # 关闭此面板
			)
		button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置鼠标触碰事件
		archive_box.add_child(button) # 添加选项

func _add_new_archive_option(): # 添加新建选项
	var button = Button.new() # 新建选项
	button.text = "+" # 修改按钮文字
	button.connect("pressed", func(): # 设置按钮点击事件
		AudioManager.play_audio("Interaction") # 点击音效
		UIManager.get_ui("NewArchiveMenu", self) # 加载主菜单面板
		_close() # 关闭此面板
		)
	button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置鼠标触碰事件
	archive_box.add_child(button) # 添加选项

#region 返回按钮
func _on_back_pressed(): # 返回按钮点击事件
	AudioManager.play_audio("Interaction") # 点击音效
	UIManager.get_ui("MainMenu", self) # 加载主菜单面板
	_close()
func _on_back_mouse_entered(): # 返回按钮触碰事件
	AudioManager.play_audio("Focus") # 鼠标触碰音效
#endregion
