extends AnimatedSprite2D


var effect_data # 特效数据
@onready var multiplayer_synchronizer = $MultiplayerSynchronizer # 多人同步器
@onready var visible_on_screen_notifier_2D = $VisibleOnScreenNotifier2D # 屏幕可见判定器

## 初始化
func _ready() -> void:
	if multiplayer.is_server():
		_init_effect_data(effect_data)
		play("default") # 播放动画
	else:
		rpc_id(1, "_send_effect_data")

## 服务端-发送特效数据
@rpc("any_peer", "reliable")
func _send_effect_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_effect_data", effect_data)

## 属性赋值
@rpc("reliable")
func _init_effect_data(_effect_data):
	effect_data = _effect_data
	sprite_frames = load(_effect_data["effect_resource_path"])
	visible_on_screen_notifier_2D.rect = Rect2(_effect_data["position"], _effect_data["size"])

func _on_animation_finished():
	queue_free()
