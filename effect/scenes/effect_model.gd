extends AnimatedSprite2D


@onready var multiplayer_synchronizer = $MultiplayerSynchronizer # 多人同步器
@onready var visible_on_screen_notifier_2D = $VisibleOnScreenNotifier2D # 屏幕可见判定器


func init(_sprite_frames : SpriteFrames, _rect : Rect2):
	sprite_frames = _sprite_frames
	visible_on_screen_notifier_2D.rect = _rect


#func _ready():
	#multiplayer_synchronizer.add_visibility_filter(_visable_filter) # 添加可见性过滤器
#
#
#func _visable_filter(_peer_id:int) -> bool: # 可见性过滤器
	#return visible_on_screen_notifier_2D.is_on_screen()


func _on_animation_finished():
	queue_free()
