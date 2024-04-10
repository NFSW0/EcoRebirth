class_name TitleScreen
extends Control

@onready var back_ground = %BackGround

func _ready():
	back_ground.texture = TextureManager.get_texture("TitleScreenBackGround") # 加载背景
	UIManager.get_ui("MainMenu", self) # 主菜单
	UIManager.get_ui("Hyperlinks", self) # 快捷链接
	UIManager.get_ui("VersionNumber", self) # 版本号
