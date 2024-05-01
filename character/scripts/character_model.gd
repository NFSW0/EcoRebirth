extends CharacterBody2D

signal init_completed()
var character_data
@onready var body = %Body
@onready var face = %Face

@rpc("any_peer","call_local","reliable")
func set_authority(peer_id):
	set_multiplayer_authority(peer_id)

func _ready() -> void:
	if multiplayer.is_server():
		_init_character_data(character_data)
	else:
		rpc_id(1, "_send_character_data")

## 服务端-发送特效数据
@rpc("any_peer", "reliable")
func _send_character_data():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "_init_character_data", character_data)

## 属性赋值
@rpc("reliable")
func _init_character_data(_character_data):
	character_data = _character_data
	var body_texture = TextureManager.get_texture(character_data["body"])
	body.offset = Vector2(0, -body_texture.get_height() / 2)
	body.texture = body_texture
	face.texture = TextureManager.get_texture(character_data["face"])
	init_completed.emit()
