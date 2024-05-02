extends CharacterBody2D

signal position_changed(position)
var character_data
@onready var body = %Body
@onready var face = %Face

func _ready() -> void:
	_multi_ready()

func _input(event):
	if event.is_action_pressed("main_interaction"):
		position = event.position
		position_changed.emit(position)

#region 多人相关初始化
func _multi_ready():
	if is_multiplayer_authority():
		get_tree().current_scene.player = self
	if multiplayer.is_server():
		_init_character_data(character_data)
	else:
		rpc_id(1, "_send_character_data")

## 发送特效数据
@rpc("any_peer", "reliable")
func _send_character_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_character_data", character_data)

## 属性赋值
@rpc("any_peer", "reliable")
func _init_character_data(_character_data):
	character_data = _character_data
	var body_texture = TextureManager.get_texture(character_data["body"])
	body.offset = Vector2(0, -body_texture.get_height() / 2)
	body.texture = body_texture
	face.texture = TextureManager.get_texture(character_data["face"])
#endregion
