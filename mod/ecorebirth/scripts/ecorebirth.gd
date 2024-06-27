extends Node

# UI加载的回调函数
# 实现对请求者的调整
# 也可以通过在UI脚本中加入on_ui_loaded(requester)实现

# 设置选项回调函数
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

# 附益效果回调函数
static func debug_begin(_node:Node, active_adjunct:AdjunctActive):
	print("")
	print("adjunct:", active_adjunct.adjunct_data_tag)
	print("source:", "null" if active_adjunct.adjunct_source == null else str(active_adjunct.adjunct_source.name))
	print("target:", "null" if active_adjunct.adjunct_target == null else str(active_adjunct.adjunct_target.name))
	print("permanency:", active_adjunct.permanency)
	print("stack:", active_adjunct.stack)
	print("tick_remain:", active_adjunct.tick_remain)
	print("duration_remain:", active_adjunct.duration_remain)
static func debug_tick(_node:Node, active_adjunct:AdjunctActive):
	if active_adjunct.tick_remain > 0:
		return
	active_adjunct.tick_remain += 1
	print("")
	print("adjunct:", active_adjunct.adjunct_data_tag)
	print("source:", "null" if active_adjunct.adjunct_source == null else str(active_adjunct.adjunct_source.name))
	print("target:", "null" if active_adjunct.adjunct_target == null else str(active_adjunct.adjunct_target.name))
	print("permanency:", active_adjunct.permanency)
	print("stack:", active_adjunct.stack)
	print("tick_remain:", active_adjunct.tick_remain)
	print("duration_remain:", active_adjunct.duration_remain)
static func debug_end(_node:Node, active_adjunct:AdjunctActive):
	print("")
	print("adjunct:", active_adjunct.adjunct_data_tag)
	print("source:", "null" if active_adjunct.adjunct_source == null else str(active_adjunct.adjunct_source.name))
	print("target:", "null" if active_adjunct.adjunct_target == null else str(active_adjunct.adjunct_target.name))
	print("permanency:", active_adjunct.permanency)
	print("stack:", active_adjunct.stack)
	print("tick_remain:", active_adjunct.tick_remain)
	print("duration_remain:", active_adjunct.duration_remain)
static func debug_stacking(_node:Node, active_adjunct:AdjunctActive):
	active_adjunct.stack += 1
	print("")
	print("adjunct:", active_adjunct.adjunct_data_tag)
	print("source:", "null" if active_adjunct.adjunct_source == null else str(active_adjunct.adjunct_source.name))
	print("target:", "null" if active_adjunct.adjunct_target == null else str(active_adjunct.adjunct_target.name))
	print("permanency:", active_adjunct.permanency)
	print("stack:", active_adjunct.stack)
	print("tick_remain:", active_adjunct.tick_remain)
	print("duration_remain:", active_adjunct.duration_remain)
