extends Node

# UI界面-主菜单、版本号、快捷链接的回调函数
static func test(requester : Node): # 静态回调函数
	print("Callable Test Load By %s" % requester.name)
