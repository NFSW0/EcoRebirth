extends Node
# 游玩场景 同步玩家和世界

@onready var multiplayer_spawner = $MultiplayerSpawner # 多人生成器

func _input(event):
	if event.is_action_pressed("ui_accept"):
		EffectManager.play_effect("ExampleEffect", func(effect_node):(effect_node as AnimatedSprite2D).position = Vector2i(100,50))
