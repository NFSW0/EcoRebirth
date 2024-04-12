class_name MainMenu
extends Control
# 主菜单交互界面 仅包含 仅监听 四个按钮 单人游戏 多人游戏 设置 退出

var hyperlinks : Control # 快捷链接面板
var version_number : Control # 版本号面板

@onready var single_play = %SinglePlay # 单人游戏
@onready var multi_play = %MultiPlay # 多人游戏
@onready var setting = %Setting # 设置
@onready var exit =%Exit # 退出

func _ready():
	hyperlinks = UIManager.get_ui("Hyperlinks", self) # 快捷链接
	version_number = UIManager.get_ui("VersionNumber", self) # 版本号

func _close(): # 关闭此面板 主要用于切换面板时剔除原面板
	hyperlinks.queue_free()
	version_number.queue_free()
	queue_free()

#region 按钮点击事件
func _on_single_play_pressed():
	AudioManager.play_audio("Interaction")
	pass # 存档界面
	_close()
func _on_multi_play_pressed():
	AudioManager.play_audio("Interaction")
	pass # 多人界面
	_close()
func _on_setting_pressed():
	AudioManager.play_audio("Interaction")
	UIManager.get_ui("SettingMenu", self) # 设置界面
	_close()
func _on_exit_pressed():
	AudioManager.play_audio("Interaction")
	get_tree().quit()
#endregion

#region 按钮触碰事件
func _on_single_play_mouse_entered():
	AudioManager.play_audio("Focus")
func _on_multi_play_mouse_entered():
	AudioManager.play_audio("Focus")
func _on_setting_mouse_entered():
	AudioManager.play_audio("Focus")
func _on_exit_mouse_entered():
	AudioManager.play_audio("Focus")
#endregion
