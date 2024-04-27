class_name GreyScreen
extends Control
# 灰幕 用于遮挡并隐藏后方UI 前后分割UI 关闭时恢复后方UI

signal on_close() # 关闭信号 未使用
signal ui_hided() # 隐藏完成信号 未使用
var hided_ui := [] # 记录已隐藏的UI 用于恢复显示

func on_ui_loaded(_requester): # 当灰幕被加载后
	for child in UIManager.get_children(): # 遍历已有UI对象
		if child == self: # 跳过自己
			continue # 跳过自己
		hided_ui.append(child) # 隐藏的UI加入记录
		child.hide() # 隐藏UI
	ui_hided.emit() # 触发隐藏完成信号
	var game_menu = UIManager.get_ui("GameMenu", self) # 打开游戏菜单
	game_menu.connect("on_close",_close) # 添加关闭监听

func _close():
	for ui in hided_ui:
		ui.show()
	queue_free()
	on_close.emit()
