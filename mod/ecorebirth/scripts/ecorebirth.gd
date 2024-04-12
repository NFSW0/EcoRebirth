extends Node

# UI界面-主菜单、版本号、快捷链接的回调函数
static func test(requester : Node): # 静态回调函数 - ui
	print("Callable Test Load By %s" % requester.name)
static func setting_test(value): # 静态回调函数 - setting
	print("Setting %s" % value)

static func setting_full_screen(value): # 设置全屏
	match value:
		true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_:
			print("未知数据: %s" % value)
static func setting_resolution(value): # 设置分辨率
	match value:
		"1920x1080":
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		"1280x720":
			DisplayServer.window_set_size(Vector2i(1280, 720))
		"800x600":
			DisplayServer.window_set_size(Vector2i(800, 600))
		_:
			print("未知数据: %s" % value)
static func setting_master_volume(value): # 设置主音量
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value)
