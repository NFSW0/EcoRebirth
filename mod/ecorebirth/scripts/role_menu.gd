class_name RoleMenu
extends Control
# 玩家角色菜单 选择角色或创建角色 完成后进入存档选择或多人菜单

signal player_selected() # 玩家选择完成信号
const player_data_name = "ecorebirth_player" # 玩家数据集索引值
@onready var player_box = %PlayerBox # 玩家角色选项盒

func _ready():
	connect("visibility_changed", _refresh)
	_refresh()

func _input(event): # 通过数字实现快速点击对应按钮
	if event.is_released() and event is InputEventKey: # 键盘松开
		_handle_numeric_input(event) # 处理数字输入的函数

func _handle_numeric_input(event: InputEventKey): # 处理数字输入
	var key_str = event.as_text() # 获取字符化的按键
	if "1" <= key_str and key_str <= "9": # 确认是数字键
		var index = int(key_str) - 1 # 获取索引
		if index < player_box.get_child_count(): # 防止溢出
			var button = player_box.get_child(index) # 获取按钮
			button.emit_signal("pressed") # 触发点击事件

func _close(): # 关闭面板
	queue_free()

func _refresh(): # 刷新显示
	for child in player_box.get_children(): # 遍历所有选项
		child.queue_free() # 清理选项
	var player_datas:Dictionary = DataManager.get_data(player_data_name,{}) # 获取角色列表
	_add_player_option(player_datas) # 添加玩家选项
	_add_new_player_option() # 添加新建玩家选项

func _add_player_option(player_datas: Dictionary): # 添加玩家选项
	for player_name in player_datas.keys(): # 遍历存档集合
		var button = Button.new() # 新建选项
		button.text = player_name # 修改按钮文字
		button.connect("pressed", func(): # 设置按钮点击事件
			AudioManager.play_audio("Interaction") # 点击音效
			var player_data = player_datas[player_name] # 读取玩家数据
			if DataManager.has_registered("using_player_data"): # 设置为使用中的玩家数据
				DataManager.set_data("using_player_data",player_data) # 更新数据
			else: # 如果没注册
				DataManager.register_data("using_player_data",player_data) # 注册数据
			player_selected.emit() # 发出玩家选择完成信号
			_close() # 关闭此面板
			)
		button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置鼠标触碰事件
		player_box.add_child(button) # 添加选项

func _add_new_player_option(): # 添加新建玩家选项
	var button = Button.new() # 新建选项
	button.text = "+" # 修改按钮文字
	button.connect("pressed", func(): # 设置按钮点击事件
		AudioManager.play_audio("Interaction") # 点击音效
		UIManager.get_ui("NewRoleMenu", self) # 加载新建玩家面板
		hide() # 隐藏此面板
		)
	button.connect("mouse_entered", func():AudioManager.play_audio("Focus")) # 设置鼠标触碰事件
	player_box.add_child(button) # 添加选项
