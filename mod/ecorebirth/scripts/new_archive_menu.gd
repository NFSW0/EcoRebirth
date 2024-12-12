class_name NewArchiveMenu
extends Control
# 新建存档菜单 添加新存档


const archives_data_name = "ecorebirth_archive" # 存档集合数据名
var archive_data = ArchiveData.new() # 新建存档数据
var edit_line_has_focus = false # 是否有焦点 用于处理点击数字键和输入框冲突
var archive_name_ui # 名称UI
var archive_seed_ui # 种子UI
var archive_circle_time_ui # 周期选择UI
var archive_difficulty_ui # 难度选择UI
@onready var option_box = %OptionBox # 选项盒
@onready var create = %Create # 创建按钮
@onready var cancel = %Cancel # 取消按钮

func _ready():
	_refresh()

func _input(event): # 通过数字实现快速点击对应按钮
	if event.is_released() and event is InputEventKey and not edit_line_has_focus: # 键盘松开
		_handle_numeric_input(event) # 处理数字输入的函数
	elif event.is_action_pressed("ui_cancel"): # ESC输入
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

func _refresh(): # 刷新显示
	for child in option_box.get_children(): # 遍历所有选项
		child.queue_free() # 清理选项
	
	var archive_name = LineEdit.new() # 存档名称设置
	archive_name.alignment = HORIZONTAL_ALIGNMENT_CENTER
	archive_name.placeholder_text = "Name"
	archive_name.connect("focus_entered", func():
		edit_line_has_focus = true
		)
	archive_name.connect("text_submitted", func(_new_text):
		AudioManager.play_audio("Interaction") # 点击音效
		edit_line_has_focus = false
		archive_name.release_focus()
		)
	archive_name_ui = archive_name
	option_box.add_child(archive_name)
	
	var archive_seed = LineEdit.new() # 存档种子设置
	archive_seed.alignment = HORIZONTAL_ALIGNMENT_CENTER
	archive_seed.placeholder_text = "Seed"
	archive_seed.connect("focus_entered", func():
		edit_line_has_focus = true
		)
	archive_seed.connect("text_submitted", func(_new_text):
		AudioManager.play_audio("Interaction") # 点击音效
		edit_line_has_focus = false
		archive_seed.release_focus()
		)
	archive_seed_ui = archive_seed
	option_box.add_child(archive_seed)
	
	var archive_circle_time = Button.new() # 存档周期设置
	archive_circle_time.text = "CircleTime:Default"
	archive_circle_time.connect("pressed",func():
		AudioManager.play_audio("Interaction") # 点击音效
		match archive_circle_time.text:
			"CircleTime:Default":
				archive_circle_time.text = "CircleTime:Long"
			"CircleTime:Long":
				archive_circle_time.text = "CircleTime:Short"
			"CircleTime:Short":
				archive_circle_time.text = "CircleTime:Default"
		)
	archive_circle_time_ui = archive_circle_time
	option_box.add_child(archive_circle_time)
	
	var archive_difficulty = Button.new() # 存档难度设置
	archive_difficulty.text = "Difficulty:Default"
	archive_difficulty.connect("pressed",func():
		AudioManager.play_audio("Interaction") # 点击音效
		match archive_difficulty.text:
			"Difficulty:Default":
				archive_difficulty.text = "Difficulty:Hard"
			"Difficulty:Hard":
				archive_difficulty.text = "Difficulty:Eazy"
			"Difficulty:Eazy":
				archive_difficulty.text = "Difficulty:Default"
		)
	archive_difficulty_ui = archive_difficulty
	option_box.add_child(archive_difficulty)

#region 创建和取消按钮
func _on_cancel_pressed():
	UIManager.get_ui("ArchiveMenu", self) # 加载存档面板
	AudioManager.play_audio("Interaction") # 点击音效
	_close() # 关闭此面板
func _on_cancel_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
func _on_create_pressed():
	archive_data.archive_name = archive_name_ui.text # 存档名称
	archive_data.archive_seed = (archive_seed_ui.text as String).hash() # 存档种子
	archive_data.archive_cycle_time = ArchiveData.ArchiveCircleTime.DEFAULT # 存档周期
	archive_data.archive_difficulty = ArchiveData.ArchiveDifficulty.DEFAULT # 存档难度
	if DataManager.has_registered(archives_data_name): # 如果数据已有存档列表
		var archive_dic:Dictionary = DataManager.get_data(archives_data_name) # 获取存档列表
		archive_dic[archive_name_ui.text] = archive_data.to_dictionary() # 添加新存档数据
		DataManager.set_data(archives_data_name, archive_dic) # 更新存档列表
	else: # 如果没有存档列表
		DataManager.register_data(archives_data_name, {archive_name_ui.text:archive_data}) # 新注册存档列表{存档名:存档数据}
	UIManager.get_ui("ArchiveMenu", self) # 加载存档面板
	AudioManager.play_audio("Interaction") # 点击音效
	_close() # 关闭面板
func _on_create_mouse_entered():
	AudioManager.play_audio("Focus") # 鼠标触碰音效
#endregion
