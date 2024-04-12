extends Node

# UI界面-主菜单、版本号、快捷链接的回调函数
static func test(requester : Node): # 静态回调函数 - ui
	print("Callable Test Load By %s" % requester.name)
static func setting_test(value): # 静态回调函数 - setting
	print("Setting %s" % value)

static func setting_full_screen(value): # 设置全屏
	match value:
		true:
			print("开启全屏")
		false:
			print("关闭全屏")
		_:
			print("未知数据: %s" % value)
static func setting_resolution(value): # 设置分辨率
	print("setting_resolution: %s" % value)
static func setting_main_volume(value): # 设置主音量
	print("setting_main_volume: %s" % value)
