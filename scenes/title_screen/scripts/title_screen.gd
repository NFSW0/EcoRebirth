class_name TitleScreen
extends Control

func _ready():
	UIManager.get_ui("MainMenu", self) # 主菜单
	UIManager.get_ui("Hyperlinks", self) # 快捷链接
	UIManager.get_ui("VersionNumber", self) # 版本号
