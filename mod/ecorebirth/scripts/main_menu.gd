class_name MainMenu
extends Control
# 主菜单交互界面 仅包含 仅监听 四个按钮 单人游戏 多人游戏 设置 退出

@onready var single_play = %SinglePlay # 单人游戏
@onready var multi_play = %MultiPlay # 多人游戏
@onready var setting = %Setting # 设置
@onready var exit =%Exit # 退出


func _on_single_play_pressed():
	AudioManager.play_audio("Interaction")
	pass # 存档界面


func _on_multi_play_pressed():
	AudioManager.play_audio("Interaction")
	pass # 多人界面


func _on_setting_pressed():
	AudioManager.play_audio("Interaction")
	pass # 设置界面


func _on_exit_pressed():
	AudioManager.play_audio("Interaction")
	get_tree().quit()

#region 按钮触碰音效
func _on_single_play_mouse_entered():
	AudioManager.play_audio("Focus")
func _on_multi_play_mouse_entered():
	AudioManager.play_audio("Focus")
func _on_setting_mouse_entered():
	AudioManager.play_audio("Focus")
func _on_exit_mouse_entered():
	AudioManager.play_audio("Focus")
#endregion
