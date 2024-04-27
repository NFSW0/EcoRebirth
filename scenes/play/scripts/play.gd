extends Node
# 游玩场景 同步玩家和世界

@onready var multiplayer_spawner = $MultiplayerSpawner # 多人生成器


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"): # 特效功能测试
		EffectManager.play_effect("ExampleEffect", Vector2i(100,50)) # 特效功能测试
	
	if event.is_action_pressed("ui_cancel"): # 打开灰幕与游戏菜单
		UIManager.get_ui("GreyScreen", self) # 打开灰幕与游戏菜单
